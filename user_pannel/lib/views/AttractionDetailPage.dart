import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ReviewController extends GetxController {
  final TextEditingController reviewText = TextEditingController();
  final RxList<DocumentSnapshot> reviews = <DocumentSnapshot>[].obs;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addReview(String cityId, String attractionId, int rating) async {
    if (reviewText.text.trim().isEmpty) {
      Get.snackbar("Error", "Review cannot be empty");
      return;
    }
    if (rating < 1 || rating > 5) {
      Get.snackbar("Error", "Please select a rating between 1 and 5");
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
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });
      reviewText.clear();
      Get.back();
      Get.snackbar("Success", "Review added");
      await fetchReviews(cityId, attractionId);
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

  double get averageRating {
    if (reviews.isEmpty) return 0;
    double sum = 0;
    int count = 0;

    for (var r in reviews) {
      var data = r.data() as Map<String, dynamic>;
      if (data.containsKey('rating')) {
        sum += (data['rating'] ?? 0);
        count++;
      }
    }
    return count == 0 ? 0 : sum / count;
  }
}

class AttractionDetailPage extends StatefulWidget {
  final String cityId;
  final String attractionId;
  final Map<String, dynamic> data;

  const AttractionDetailPage({
    Key? key,
    required this.cityId,
    required this.attractionId,
    required this.data,
  }) : super(key: key);

  @override
  State<AttractionDetailPage> createState() => _AttractionDetailPageState();
}

class _AttractionDetailPageState extends State<AttractionDetailPage> {
  final ReviewController reviewController = Get.put(ReviewController());
  int selectedRating = 0;

  @override
  void initState() {
    super.initState();
    reviewController.fetchReviews(widget.cityId, widget.attractionId);
  }

  Future<void> _launchDirectionLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar("Error", "Could not open the direction link.");
    }
  }

  Widget _buildStarSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        int starIndex = index + 1;
        return IconButton(
          onPressed: () {
            setState(() {
              selectedRating = starIndex;
            });
          },
          icon: Icon(
            starIndex <= selectedRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 32,
          ),
        );
      }),
    );
  }

  Widget _buildRatingStars(double rating) {
    int fullStars = rating.floor();
    bool halfStar = (rating - fullStars) >= 0.5;

    return Row(
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, color: Colors.amber, size: 20);
        } else if (index == fullStars && halfStar) {
          return Icon(Icons.star_half, color: Colors.amber, size: 20);
        } else {
          return Icon(Icons.star_border, color: Colors.amber, size: 20);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data['name'] ?? 'Attraction Details'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.rate_review),
            onPressed: () {
              selectedRating = 0;
              reviewController.reviewText.clear();

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
                    Text("Rate this attraction:", style: TextStyle(fontWeight: FontWeight.bold)),
                    _buildStarSelector(),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedRating == 0) {
                          Get.snackbar("Error", "Please select a rating");
                          return;
                        }
                        reviewController.addReview(widget.cityId, widget.attractionId, selectedRating);
                      },
                      child: Text("Submit"),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Obx(() {
        final reviews = reviewController.reviews;
        final avgRating = reviewController.averageRating;

        return ListView(
          children: [
            Image.network(
              widget.data['image'] ?? 'https://via.placeholder.com/400',
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
                    widget.data['name'] ?? '',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),

                  Row(
                    children: [
                      _buildRatingStars(avgRating),
                      SizedBox(width: 8),
                      Text(avgRating > 0 ? avgRating.toStringAsFixed(1) : "No ratings yet",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),

                  SizedBox(height: 12),
                  Text(
                    widget.data['desc'] ?? '',
                    style: TextStyle(fontSize: 16),
                  ),

                  if ((widget.data['directionLink'] ?? '').isNotEmpty) ...[
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _launchDirectionLink(widget.data['directionLink']),
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

                  reviews.isEmpty
                      ? Text("No reviews yet.")
                      : Column(
                          children: reviews.map((review) {
                            var data = review.data() as Map<String, dynamic>;
                            int userRating = data['rating'] ?? 0;

                            return ListTile(
                              leading: Icon(Icons.comment),
                              title: Text(data['text'] ?? ''),
                              subtitle: Row(
                                children: [
                                  Row(
                                    children: List.generate(5, (index) {
                                      int starIndex = index + 1;
                                      return Icon(
                                        starIndex <= userRating ? Icons.star : Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                      );
                                    }),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    data['timestamp'] != null
                                        ? (data['timestamp'] as Timestamp).toDate().toLocal().toString()
                                        : '',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            )
          ],
        );
      }),
    );
  }
}
