import 'package:flutter/material.dart';
import 'package:skywise/login.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3,),(){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login(),));
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
       child: Image.asset("assets/splash.png",scale: 1,),
      ),
    );
  }
}