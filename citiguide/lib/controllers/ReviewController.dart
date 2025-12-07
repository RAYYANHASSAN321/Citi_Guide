import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewController extends GetxController {
  final TextEditingController reviewText = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  var reviews = <DocumentSnapshot>[].obs;

  Future<void> addReview(String cityId, String attractionId) async {
    if (reviewText.text.trim().isEmpty) {
      Get.snackbar("Error", "Review cannot be empty");
      return;
    }

    try {
      await firestore
          .collection('Cities')
          .doc(cityId)
          .collection('Attractions')
          .doc(attractionId)
          .collection('Reviews')
          .add({
        'text': reviewText.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      reviewText.clear();
      Get.back();
      Get.snackbar("Success", "Review added");
    } catch (e) {
      Get.snackbar("Error", "Failed to add review");
    }
  }

  Future<void> fetchReviews(String cityId, String attractionId) async {
    final snapshot = await firestore
        .collection('Cities')
        .doc(cityId)
        .collection('Attractions')
        .doc(attractionId)
        .collection('Reviews')
        .orderBy('timestamp', descending: true)
        .get();

    reviews.value = snapshot.docs;
  }
}
