 import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
     appBar: AppBar(
      automaticallyImplyLeading: false,
      foregroundColor: Colors.blue.shade900,
      backgroundColor: Colors.white,
      title: Text("Profile",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
      
    
     ),
    );
  }
}