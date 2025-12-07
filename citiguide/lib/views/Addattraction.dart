// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:ecommerce/controllers/attractionController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:typed_data';

class AddAttractionScreen extends StatelessWidget {
  final Map list;
  final String Id;
  const AddAttractionScreen({super.key, required this.list, required this.Id});

  @override
  Widget build(BuildContext context) {
    final con = Get.put(AttractionController());

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurpleAccent, Colors.indigoAccent],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "Add Attraction for ${list['cityName']}",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                MyInputs(
                  email: con.at_name,
                  text: "Enter Attraction Name...",
                  suffIcon: Icon(Icons.place_outlined),
                ),
                SizedBox(height: 16),
                MyInputs(
                  email: con.at_desc,
                  text: "Enter Attraction Description...",
                  suffIcon: Icon(Icons.description_outlined),
                ),
                SizedBox(height: 16),
                // New input for Google Maps direction link
                MyInputs(
                  email: con.directionLinkController,
                  text: "Enter Google Maps Direction Link...",
                  suffIcon: Icon(Icons.map_outlined),
                ),
                SizedBox(height: 20),
                Obx(() {
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await con.pickImage();
                        },
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: con.selectedFile.value != null ||
                                      con.selectedFileBytes.value != null
                                  ? Colors.green
                                  : Colors.grey,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 4),
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: con.selectedFile.value != null
                                ? Image.file(con.selectedFile.value!,
                                    fit: BoxFit.cover)
                                : con.selectedFileBytes.value != null
                                    ? Image.memory(
                                        Uint8List.fromList(
                                            con.selectedFileBytes.value!),
                                        fit: BoxFit.cover,
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_photo_alternate,
                                              size: 40,
                                              color: Colors.grey.shade700),
                                          SizedBox(height: 8),
                                          Text(
                                            "Tap to select image",
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                            ),
                                          )
                                        ],
                                      ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        con.selectedFileName.value.isNotEmpty
                            ? con.selectedFileName.value
                            : "No image selected",
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  );
                }),
                SizedBox(height: 30),
                InkWell(
                  onTap: () {
                    con.addAttraction(Id);
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.indigoAccent, Colors.deepPurpleAccent],
                      ),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.4),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                      child: Center(
                        child: Text(
                          "Add Attraction",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyInputs extends StatelessWidget {
  final String text;
  final Icon suffIcon;
  final TextEditingController email;
  const MyInputs(
      {super.key,
      required this.text,
      required this.suffIcon,
      required this.email});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: email,
      decoration: InputDecoration(
        prefixIcon: suffIcon,
        filled: true,
        fillColor: Colors.white,
        hintText: text,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.blueGrey.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.indigo, width: 2),
        ),
      ),
    );
  }
}
