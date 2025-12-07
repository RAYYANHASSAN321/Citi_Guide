import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:user_pannel/controllers/attractionController.dart';
import 'package:user_pannel/views/AttractionDetailPage.dart';
import 'package:user_pannel/views/FavouritesPage.dart';

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
            icon: Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Get.to(() => FavouritesPage());
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Cities')
            .doc(city)
            .collection('Attractions')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error loading attractions'));
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          final attractions = snapshot.data!.docs;
          if (attractions.isEmpty) return Center(child: Text('No attractions found.'));

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
              var doc = attractions[index];
              var data = doc.data() as Map<String, dynamic>;
              var attractionId = doc.id;

              return FutureBuilder<bool>(
                future: con.isFavourite(attractionId),
                builder: (context, favSnapshot) {
                  bool isFav = favSnapshot.data ?? false;

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
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
                                          attractionId: attractionId,
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
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // Average rating below name
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('Cities')
                                      .doc(city)
                                      .collection('Attractions')
                                      .doc(attractionId)
                                      .collection('Reviews')
                                      .snapshots(),
                                  builder: (context, reviewSnapshot) {
                                    if (!reviewSnapshot.hasData) {
                                      return SizedBox(height: 20);
                                    }

                                    final reviews = reviewSnapshot.data!.docs;
                                    if (reviews.isEmpty) {
                                      return Text(
                                        'No ratings',
                                        style: TextStyle(color: Colors.white70, fontSize: 12),
                                      );
                                    }

                                    // Calculate average rating
                                    double sumRating = 0;
                                    int count = 0;
                                    for (var r in reviews) {
                                      final rData = r.data() as Map<String, dynamic>;
                                      if (rData.containsKey('rating')) {
                                        var rate = rData['rating'];
                                        if (rate is int) sumRating += rate.toDouble();
                                        else if (rate is double) sumRating += rate;
                                        count++;
                                      }
                                    }
                                    double avgRating = count == 0 ? 0 : sumRating / count;

                                    return Row(
                                      children: [
                                        Icon(Icons.star, color: Colors.yellowAccent, size: 16),
                                        SizedBox(width: 4),
                                        Text(
                                          avgRating.toStringAsFixed(1),
                                          style: TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          '($count)',
                                          style: TextStyle(color: Colors.white70, fontSize: 12),
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Icon(
                                      isFav ? Icons.favorite : Icons.favorite_border,
                                      color: isFav ? Colors.red : Colors.white,
                                    ),
                                    onPressed: () {
                                      con.toggleFavourite(city, attractionId);
                                    },
                                  ),
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
          );
        },
      ),
    );
  }
}
