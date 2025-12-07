import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final contactController = TextEditingController();
  final addressController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    final uid = auth.currentUser?.uid;
    if (uid != null) {
      final doc = await firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        nameController.text = data['name'] ?? '';
        emailController.text = data['email'] ?? '';
        contactController.text = data['contact'] ?? '';
        addressController.text = data['address'] ?? '';
      }
    }
    setState(() => isLoading = false);
  }

  void saveProfile() async {
    final uid = auth.currentUser?.uid;
    if (uid != null) {
      await firestore.collection('users').doc(uid).update({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'contact': contactController.text.trim(),
        'address': addressController.text.trim(),
      });
      Get.snackbar("Success", "Profile updated!", snackPosition: SnackPosition.BOTTOM);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("User Profile"),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildTextField("Name", nameController, Icons.person),
                        _buildTextField("Email", emailController, Icons.email),
                        _buildTextField("Contact", contactController, Icons.phone),
                        _buildTextField("Address", addressController, Icons.home),
                        SizedBox(height: 25),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                          ),
                          onPressed: saveProfile,
                          icon: Icon(Icons.save),
                          label: Text("Save Changes", style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
