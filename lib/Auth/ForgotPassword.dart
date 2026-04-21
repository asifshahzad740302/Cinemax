import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formkey=GlobalKey<FormState>();
  final TextEditingController emailController=TextEditingController();

  @override
  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> sendPasswordReset(String email) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userDoc.docs.isEmpty) {
        Get.snackbar("Error", "This email is not registered.",
          backgroundColor: Colors.red,
          colorText: Colors.white,);
        return;
      }
      String uid = userDoc.docs.first.id;

      bool _isVerified = userDoc.docs.first['isVerified'] ?? false;

      if (!_isVerified) {
        Get.snackbar("Error", "Please verify your email first",
          backgroundColor: Colors.orange,
          colorText: Colors.white,);
        return;
      }
      var actionCodeSettings = ActionCodeSettings(
        url: 'https://cinemaxmovieapp.firebaseapp.com/reset?uid=$uid',
        handleCodeInApp: true,
        androidPackageName: 'com.example.cinemax_fyp',
        androidInstallApp: true,
        androidMinimumVersion: '1',
      );
      await _auth.sendPasswordResetEmail(email: email,
        actionCodeSettings: actionCodeSettings,
      );
      Get.snackbar("Success", "Reset link sent to email",
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white
      );
    }
  }

  Widget build(BuildContext context) {
    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formkey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: height*.06),
                  Text('Reset Password',style: GoogleFonts.montserrat(fontSize: 24,
                      fontWeight: FontWeight.w600,color: Colors.white),),
                  SizedBox(height: height*.01,),
                  Text('Recover your account password',style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,
                    fontSize: 12,color: Color(0xffEBEBEF),),),
                  SizedBox(height: height*.10,),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    validator: (value){
                      if (value!.isEmpty){
                        return 'Enter your Registered Email';
                      }
                      return null;
                    },
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,
                        fontSize: 14,color: Colors.grey),
                    decoration: InputDecoration(
                      label: Text('Email Address',style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,
                        fontSize: 12,color: Color(0xffEBEBEF),),),
                      hintText: 'Enter your Registered Email',
                      hintStyle: GoogleFonts.montserrat(fontSize: 14,fontWeight: FontWeight.w500,color:Colors.grey),
                      filled: true,
                      fillColor: Color(0xff1F1D2B),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height: height*.05,),
                  GestureDetector(
                    onTap:() {
                      if(_formkey.currentState!.validate()) {
                        sendPasswordReset(emailController.text);
                      }
                      else {
                        print('Error: Something is Missing');
                      }
                    },
                    child: Container(
                      height: height*.08,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: Color(0xff12CDD9),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Center(child: Text('Next',style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,
                          fontSize: 16,color: Colors.white),),),
                    ),
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