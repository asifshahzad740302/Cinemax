import 'package:cinemax_fyp/Screens/PrivacyPolicy.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore, FieldValue;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Screens/Terms&Condition.dart';
import 'Login.dart';
class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _ischecked=false;
  final TextEditingController emailController=TextEditingController();
  final TextEditingController passController=TextEditingController();
  final TextEditingController nameController=TextEditingController();
  final _formkey=GlobalKey<FormState>();
  bool _obsecurepass=true;

  bool isLoading=false;

  Future<void> _saveUserToFirestore(User user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'isVerified': false,
        'authMethod': 'email',
      });
    } catch (e) {
      print("Error saving to Firestore: $e");
    }
  }
  Future<void> RegisterUsingAuth()async{
    setState(() {
      isLoading=true;
    });
    try{
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passController.text.trim());
      User? user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();
        await _saveUserToFirestore(user);

        Get.defaultDialog(
          title: "Verify your email",
          middleText: "A verification link has been sent to ${user.email}. Please verify to continue.",
          textConfirm: "Go to Login",
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.offAll(() => const loginscreen());
          },
        );
      }

    }on FirebaseAuthException catch(e){
      Get.snackbar('Error', e.message.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,);
      print('error${e.message}');
    }
    catch(e){
      print('error${e.toString()}');
      Get.snackbar('Error', '${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    finally{
      setState(() {
        isLoading=false;
      });
    }
  }

  @override
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
              height: 28,
              width: 24,
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
        title: Text('Sign Up',style: GoogleFonts.montserrat(fontSize: 16,
          fontWeight: FontWeight.w600,color: Colors.white,),),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Column(
                children: [
                  SizedBox(height: height*.06,),
                  Text('Let’s get started',style: GoogleFonts.montserrat(fontSize: 24,
                      fontWeight: FontWeight.w600,color: Colors.white),),
                  SizedBox(height: height*.01,),
                  Text('The latest movies and series\nare here',textAlign:TextAlign.center,style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,
                    fontSize: 12,color: Color(0xffEBEBEF),),),
                  SizedBox(height: height*.10,),
                  TextFormField(
                    controller: nameController,
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Enter your Full Name';
                      }
                      return null;
                    },
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,
                        fontSize: 14,color: Colors.grey),
                    decoration: InputDecoration(
                      label: Text('Full Name',style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,
                        fontSize: 12,color: Color(0xffEBEBEF),),),
                      hintText: 'Enter your Full Name',
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
                  SizedBox(height: height*.03,),
                  TextFormField(
                    controller: emailController,
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Enter your email';
                      }
                      if(!value.contains('@')){
                        return 'enter valid email';
                      }
                      return null;
                    },
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,
                        fontSize: 14,color: Colors.grey),
                    decoration: InputDecoration(
                      label: Text('Email Address',style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,
                        fontSize: 12,color: Color(0xffEBEBEF),),),
                      hintText: 'Enter your Email Address',
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
                  SizedBox(height: height*.03,),
                  TextFormField(
                    controller: passController,
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Enter your Password';
                      }
                      return null;
                    },
                    obscureText: _obsecurepass,
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,
                        fontSize: 14,color: Colors.grey),
                    decoration: InputDecoration(
                      label: Text('Password',style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,
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
                  SizedBox(height: height*.01,),
                  CheckboxListTile(
                    value: _ischecked,
                    onChanged: (bool? newValue){
                    setState(() {
                      _ischecked= newValue ?? false;
                    });
                    },
                    controlAffinity: ListTileControlAffinity.leading, // Moves checkbox to the start
                    contentPadding: EdgeInsets.zero,
                    title: Text.rich(
                      TextSpan(
                        text: 'I agree to the ',
                        style: GoogleFonts.montserrat(color: Colors.grey,fontSize: 12,
                        fontWeight: FontWeight.w500),
                        children: [
                          TextSpan(
                            text: 'Terms and Services',
                            style: GoogleFonts.montserrat(color: Color(0xff12CDD9), fontWeight: FontWeight.bold,
                            fontSize: 12),
                            recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>TermsScreen()));
                            },
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: GoogleFonts.montserrat(color: Color(0xff12CDD9), fontWeight: FontWeight.bold,
                            fontSize: 12),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>PrivacyScreen()));
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: height*.04,),
                  GestureDetector(
                    onTap: () {
                      if (_ischecked) {
                        if (_formkey.currentState!.validate()) {
                          RegisterUsingAuth();
                        }
                      }
                    },
                    child: Container(
                      height: height*.08,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: _ischecked ? const Color(0xff12CDD9) : Colors.grey,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Center(child: Text('Sign Up',style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,
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
