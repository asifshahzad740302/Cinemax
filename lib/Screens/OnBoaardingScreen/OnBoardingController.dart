import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Auth/loginSignUp.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/images/onboarding1.png",
      "title": "The biggest international and local film streaming",
      "description":
          "Discover a vast library of movies and series from all over the world, tailored just for you.",
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Offers ad-free viewing of high quality",
      "description":
          "Enjoy an uninterrupted cinematic experience with zero ads and stunning 4K resolution.",
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": "Our service brings together your favorite series",
      "description":
          "Download trailers and movies to your local storage to watch them offline anytime.",
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginSignUp()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF1F1D2B),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Image.asset(_onboardingData[index]["image"]!,
                              height: height*.70,width: width*.90,
                              fit: BoxFit.fill,),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF252836),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _onboardingData[index]["title"]!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                    fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                _onboardingData[index]["description"]!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? const Color(0xFF12CDD9) : Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_currentPage == _onboardingData.length - 1) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.ease);
                      }
                    },
                    child: Container(
                      height: 56, width: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF12CDD9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _currentPage == _onboardingData.length - 1 ? Icons.check : Icons.arrow_forward_ios,
                        color: Colors.white, size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
