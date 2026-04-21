import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Login.dart';
class NewPassword extends StatefulWidget {
  final String oobCode;
  final String uid;

  const NewPassword({super.key, required this.oobCode, required this.uid});

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool _obsecurepass=true;
  bool isLoading = false;
  @override
  Future<void> updatePassword() async {
    if(isLoading) return;
    setState(() {
      isLoading=true;
    });
    try {
      String newPass = passwordController.text.trim();
      await _auth.confirmPasswordReset(
          code: widget.oobCode,
          newPassword: newPass,
      );
      var userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({
        'password': newPass,
      });
      Get.snackbar("Success", "Password updated successfully!",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      Get.offAll(() => const loginscreen());

    } catch (e) {
      print("ERROR: $e");

      if (e.toString().contains('expired')) {
        Get.snackbar("Error", "Reset link expired",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else if (e.toString().contains('invalid')) {
        Get.snackbar("Error", "Invalid reset link",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar("Error", "Something went wrong",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    }
    finally{
      setState(() {
        isLoading=false;
      });
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
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: height*.06),
              Text('Create New Password',style: GoogleFonts.montserrat(fontSize: 24,
                  fontWeight: FontWeight.w600,color: Colors.white),),
              SizedBox(height: height*.01,),
              Text('Enter your new password',textAlign: TextAlign.center,style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,
                fontSize: 12,color: Color(0xffEBEBEF),),),
              SizedBox(height: height*.08,),
              TextFormField(
                validator: (value){
                  if(value!.isEmpty){
                    return 'Enter correct password';
                  }else if (value.length < 8) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                controller: passwordController,
                obscureText: _obsecurepass,
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,
                    fontSize: 14,color: Colors.grey),
                decoration: InputDecoration(
                  label: Text('New Password',style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,
                    fontSize: 12,color: Color(0xffEBEBEF),),),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obsecurepass = !_obsecurepass;
                      });
                    },
                    child: Icon(
                        _obsecurepass ? Icons.visibility : Icons.visibility_off),
                  ),
                  hintText: 'Enter strong password',
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
              SizedBox(height: height*.02,),
              TextFormField(
                validator: (value){
                  if(value!.isEmpty){
                    return 'Enter correct password';
                  }else if (value != passwordController.text) {
                    return 'Enter same Passwords';
                  }
                  return null;
                },
                controller: confirmController,
                obscureText: _obsecurepass,
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,
                    fontSize: 14,color: Colors.grey),
                decoration: InputDecoration(
                  label: Text('Confirm Password',style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,
                    fontSize: 12,color: Color(0xffEBEBEF),),),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obsecurepass = !_obsecurepass;
                      });
                    },
                    child: Icon(
                        _obsecurepass ? Icons.visibility : Icons.visibility_off),
                  ),
                  hintText: 'Enter strong password',
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
              SizedBox(height: height*.08,),
              GestureDetector(
                onTap: (){
                  if (_formKey.currentState!.validate()){
                    updatePassword();
                  }
                },
                child: Container(
                  height: height*.08,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: Color(0xff12cdd9),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Center(child: Text('Reset',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16,color: Colors.white),)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
