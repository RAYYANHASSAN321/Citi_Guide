// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:ecommerce/controllers/SigninController.dart';
import 'package:ecommerce/views/Signup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final con = Get.put(LoginController());
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Login",
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 30),

                  // Email Input
                  CustomInput(
                    controller: con.emailController,
                    hintText: "Email",
                    icon: Icons.email_outlined,
                  ),

                  SizedBox(height: 20),

                  // Password Input
                  Obx(() {
                    return CustomInput(
                      controller: con.passwordController,
                      hintText: "Password",
                      icon: con.isObscure.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      obscureText: con.isObscure.value,
                      toggleObscure: con.isToggle,
                    );
                  }),

                  SizedBox(height: 30),

                  // Login Button
                  ElevatedButton(
                    onPressed: () => con.login(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF9800),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      "Sign In",
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),

                  SizedBox(height: 20),

                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () => Get.to(SignUpScreen()),
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                                color: Color(0xFFFF9800),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom styled input
class CustomInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final VoidCallback? toggleObscure;

  const CustomInput({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.toggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.grey[900],
        suffixIcon: toggleObscure != null
            ? IconButton(
                icon: Icon(icon, color: Colors.white),
                onPressed: toggleObscure,
              )
            : Icon(icon, color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
