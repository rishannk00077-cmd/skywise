import 'package:flutter/material.dart';
import 'package:skywise/login.dart';
import 'package:skywise/service.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController namec = TextEditingController();
  TextEditingController emailc = TextEditingController();
  TextEditingController passwordc = TextEditingController();
  TextEditingController ConfirmPasswordc = TextEditingController();
  bool visible = true;
  bool isvisible = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/register.png"),
            fit: BoxFit.fill,
          ),
        ),

        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 120, right: 120),
            child: Column(
              children: [
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/logo.png", height: 60),
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
                SizedBox(height: 20),
                Text(
                  "Create Your Account",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Sign up to personalized weather & AI advice",
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 350,
                  width: 300,
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      SizedBox(
                        width: 290,
                        child: TextField(
                          controller: namec,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            labelText: "Full Name",
                            hintText: "Enter your name",
                            hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 114, 139, 152),
                              fontSize: 12,
                            ),
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
                          controller: emailc,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            labelText: "Email",
                            hintText: "Enter your email",
                            hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 114, 139, 152),
                              fontSize: 12,
                            ),
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
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  visible = !visible;
                                });
                              },
                              icon: visible
                                  ? Icon(Icons.visibility_off)
                                  : Icon(Icons.visibility),
                            ),
                            prefixIcon: Icon(Icons.lock),
                            labelText: "Password",
                            hintText: "Enter your password",
                            hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 114, 139, 152),
                              fontSize: 12,
                            ),
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
                          controller: ConfirmPasswordc,
                          obscureText: isvisible,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isvisible = !isvisible;
                                });
                              },
                              icon: isvisible
                                  ? Icon(Icons.visibility_off)
                                  : Icon(Icons.visibility),
                            ),
                            prefixIcon: Icon(Icons.lock),
                            labelText: "Confirm Password",
                            hintText: "Enter your password",
                            hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 114, 139, 152),
                              fontSize: 12,
                            ),
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
                      SizedBox(height: 20),
                      SizedBox(
                        height: 50,
                        width: 290,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            register(
                              namec.text,
                              emailc.text,
                              passwordc.text,
                              ConfirmPasswordc.text,
                              context,
                            );
                          },
                          child: Text(
                            "Register",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already have an account?"),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Login(),
                                ),
                              );
                            },
                            child: Text(
                              "Login",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
