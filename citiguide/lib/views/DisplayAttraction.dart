// ignore_for_file: prefer_const_constructors, unnecessary_cast

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/controllers/attractionController.dart';
import 'package:ecommerce/views/Addattraction.dart';
import 'package:ecommerce/views/AttractionDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DisplayAttraction extends StatelessWidget {
  final String city;
  DisplayAttraction({super.key, required this.city});

  final AttractionController con = Get.put(AttractionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Attractions in $city"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.to(() => AddAttractionScreen(Id: city, list: {}));
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Cities')
            .doc(city)
            .collection('Attractions')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading attractions'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final attractions = snapshot.data!.docs;

          if (attractions.isEmpty) {
            return Center(child: Text('No attractions found.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: attractions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              var data = attractions[index].data() as Map<String, dynamic>;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        data['image'] ?? 'https://via.placeholder.com/150',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.to(() => AttractionDetailPage(
                                      cityId: city,
                                      attractionId: attractions[index].id,
                                      data: data,
                                    ));
                              },
                              child: Text(
                                data['name'] ?? 'No Name',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 3,
                                      color: Colors.black54,
                                      offset: Offset(1, 1),
                                    )
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('Cities')
                                        .doc(city)
                                        .collection('Attractions')
                                        .doc(attractions[index].id)
                                        .delete();
                                    Get.snackbar("Deleted", "Attraction deleted successfully");
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
