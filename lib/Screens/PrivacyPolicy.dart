import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

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
        title: Text("Privacy Policy",style: GoogleFonts.montserrat(fontSize: 16,
          fontWeight: FontWeight.w600,color: Colors.white,),),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            """
Your privacy is important to us.

1. Information Collection
We collect basic information such as name, email, and profile image.

2. Data Usage
Your data is used to personalize your experience and improve our services.

3. Security
We use Firebase Authentication and Firestore to keep your data secure.

4. No Data Sharing
We do NOT sell or share your personal data with third parties.

5. Media Content
Trailers are fetched from public APIs or services.

6. User Control
You can update or delete your data anytime from your profile.

7. Changes to Policy
We may update this policy from time to time.

Stay safe and enjoy Cinemax 
            """,
            style: TextStyle(
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