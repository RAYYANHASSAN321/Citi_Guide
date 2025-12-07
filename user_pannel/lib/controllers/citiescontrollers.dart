// ignore_for_file: body_might_complete_normally_nullable, unused_import

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:user_pannel/views/DisplayCity.dart';

class CitiesController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController citynameController = TextEditingController();

  var citiesdata = <Map<String, dynamic>>[].obs; // All cities
  var filteredCities = <Map<String, dynamic>>[].obs; // Filtered by search
  var city = <DocumentSnapshot>[].obs;

  var imageFile = Rxn<File>();
  var selectedFile = Rxn<File>();
  var selectedFileBytes = Rxn<List<int>>();
  var selectedFileName = ''.obs;

  // Pick image
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
        Get.snackbar("Error", "No image selected!");
      }
    } catch (e) {
      log(e.toString());
    }
  }

  // Upload to Cloudinary
  Future<String?> uploadToCloudinary() async {
    const String cloudName = 'dtupm0mck';
    const String uploadPreset = 'images';

    if (selectedFile.value == null && selectedFileBytes.value == null) {
      Get.snackbar("Error", "Please select an image first!");
      return null;
    }

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    try {
      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = uploadPreset;

      if (kIsWeb && selectedFileBytes.value != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            selectedFileBytes.value!,
            filename: selectedFileName.value,
          ),
        );
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
        Get.snackbar("Success", "Image uploaded!");
        return imageUrl;
      } else {
        Get.snackbar("Error", "Error in image upload!");
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  // Add city
  Future<void> addCity() async {
    try {
      final imageUrl = await uploadToCloudinary();
      if (imageUrl == null) {
        Get.snackbar("Error", "Image not found");
        return;
      }

      DocumentReference cityRef = firestore.collection('Cities').doc();
      DocumentSnapshot cityDoc = await cityRef.get();

      if (!cityDoc.exists) {
        await cityRef.set({
          'cityName': citynameController.text.trim(),
          'image': imageUrl,
        });
        log("City inserted successfully!");
      } else {
        log("City already exists!");
      }

      Get.to(() => DisplayCity());
    } catch (e) {
      log(e.toString());
    }
  }

  // Fetch city data
  Future<void> fetchdata() async {
    try {
      final QuerySnapshot data = await firestore.collection('Cities').get();
      if (data.docs.isNotEmpty) {
        List<Map<String, dynamic>> citylist = [];

        for (var doc in data.docs) {
          var cityMap = doc.data() as Map<String, dynamic>;
          cityMap['id'] = doc.id;
          citylist.add(cityMap);
        }

        citiesdata.value = citylist;
        filteredCities.value = citylist; // Sync filtered list
        city.value = data.docs;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  // Filter by name
  void filterCities(String query) {
    if (query.isEmpty) {
      filteredCities.value = citiesdata;
    } else {
      filteredCities.value = citiesdata
          .where((city) =>
              city['cityName'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  // Update city
  Future<void> updateCity(String docId, String newCityName) async {
    try {
      await firestore.collection('Cities').doc(docId).update({'cityName': newCityName});
      fetchdata();
      Get.snackbar("Success", "City updated successfully!");
    } catch (e) {
      log("Error in updation $e");
    }
  }

  // Delete city
  Future<void> deleteCity(String docId) async {
    try {
      await firestore.collection('Cities').doc(docId).delete();
      fetchdata();
      Get.snackbar("Success", "City deleted successfully!");
    } catch (e) {
      log("Error in deletion $e");
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchdata();
  }
}
