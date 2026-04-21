import 'package:cinemax_fyp/Auth/loginSignUp.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'PrivacyPolicy.dart';
import 'Terms&Condition.dart';
import 'editProfile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout",style: GoogleFonts.montserrat(),),
        content: const Text("Are you sure you want to logout."),
        contentTextStyle: GoogleFonts.montserrat(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w600),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => LoginSignUp()), (route) => false,
              );
            },
            child: Text("YES",style: GoogleFonts.montserrat(fontWeight: FontWeight.bold,fontSize: 14),),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("NO",style: GoogleFonts.montserrat(fontWeight: FontWeight.bold,fontSize: 14),),
          ),
        ],
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1D2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1D2B),
        centerTitle: true,
        title: Text("Profile",style:GoogleFonts.montserrat(fontSize: 16,
          fontWeight: FontWeight.w600,color: Colors.white,)
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.edit, color: Color(0xff12CDD9)),
            title: const Text("Edit Profile",
                style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios,
                color: Color(0xff12CDD9), size: 16),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProfileScreen()));
            },
          ),
          const Divider(color: Colors.grey),
          ListTile(
            leading: const Icon(Icons.description, color: Colors.white),
            title: const Text("Terms & Conditions",
                style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios,
                color: Color(0xff12CDD9), size: 16),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>TermsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.white),
            title: const Text("Privacy Policy",
                style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios,
                color: Color(0xff12CDD9), size: 16),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>PrivacyScreen()));
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff12CDD9),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                logout(context);
              },
              child: const Text("Logout"),
            ),
          )
        ],
      ),
    );
  }
}