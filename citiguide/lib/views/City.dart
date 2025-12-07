// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:ecommerce/controllers/citiescontrollers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:typed_data'; // needed for web image rendering

class AddCityScreen extends StatelessWidget {
  const AddCityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final con = Get.put(CitiesController());

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.lightBlueAccent],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "Add City",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                MyInputs(
                  email: con.citynameController,
                  text: "Enter city name...",
                  suffIcon: Icon(Icons.location_city),
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
                                          Icon(Icons.add_a_photo,
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
                    con.addCity();
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.lightBlueAccent],
                      ),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        )
                      ],
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                      child: Center(
                        child: Text(
                          "Add City",
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
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
    );
  }
}
