import 'dart:async';
import 'package:cinemax_fyp/Screens/BottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Screens/OnBoaardingScreen/OnBoardingController.dart';
import 'Login.dart';
import 'loginSignUp.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }
  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isFirstTime) {
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const OnboardingScreen()));
      }
    } else if (isLoggedIn) {
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => CustomBottomNavigationBar()));
      }
    } else {
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const LoginSignUp()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: const Color(0xFF1F1D2B),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/TV.png', height: 200, width: 200, fit: BoxFit.cover),
              SizedBox(height: height * .01),
              Text(
                'CINEMAX',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 28,
                    color: const Color(0xff12cdd9)
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        )
    );
  }
}