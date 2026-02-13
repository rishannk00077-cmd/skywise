import 'package:flutter/material.dart';
import 'package:skywise/views/forgot_password_view.dart';
import 'package:skywise/controllers/auth_controller.dart';
import 'package:skywise/views/signup_view.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthController _controller = AuthController();
  final TextEditingController emailc = TextEditingController();
  final TextEditingController passwordc = TextEditingController();
  bool visible = true;

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_queue_rounded,
                    size: 80, color: Color(0xFF1E3A8A)),
                const SizedBox(height: 10),
                const Text(
                  "Skywise",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E3A8A)),
                ),
                const Text(
                  "Smart Weather & AI Advisor",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 50),
                _buildTextField(
                    emailc, "Email Address", Icons.email_outlined, false),
                const SizedBox(height: 20),
                _buildTextField(
                    passwordc, "Password", Icons.lock_outline, true),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Forgotpassword())),
                    child: const Text("Forgot Password?",
                        style: TextStyle(
                            color: Color(0xFF3B82F6),
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () =>
                        _controller.login(emailc.text, passwordc.text, context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    child: const Text("Sign In",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ",
                        style: TextStyle(color: Colors.grey)),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Signup())),
                      child: const Text("Sign Up",
                          style: TextStyle(
                              color: Color(0xFF1E3A8A),
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, bool isPassword) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? visible : false,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.blueGrey, fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF1E3A8A)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(visible ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey),
                  onPressed: () => setState(() => visible = !visible),
                )
              : null,
        ),
      ),
    );
  }
}
