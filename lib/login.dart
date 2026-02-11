import 'package:flutter/material.dart';
import 'package:skywise/forgotpassword.dart';
import 'package:skywise/service.dart';
import 'package:skywise/signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
   TextEditingController emailc=TextEditingController();
  TextEditingController passwordc=TextEditingController();
  bool rememberMe = true;
  bool visible = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/login.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 120,right: 120),
            child: Column(
              children: [
                SizedBox(height: 10),

    /// LOGO
   
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                     Image.asset(
      "assets/logo.png",
      height: 60,
      
    ),
                    Text(
                      "Skywise",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ],
                ),
                Text(
                  "Smart Weather & AI lifestyle Advisor",
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Log in to your account",
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 225,
                  width: 300,
                  child: Column(
                    children: [
                      SizedBox(height: 5),
                      SizedBox(
                        width: 290,
                        child: TextField(
                          controller: emailc,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            labelText: "Email",
                             hintText: "Enter your Email", 
                                      hintStyle: TextStyle(color: const Color.fromARGB(255, 114, 139, 152),fontSize: 12),
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            filled: true,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            labelStyle: TextStyle(
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      SizedBox(
                        width: 290,
                        child: TextField(
                          controller: passwordc,
                          obscureText: visible,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(onPressed: () {
                    setState(() {
                      visible =!visible;
                    });
                  }, icon: visible? Icon(Icons.visibility_off) : Icon(Icons.visibility)) ,
                            prefixIcon: Icon(Icons.lock),
                            hintText: "Enter your password", 
                                      hintStyle: TextStyle(color: const Color.fromARGB(255, 114, 139, 152),fontSize: 12),
                             labelText: "Password",
                          
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            filled: true,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            labelStyle: TextStyle(
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                      ),
                      Align(alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Forgotpassword(),));
                  },
                  child: Text("Forgot Password?",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 12),)),
              ),
                      SizedBox(height: 20,),
                      SizedBox(
                      height: 50,
                      width: 290,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(10),
                          ),
                        ),
                        onPressed: () {login(emailc.text, passwordc.text, context);},
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    ],
                  ),
                ),
               

Row(
  children: [

    /// LEFT DIVIDER
    Expanded(
      child: Divider(
        color: Colors.white70,
        thickness: 1,
      ),
    ),

    /// CHECKBOX + TEXT
    Row(
      children: [
        Checkbox(
          value: rememberMe,
          activeColor: Colors.blue,
          onChanged: (value) {
            setState(() {
              rememberMe = value!;
            });
          },
        ),
        Text(
          "Remember Me",
          style: TextStyle(color: Colors.lightBlue),
        ),
      ],
    ),

    /// RIGHT DIVIDER
    Expanded(
      child: Divider(
        color: Colors.white70,
        thickness: 1,
      ),
    ),

  ],
),

              
                
                SizedBox(height: 45,),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Signup(),));
                    },
                    child: Text("Signup",style: TextStyle(fontWeight: FontWeight.bold),))
                ],
                
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
