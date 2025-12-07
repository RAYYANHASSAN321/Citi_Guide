import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewController extends GetxController {
  final TextEditingController reviewText = TextEditingController();
  final RxInt rating = 0.obs;  // User rating input
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  var reviews = <DocumentSnapshot>[].obs;

  // Add review with rating
  Future<void> addReview(String cityId, String attractionId) async {
    if (reviewText.text.trim().isEmpty) {
      Get.snackbar("Error", "Review cannot be empty");
      return;
    }
    if (rating.value == 0) {
      Get.snackbar("Error", "Please select a rating");
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
        'rating': rating.value,
        'timestamp': FieldValue.serverTimestamp(),
      });
      reviewText.clear();
      rating.value = 0;
      Get.back();
      Get.snackbar("Success", "Review added");
      fetchReviews(cityId, attractionId); // Refresh reviews
    } catch (e) {
      Get.snackbar("Error", "Failed to add review");
    }
  }

  // Fetch reviews
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

  // Calculate average rating
  double get averageRating {
    if (reviews.isEmpty) return 0;
    double sum = 0;
    int count = 0;

    for (var r in reviews) {
      final data = r.data() as Map<String, dynamic>?;  // Safe cast
      if (data != null && data.containsKey('rating')) {
        final ratingVal = data['rating'];
        if (ratingVal is int || ratingVal is double) {
          sum += ratingVal.toDouble();
          count++;
        }
      }
    }
    return count == 0 ? 0 : sum / count;
  }
}
