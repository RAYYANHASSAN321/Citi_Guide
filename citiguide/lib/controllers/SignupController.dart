import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/views/Signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController{

  final unameController = TextEditingController();
  final uemailController = TextEditingController();
  final upasswordController = TextEditingController();
  final uconfirmPassController = TextEditingController();
  final uaddressController = TextEditingController();
  final ucontactController = TextEditingController();



  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;


  var isObscurePass = true.obs;
  var isObscureConfirmPass = true.obs;

  void isPassToggle(){

    isObscurePass.value = !isObscurePass.value;
  }


    void isConfirmPassToggle(){

    isObscureConfirmPass.value = !isObscureConfirmPass.value;
  }


  bool validatePassword(){
    
    return upasswordController.text.trim() == uconfirmPassController.text.trim();

  }

  @override 
  void dispose(){

    super.dispose();
    unameController.dispose();
    upasswordController.dispose();
    uconfirmPassController.dispose();
    ucontactController.dispose();
    uaddressController.dispose();
    uemailController.dispose();

  }


  // signup function --------------

  void signup() async {

    try{
      await auth.createUserWithEmailAndPassword(
        email: uemailController.text.trim(), 
        password: upasswordController.text.trim()
        
        ).then((usercredential) async{
            
            String userid = usercredential.user!.uid;
            return await firestore.collection('users').doc(userid).set({

              'name' : unameController.text.trim(),
              'email' : uemailController.text.trim(),
              'password' : upasswordController.text.trim(),
              'contact' : ucontactController.text.trim(),
              'address' : uaddressController.text.trim(),
              'uid' : userid,
              'role' : 'admin'
            });
        })          
        .then((value){
          Get.snackbar("Success", "Account has been created!!");
          Get.to(() => SignInScreen());
        });
    }

    // incase any error occurs in signup work, catch will handle the error show you message in console log
    catch(e){

      log("signup failed : ${e.toString()}");
    }

  }
}


