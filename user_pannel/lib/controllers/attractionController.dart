// ignore_for_file: body_might_complete_normally_nullable, unused_import, non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_pannel/views/DisplayAttraction.dart';

class AttractionController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController at_name = TextEditingController();
  final TextEditingController at_desc = TextEditingController();
  final TextEditingController directionLinkController = TextEditingController();

  var attractions = <DocumentSnapshot>[].obs;

  var imageFile = Rxn<File>();
  var selectedFile = Rxn<File>();
  var selectedFileBytes = Rxn<List<int>>();
  var selectedFileName = ''.obs;

  final userId = FirebaseAuth.instance.currentUser?.uid;

  // Function to pick image
  Future<void> pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        selectedFileName.value = result.files.single.name;

        if (kIsWeb) {
          selectedFileBytes.value = result.files.single.bytes;
        } else {
          selectedFile.value = File(result.files.single.path!);
        }

        Get.snackbar("Success", "Image selected successfully!");
      } else {
        Get.snackbar("Error", "No image selected.");
      }
    } catch (e) {
      log(e.toString());
    }
  }

  // Upload image to Cloudinary and return URL
  Future<String?> uploadToCloudinary() async {
    const String cloudName = 'dtupm0mck';
    const String uploadPreset = 'images';

    if (selectedFile.value == null && selectedFileBytes.value == null) {
      Get.snackbar("Error", "Please select an image first.");
      return null;
    }

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    try {
      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = uploadPreset;

      if (kIsWeb && selectedFileBytes.value != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          selectedFileBytes.value!,
          filename: selectedFileName.value,
        ));
      } else if (selectedFile.value != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          selectedFile.value!.path,
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200) {
        final imageUrl = jsonResponse['secure_url'];
        Get.snackbar("Success", "Image uploaded successfully!");
        return imageUrl;
      } else {
        Get.snackbar("Error", "Image upload failed.");
        return null;
      }
    } catch (e) {
      log(e.toString());
      Get.snackbar("Error", "Image upload error.");
      return null;
    }
  }

  // Add new attraction to Firestore
  Future<void> addAttraction(String city) async {
    try {
      final imageUrl = await uploadToCloudinary();
      if (imageUrl == null) return;

      CollectionReference attractionCollection =
          firestore.collection('Cities').doc(city).collection('Attractions');

      await attractionCollection.add({
        'name': at_name.text.trim(),
        'desc': at_desc.text.trim(),
        'image': imageUrl,
        'directionLink': directionLinkController.text.trim(),
      });

      Get.snackbar("Success", "Attraction added successfully!");
      Get.to(() => DisplayAttraction(city: city));
    } catch (e) {
      log(e.toString());
      Get.snackbar("Error", "Failed to add attraction.");
    }
  }

  // Fetch all attractions from a city
  Future<void> fetchAttraction(String CityID) async {
    try {
      final QuerySnapshot attractionData = await firestore
          .collection('Cities')
          .doc(CityID)
          .collection('Attractions')
          .get();

      attractions.value = attractionData.docs;
    } catch (e) {
      log(e.toString());
      Get.snackbar("Error", "Failed to fetch attractions.");
    }
  }

  // Toggle favourite attraction
  Future<void> toggleFavourite(String cityId, String attractionId) async {
    final favRef = firestore
        .collection('users')
        .doc(userId)
        .collection('favourites')
        .doc(attractionId);

    final doc = await favRef.get();

    if (doc.exists) {
      await favRef.delete();
      Get.snackbar("Removed", "Attraction removed from favourites.");
    } else {
      await favRef.set({
        'cityId': cityId,
        'attractionId': attractionId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      Get.snackbar("Added", "Attraction added to favourites.");
    }
  }

  // Check if an attraction is marked as favourite
  Future<bool> isFavourite(String attractionId) async {
    final doc = await firestore
        .collection('users')
        .doc(userId)
        .collection('favourites')
        .doc(attractionId)
        .get();
    return doc.exists;
  }

  // Stream favourite attractions of the user
  Stream<QuerySnapshot> getFavouriteAttractions() {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('favourites')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
