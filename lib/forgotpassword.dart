import 'package:flutter/material.dart';
import 'package:skywise/login.dart';
import 'package:skywise/service.dart';


class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  TextEditingController emailc=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Colors.blue.shade400,
        Colors.blue.shade900,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  ),
  child: Center(
    child: Padding(
      padding: const EdgeInsets.only(left: 100,right: 100),
      child: Container(
        padding: EdgeInsets.only(left: 20,right: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
      SizedBox(height: 25,),
            /// ICON HEADER
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              child: Icon(
                Icons.lock_reset,
                color: Colors.white,
                size: 35,
              ),
            ),
      
            SizedBox(height: 20),
      
            /// TITLE
            Text(
              "Forgot Password",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.white,
              ),
            ),
      
            SizedBox(height: 8),
      
            Text(
              "Enter your email to receive reset link",
              style: TextStyle(color: Colors.white70),
            ),
      
            SizedBox(height: 25),
      
            /// EMAIL FIELD
            TextField(
              controller: emailc,
              decoration: InputDecoration(
                hintText: "Enter your email",
                prefixIcon: Icon(Icons.email_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
      
            SizedBox(height: 25),
      
            /// SEND BUTTON
            SizedBox(
              height: 55,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  "Send Reset Link",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
      
            SizedBox(height: 15),
      
            /// BACK TO LOGIN
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              child: Text(
                "Back to Login",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),SizedBox(height: 25,)
          ],
        ),
      ),
    ),
  ),
),


    );
  }
}