import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
     appBar: AppBar(
      automaticallyImplyLeading: false,
      foregroundColor: Colors.blue.shade900,
      backgroundColor: Colors.white,
      title: Text("CURRENT LOCATION",style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
      
    
     ),
    );
  }
}