import 'dart:io';

import 'package:cinemax_fyp/Auth/New_Password.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'Auth/splash_screen.dart';
import 'package:cinemax_fyp/Management/MovieProvider.dart';
import 'package:cinemax_fyp/Management/TrailorController.dart';
import 'package:cinemax_fyp/Management/WishlistProvider.dart';

Future <void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: Platform.isIOS ? const FirebaseOptions(
          apiKey: "AIzaSyAMw_Q8TNit7XKt-IiLnYnACPqlrOc8DGI",
          appId: "1:260127264988:ios:94c81631ea32f0769da419",
          messagingSenderId: "260127264988",
          projectId: "cinemaxmovieapp",
          storageBucket: "cinemaxmovieapp.firebasestorage.app",
          iosClientId: "260127264988-v4685fi289ro766lvacqgd41t4u71vmc.apps.googleusercontent.com",
        ) : const FirebaseOptions(
          apiKey: "AIzaSyAkJxBkFkLrYNjWMlbN9MDRvqnpRgv4X-k",
          appId: "1:260127264988:android:YOUR_ANDROID_APP_ID",
          messagingSenderId: "260127264988",
          projectId: "cinemaxmovieapp",
          storageBucket: "cinemaxmovieapp.firebasestorage.app",
        ),
      );
      print('Firebase initialized successfully');
    }
    else {
      print('Firebase already initialized');
    }
  }
  catch(e){
      print('Firebase initialization error: \$e');
    }
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  await Hive.initFlutter();
  await Hive.openBox('Cinemax');
  Get.put(TrailerController());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    initDeepLinks();
  }

  void initDeepLinks() async {
    final uri = await _appLinks.getInitialLink();
    if (uri != null) {
      handleLink(uri);
    }
    _appLinks.uriLinkStream.listen((uri) {
      if (uri != null) {
        handleLink(uri);
      }
    });
  }
  void handleLink(Uri uri) {
    print("Deep Link: $uri");
    if (uri.path.contains("/__/auth/action")) {
      String? oobCode = uri.queryParameters['oobCode'];
      if (oobCode != null) {
        Get.to(() => NewPassword(oobCode: oobCode, uid: '',));
      }
    }
  }
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CINEMAX',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreen(),
    );
  }
}
