// ignore_for_file: prefer_const_constructors, unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_pannel/controllers/citiescontrollers.dart';
import 'package:user_pannel/views/DisplayAttraction.dart';
import 'package:user_pannel/views/Signin.dart';
import 'package:user_pannel/views/UserProfilePage.dart';

class DisplayCity extends StatelessWidget {
  DisplayCity({super.key});

  final con = Get.put(CitiesController());
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    con.fetchdata();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          onChanged: (value) => con.filterCities(value),
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search city...",
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.white),
          ),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Get.to(() => const UserProfilePage());
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Get.offAll(() => SignInScreen());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Obx(() {
          var filteredCities = con.filteredCities;
          return GridView.builder(
            itemCount: filteredCities.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              var city = filteredCities[index];
              var cityId = city['id'];
              return Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      city['image'] ?? 'https://via.placeholder.com/150',
                      fit: BoxFit.cover,
                    ),
                    Container(color: Colors.black.withOpacity(0.4)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.to(() => DisplayAttraction(city: city['cityName']));
                          },
                          child: Text(
                            city['cityName'],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
          
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
