// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_import

import 'package:ecommerce/controllers/SignupController.dart';
import 'package:ecommerce/views/Signin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final con = Get.put(SignUpController());

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 30),

                CustomInput(text: "Username", icon: Icons.person, controller: con.unameController),
                SizedBox(height: 15),

                CustomInput(text: "Email", icon: Icons.email, controller: con.uemailController),
                SizedBox(height: 15),

                CustomInput(text: "Address", icon: Icons.home, controller: con.uaddressController),
                SizedBox(height: 15),

                CustomInput(text: "Contact", icon: Icons.phone, controller: con.ucontactController),
                SizedBox(height: 15),

                Obx(() {
                  return PasswordInput(
                    controller: con.upasswordController,
                    hint: "Password",
                    isObscure: con.isObscurePass.value,
                    toggle: con.isPassToggle,
                  );
                }),
                SizedBox(height: 15),

                Obx(() {
                  return PasswordInput(
                    controller: con.uconfirmPassController,
                    hint: "Confirm Password",
                    isObscure: con.isObscureConfirmPass.value,
                    toggle: con.isConfirmPassToggle,
                  );
                }),
                SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () {
                    if (con.validatePassword()) {
                      con.signup();
                    } else {
                      print("Password and confirm password don't match!");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF9800),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text("Sign Up", style: TextStyle(fontSize: 18, color: Colors.black)),
                ),

                SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Text("Already have an account?", style: TextStyle(color: Colors.white70)),
                      TextButton(
                        onPressed: () => Get.to(SignInScreen()),
                        child: Text(
                          "Login",
                          style: TextStyle(color: Color(0xFFFF9800), fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomInput extends StatelessWidget {
  final String text;
  final IconData icon;
  final TextEditingController controller;

  const CustomInput({
    super.key,
    required this.text,
    required this.icon,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: text,
        hintStyle: TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.grey[900],
        suffixIcon: Icon(icon, color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class PasswordInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isObscure;
  final VoidCallback toggle;

  const PasswordInput({
    super.key,
    required this.controller,
    required this.hint,
    required this.isObscure,
    required this.toggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.grey[900],
        suffixIcon: IconButton(
          icon: Icon(
            isObscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.white,
          ),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
