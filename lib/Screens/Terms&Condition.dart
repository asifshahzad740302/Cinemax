import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});
  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1D2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1D2B),
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
        title: Text("Terms & Conditions",style: GoogleFonts.montserrat(fontSize: 16,
          fontWeight: FontWeight.w600,color: Colors.white,),),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            """
Welcome to Cinemax 

By using this application, you agree to the following terms and conditions:

1. Usage of App
You agree to use this app only for lawful purposes. You must not misuse the platform.

2. User Accounts
You are responsible for maintaining the confidentiality of your account credentials.

3. Content
All movies trailers and media content are for informational and entertainment purposes only.

4. Restrictions
You may not copy, distribute, or modify app content without permission.

5. Updates
We may update or change these terms at any time without prior notice.

6. Termination
We reserve the right to suspend or terminate your account if any violation occurs.

Thank you for using Cinemax 
            """,
            style: GoogleFonts.montserrat(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}