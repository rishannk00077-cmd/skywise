import 'package:flutter/material.dart';
import 'package:skywise/views/forgot_password_view.dart';
import 'package:skywise/controllers/auth_controller.dart';
import 'package:skywise/views/signup_view.dart';
import 'dart:ui';

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
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
              ),
            ),
          ),

          // Decoration Orbs
          Positioned(
              top: -100,
              left: -50,
              child: _buildOrb(200, Colors.blueAccent.withOpacity(0.05))),
          Positioned(
              bottom: -50,
              right: -50,
              child: _buildOrb(250, Colors.blueAccent.withOpacity(0.08))),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.1),
                              blurRadius: 40,
                              spreadRadius: 10)
                        ],
                      ),
                      child: const Icon(Icons.cloud_sync_rounded,
                          size: 64, color: Color(0xFF0F62FE)),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                          letterSpacing: -1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Sign in to your Skywise account",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.blueGrey[400],
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 48),
                    _buildTextField(
                        emailc, "Email Address", Icons.email_outlined, false),
                    const SizedBox(height: 20),
                    _buildTextField(passwordc, "Password",
                        Icons.lock_outline_rounded, true),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Forgotpassword())),
                        child: const Text("Forgot Password?",
                            style: TextStyle(
                                color: Color(0xFF0F62FE),
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() => _isLoading = true);
                                await _controller.login(
                                    emailc.text, passwordc.text, context);
                                if (mounted) setState(() => _isLoading = false);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F62FE),
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: const Color(0xFF0F62FE).withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text("Sign In",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5)),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("New to Skywise? ",
                            style: TextStyle(
                                color: Colors.blueGrey[600],
                                fontWeight: FontWeight.w500)),
                        GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Signup())),
                          child: const Text("Create Account",
                              style: TextStyle(
                                  color: Color(0xFF0F62FE),
                                  fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, bool isPassword) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? visible : false,
        style: const TextStyle(
            fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Colors.blueGrey[300],
              fontSize: 14,
              fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: const Color(0xFF0F62FE), size: 22),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      visible
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: Colors.blueGrey[200]),
                  onPressed: () => setState(() => visible = !visible),
                )
              : null,
        ),
      ),
    );
  }
}
