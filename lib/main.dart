import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:skywise/home.dart';
import 'package:skywise/login.dart';
import 'package:skywise/profile.dart';
import 'package:skywise/service.dart';
import 'package:skywise/signup.dart';
import 'package:skywise/splash.dart';
import 'firebase_options.dart';

void main() async {
  runApp(const MyApp());
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       debugShowCheckedModeBanner: false,
       home: Profile());
  }
}
