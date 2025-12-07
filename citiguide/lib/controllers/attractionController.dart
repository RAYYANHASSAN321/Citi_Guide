// ignore_for_file: body_might_complete_normally_nullable, unused_import, non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/views/DisplayAttraction.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

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

  // Function to pick images
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
        Get.snackbar("Success", "Images Selected Successfully!!");
      } else {
        Get.snackbar("Error", "No Image Selected!!");
      }
    } catch (e) {
      log(e.toString());
    }
  }

  // Upload selected Image to Cloudinary and return the url
  Future<String?> uploadToCloudinary() async {
    const String cloudName = 'dtupm0mck';
    const String uploadPreset = 'images';
    if (selectedFile.value == null && selectedFileBytes.value == null) {
      Get.snackbar("Error", "Please select an image first!!");
      return null;
    }

    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    try {
      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = uploadPreset;

      if (kIsWeb && selectedFileBytes.value != null) {
        request.files.add(http.MultipartFile.fromBytes(
            'file', selectedFileBytes.value!,
            filename: selectedFileName.value));
      } else if (selectedFile.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath('file', selectedFile.value!.path),
        );
      }
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);
      if (response.statusCode == 200) {
        final imageUrl = jsonResponse['secure_url'];
        Get.snackbar("Success", "Image Uploaded!");
        return imageUrl;
      } else {
        Get.snackbar("Error", "Error in Image Uploaded!");
      }
    } catch (e) {
      log(e.toString());
    }
  }

  // Add attraction to Firestore
  Future<void> addAttraction(String city) async {
    try {
      final imageUrl = await uploadToCloudinary();
      if (imageUrl == null) {
        Get.snackbar("Error", "Image not found");
        return;
      }

      CollectionReference attractionCollection =
          firestore.collection('Cities').doc(city).collection('Attractions');

      await attractionCollection.add({
        'name': at_name.text.trim(),
        'desc': at_desc.text.trim(),
        'image': imageUrl,
        'directionLink': directionLinkController.text.trim(),
      });

      Get.snackbar("Success", "Attraction inserted successfully!!");
      Get.to(() => DisplayAttraction(city: city));
    } catch (e) {
      log(e.toString());
      Get.snackbar("Error", "Attraction not inserted!!");
    }
  }

  // Fetch attractions from Firestore
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
      Get.snackbar("Error", "Attraction not fetching!!");
    }
  }
}
