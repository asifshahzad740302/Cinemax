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
import '../Management/MovieProvider.dart';
import 'Management/TrailorController.dart';
import 'Management/WishlistProvider.dart';

Future <void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
          // options:  FirebaseOptions(
          //     apiKey: "AIzaSyAkJxBkFkLrYNjWMlbN9MDRvqnpRgv4X-k",
          //     authDomain: "cinemaxmovieapp.firebaseapp.com",
          //     projectId: "cinemaxmovieapp",
          //     storageBucket: "cinemaxmovieapp.firebasestorage.app",
          //     messagingSenderId: "260127264988",
          //     appId: "1:260127264988:web:a137f60356ede2d19da419",
          //     measurementId: "G-WV9X8MCC6C"
          // )
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
