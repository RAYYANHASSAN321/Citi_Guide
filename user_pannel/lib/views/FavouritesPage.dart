import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:user_pannel/controllers/attractionController.dart';
import 'package:user_pannel/views/AttractionDetailPage.dart';

class FavouritesPage extends StatelessWidget {
  final AttractionController con = Get.find<AttractionController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Favourite Attractions'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder(
        stream: con.getFavouriteAttractions(),
        builder: (context, favSnapshot) {
          if (favSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final favDocs = favSnapshot.data?.docs ?? [];
          if (favDocs.isEmpty) {
            return Center(
              child: Text('No favourites found.', style: TextStyle(fontSize: 16)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            separatorBuilder: (context, index) => SizedBox(height: 12),
            itemCount: favDocs.length,
            itemBuilder: (context, index) {
              final favData = favDocs[index].data() as Map<String, dynamic>;
              final cityId = favData['cityId'];
              final attractionId = favData['attractionId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Cities')
                    .doc(cityId)
                    .collection('Attractions')
                    .doc(attractionId)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return _loadingCard();
                  }

                  final attractionData = snapshot.data!.data() as Map<String, dynamic>?;
                  if (attractionData == null) return SizedBox.shrink();

                  return GestureDetector(
                    onTap: () {
                      Get.to(() => AttractionDetailPage(
                            cityId: cityId,
                            attractionId: attractionId,
                            data: attractionData,
                          ));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                            child: Image.network(
                              attractionData['image'] ?? '',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey,
                                child: Icon(Icons.image_not_supported, color: Colors.white),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    attractionData['name'] ?? 'No Name',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    attractionData['desc'] ?? '',
                                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Icon(Icons.favorite, color: Colors.red),
                          )
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

  Widget _loadingCard() {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4))],
      ),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
