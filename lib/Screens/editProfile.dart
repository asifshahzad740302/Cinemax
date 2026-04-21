import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final _formkey=GlobalKey<FormState>();
  String email = "";
  String base64Image = "";
  File? selectedImage;
  bool isLoading = true;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  ImageProvider? _getImageProvider() {
    if (selectedImage != null) {
      return FileImage(selectedImage!);
    }
    if (base64Image.isEmpty) return null;
    if (base64Image.startsWith("http")) {
      return NetworkImage(base64Image);
    }
    try {
      return MemoryImage(base64Decode(base64Image));
    } catch (e) {
      print("Image decode error: $e");
      return null;
    }
  }
  Future<void> fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    if (doc.exists) {
      setState(() {
        nameController.text = doc['name'] ?? "";
        emailController.text = doc['email'] ?? "";
        base64Image = doc['image'] ?? "";
        isLoading = false;
      });
    }
  }
  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
      final bytes = await selectedImage!.readAsBytes();
      base64Image = base64Encode(bytes);
    }
  }
  Future<void> updateProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({
      "name": nameController.text.trim(),
      "image": base64Image.isNotEmpty ? base64Image : "",
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile Updated Successfully"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1F1D2B),
      appBar: AppBar(
        backgroundColor: Color(0xff1F1D2B),
        leading: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color(0xff252836),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(Icons.arrow_back_ios,color: Colors.white,),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text("Edit Profile",style: GoogleFonts.montserrat(fontSize: 16,
          fontWeight: FontWeight.w600,color: Colors.white,),
        ),
      ),
      body: Form(
            key: _formkey,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                :SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundImage: _getImageProvider(),
                        child: (selectedImage == null && base64Image.isEmpty)
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.teal,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 25),
                  TextFormField(
                    controller: nameController,
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Name cannot be empty';
                      }
                      if (value.trim().length < 3) {
                        return "Name must be at least 3 characters";
                      }
                      return null;
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Name",
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    readOnly: true,
                    controller: emailController,
                    style: const TextStyle(color: Colors.grey),
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    readOnly: true,
                    obscureText: true,
                    controller: TextEditingController(text: "12345678"),
                    style: const TextStyle(color: Colors.grey),
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      if (_formkey.currentState!.validate()) {
                        updateProfile();
                      }
                    },
                    child: Text("Save Changes",style: GoogleFonts.montserrat(fontSize:16,fontWeight:FontWeight.w500,color: Colors.white)),
                  )
                ],
              ),
            ),
          ),
    );
  }
}