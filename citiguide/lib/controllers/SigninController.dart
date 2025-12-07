import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/views/DisplayCity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class LoginController extends GetxController{


  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isObscure = true.obs;

  String UserId = "";
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void isToggle(){
    isObscure.value = !isObscure.value;
  }


  void login() async {
    try{

        UserCredential userCredential = await auth.signInWithEmailAndPassword(email: emailController.text.trim(), password: passwordController.text.trim());
     
      String uid = userCredential.user!.uid;
      DocumentSnapshot userDoc = await firestore.collection('users').doc(uid).get();

      if(userDoc.exists){
        Get.snackbar("Success", "Login Successfully");
        Get.to(()=>DisplayCity());
      }
     else{
      Get.snackbar("Error", "User not found  Invalid email or password!!");
     }
    }
    catch(e){
      log(e.toString());
    }
  }

}