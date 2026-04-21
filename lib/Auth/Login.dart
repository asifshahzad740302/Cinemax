import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Screens/BottomNavigationBar.dart';
import 'ForgotPassword.dart';
class loginscreen extends StatefulWidget {
  const loginscreen({super.key});

  @override
  State<loginscreen> createState() => _loginscreenState();
}

class _loginscreenState extends State<loginscreen> {
  final TextEditingController email_Controller=TextEditingController();
  final TextEditingController pass_Controller=TextEditingController();
  final __formkey=GlobalKey<FormState>();
  bool isLoading=false;
  bool _obsecurepass=true;
  String displayName = "user";

  void _fetchNameFromEmail(String email) async {
    if (email.contains('@') && email.contains('.')) {
      try {
        // Look for the document where the 'email' field matches
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email.trim())
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            displayName = querySnapshot.docs.first.get('name');
          });
        } else {
          setState(() {
            displayName = "user";
          });
        }
      } catch (e) {
        print("Error fetching name: $e");
      }
    }
  }

  Future<void> LoginUsingAuth()async{
    if (!__formkey.currentState!.validate()) return;
    setState(() {
      isLoading=true;
    });
    try{
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email_Controller.text.trim(),
          password: pass_Controller.text.trim());
      User? user = userCredential.user;
      if (user != null) {
        await user.reload(); // Refresh the user state from the server
        user = FirebaseAuth.instance.currentUser;
        if (user!.emailVerified) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'isVerified': true});
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userEmail', user.email ?? "");
          Get.snackbar('login', 'login Successfully',
            backgroundColor: Colors.blue,
            colorText: Colors.white,
          );
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>
          const CustomBottomNavigationBar()), (route) => false,
          );
        } else {
          await FirebaseAuth.instance.signOut();
          Get.snackbar(
            'Verify Email',
            'Please verify your email address before logging in.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
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
  void initState() {
    super.initState();
    email_Controller.addListener(() {
      _fetchNameFromEmail(email_Controller.text);
    });
  }
  Widget build(BuildContext context) {
    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xff1F1D2B),
      appBar: AppBar(
        backgroundColor: Color(0xff1F1D2B),
        leading: Padding(
          padding: EdgeInsets.all(16.0),
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
        title: Text('Login',style: GoogleFonts.montserrat(fontSize: 16,
          fontWeight: FontWeight.w600,color: Colors.white,),),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: __formkey,
              child: Column(
                children: [
                  SizedBox(height: height*.06,),
                  Text('Hi, $displayName',style: GoogleFonts.montserrat(fontSize: 24,
                      fontWeight: FontWeight.w600,color: Colors.white),),
                  SizedBox(height: height*.01,),
                  Text('Welcome back! Please enter\nyour details.',textAlign: TextAlign.center,style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,
                    fontSize: 12,color: Color(0xffEBEBEF),),),
                  SizedBox(height: height*.10,),
                  TextFormField(
                    controller: email_Controller,
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
                      labelText: 'Email Address',
                      labelStyle: GoogleFonts.montserrat(fontSize: 12,fontWeight: FontWeight.w500,
                        color:Color(0xffEBEBEF),),
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
                    controller: pass_Controller,
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Enter correct password';
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
                  SizedBox(height: height*.02,),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgotPassword()));
                      },
                      child: Text('Forgot Password?',style: GoogleFonts.montserrat(fontSize: 14,fontWeight: FontWeight.w500,
                          color: Color(0xff12CDD9)),),
                    ),
                  ),
                  SizedBox(height: height*.04,),
                  GestureDetector(
                    onTap: (){
                      if(__formkey.currentState!.validate()) {
                        LoginUsingAuth();
                      }
                    },
                    child: Container(
                      height: height*.08,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: Color(0xff12CDD9),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Center(child: Text('Login',style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,
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
