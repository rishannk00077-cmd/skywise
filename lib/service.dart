import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skywise/navigation.dart';

Future<void> register(String name,String Email,String Password,String ConfirmPassword,BuildContext context)async{
try{
  UserCredential userCredential=await FirebaseAuth.instance.createUserWithEmailAndPassword(email: Email, password: Password);
  await FirebaseFirestore.instance.collection("users").doc(userCredential.user!.uid).set({"NAME":name,"EMAIL":Email});
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User Created Successfully")));

}catch(e){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
}
}
Future<void> login(String Email,String Password,BuildContext context)async{
  try{
await FirebaseAuth.instance.signInWithEmailAndPassword(email: Email, password: Password);
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User login Successfully")));
Navigator.push(context, MaterialPageRoute(builder: (context) => BottomNav(),));


  }catch(e){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));

  }
}
Future<void> forgotpassword(String Email,BuildContext context)async{
  try{
await FirebaseAuth.instance.sendPasswordResetEmail(email: Email);
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mail Send successfully")));
  }catch(e){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
  }
}