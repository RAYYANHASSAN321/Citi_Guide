import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/controllers/reviewController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AttractionDetailPage extends StatelessWidget {
  final String cityId;
  final String attractionId;
  final Map<String, dynamic> data;

  AttractionDetailPage({
    super.key,
    required this.cityId,
    required this.attractionId,
    required this.data,
  });

  final ReviewController reviewController = Get.put(ReviewController());

  // Function to launch Google Maps URL
  Future<void> _launchDirectionLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar("Error", "Could not open the direction link.");
    }
  }

  @override
  Widget build(BuildContext context) {
    reviewController.fetchReviews(cityId, attractionId);

    return Scaffold(
      appBar: AppBar(
        title: Text(data['name'] ?? 'Attraction Details'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.rate_review),
            onPressed: () {
              Get.defaultDialog(
                title: "Add Review",
                content: Column(
                  children: [
                    TextField(
                      controller: reviewController.reviewText,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Write your review here...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => reviewController.addReview(cityId, attractionId),
                      child: Text("Submit"),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: ListView(
        children: [
          Image.network(
            data['image'] ?? 'https://via.placeholder.com/400',
            fit: BoxFit.cover,
            height: 250,
            width: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? '',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  data['desc'] ?? '',
                  style: TextStyle(fontSize: 16),
                ),

                // Add Directions Button only if directionLink exists
                if ((data['directionLink'] ?? '').isNotEmpty) ...[
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _launchDirectionLink(data['directionLink']),
                    icon: Icon(Icons.directions),
                    label: Text("Get Directions"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                ],

                SizedBox(height: 20),
                Text(
                  "Reviews:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Obx(() => Column(
                      children: reviewController.reviews
                          .map(
                            (review) => ListTile(
                              leading: Icon(Icons.comment),
                              title: Text(review['text'] ?? ''),
                              subtitle: Text(
                                review['timestamp'] != null
                                    ? (review['timestamp'] as Timestamp)
                                        .toDate()
                                        .toLocal()
                                        .toString()
                                    : '',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          )
                          .toList(),
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }
}
