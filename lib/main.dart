import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/firebase_options.dart';
import 'package:juan_million/screens/admin_home.dart';
import 'package:juan_million/screens/coordinator_home.dart';
import 'package:juan_million/screens/landing_screen.dart';
import 'package:juan_million/screens/main_coordinator_home.dart';

import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'juan-million',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Juan 4 All - Coordinator',
      home: MainCoordinatorHomeScreen(),
    );
  }
}
