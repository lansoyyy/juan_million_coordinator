import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:juan_million/firebase_options.dart';
import 'package:juan_million/screens/admin_home.dart';
import 'package:juan_million/screens/coordinator_home.dart';
import 'package:juan_million/screens/landing_screen.dart';
import 'package:juan_million/screens/main_coordinator_home.dart';

import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyA3leMjuJqGHG6BSU-fTkG2ex4AhG_73og",
      authDomain: "juan-million.firebaseapp.com",
      projectId: "juan-million",
      storageBucket: "juan-million.appspot.com",
      messagingSenderId: "863618395212",
      appId: "1:863618395212:web:93821de4f8c53f5e9fd8e9"
          ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Juan 4 All - Coordinator',
      home: const LoginScreen(),
    );
  }
}
