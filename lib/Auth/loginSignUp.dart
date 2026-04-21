import 'package:cloud_firestore/cloud_firestore.dart'; // Add this
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For Splash logic
import '../Screens/BottomNavigationBar.dart';
import 'Login.dart';
import 'SignUp.dart';

class LoginSignUp extends StatefulWidget {
  const LoginSignUp({super.key});

  @override
  State<LoginSignUp> createState() => _LoginSignUpState();
}

class _LoginSignUpState extends State<LoginSignUp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void> _saveUserToFirestore(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName ?? "New User",
        'email': user.email,
        'image': user.photoURL ?? "",
        'createdAt': DateTime.now(),
        'authMethod': 'google',
      }, SetOptions(merge: true)); // Merge prevents overwriting on  existing data
      print("User data successfully saved to Firestore");
    }catch (e) {
      Get.snackbar("Error", "Failed to save user profile",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<UserCredential?> googleSignIn() async {
    String webid = '260127264988-9g082feidpucgkcj7a1nbl246o4pmabl.apps.googleusercontent.com';
    try {
      await _googleSignIn.initialize(serverClientId: webid);
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Google Sign-In failed',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xff1F1D2B),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Added to prevent overflow on small screens
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: height * 0.06),
              Image.asset('assets/images/TV.png', height: 150),
              SizedBox(height: height*.01),
              Text(
                'CINEMAX',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Enter your details to',
                style: GoogleFonts.montserrat(fontSize: 14,fontWeight: FontWeight.w500, color: Colors.grey),
              ),
              Text(
                'start streaming movies',
                style: GoogleFonts.montserrat(fontSize: 14,fontWeight: FontWeight.w500, color: Colors.grey),
              ),
              SizedBox(height: height * .06),

              // 1. SIGN UP BUTTON
              GestureDetector(
                onTap: () => Get.to(() => const SignUp()),
                child: Container(
                  height: 56,
                  width: width * .80,
                  decoration: BoxDecoration(
                    color: const Color(0xff12cdd9),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Center(
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? ', style: GoogleFonts.montserrat(fontSize:14,fontWeight: FontWeight.w500,color: Colors.grey)),
                  InkWell(
                    onTap: () => Get.to(() => const loginscreen()),
                    child: Text(
                      'Login',
                      style: GoogleFonts.montserrat(color: const Color(0xff12CDD9), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * .06),
              Row(
                children: [
                  const Expanded(child: Divider(color: Colors.grey)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('Or Sign In with', style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 12,fontWeight: FontWeight.w500)),
                  ),
                  const Expanded(child: Divider(color: Colors.grey)),
                ],
              ),

              const SizedBox(height: 30),
              GestureDetector(
                onTap: () async {
                  UserCredential? authResult = await googleSignIn();
                  if (authResult != null && authResult.user != null) {
                    await _saveUserToFirestore(authResult.user!);

                    Get.snackbar('Welcome', 'Logged in as ${authResult.user!.displayName}',
                      backgroundColor: Colors.blue,
                      colorText: Colors.white,
                    );
                    Get.offAll(() => const CustomBottomNavigationBar());
                  }
                },
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset('assets/images/Google.png', height: 30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
