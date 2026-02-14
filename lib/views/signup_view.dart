import 'package:flutter/material.dart';
import 'package:skywise/views/login_view.dart';
import 'package:skywise/controllers/auth_controller.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final AuthController _controller = AuthController();
  final TextEditingController namec = TextEditingController();
  final TextEditingController emailc = TextEditingController();
  final TextEditingController passwordc = TextEditingController();
  final TextEditingController confirmPasswordc = TextEditingController();
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
              top: -80,
              right: -40,
              child: _buildOrb(220, Colors.blueAccent.withOpacity(0.06))),
          Positioned(
              bottom: -100,
              left: -60,
              child: _buildOrb(280, Colors.blueAccent.withOpacity(0.04))),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Create Account",
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                          letterSpacing: -1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Join Skywise for smart weather insights",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.blueGrey[400],
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 48),
                    _buildTextField(namec, "Full Name",
                        Icons.person_outline_rounded, false),
                    const SizedBox(height: 16),
                    _buildTextField(
                        emailc, "Email Address", Icons.email_outlined, false),
                    const SizedBox(height: 16),
                    _buildTextField(passwordc, "Password",
                        Icons.lock_outline_rounded, true),
                    const SizedBox(height: 16),
                    _buildTextField(confirmPasswordc, "Confirm Password",
                        Icons.lock_reset_rounded, true),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (passwordc.text == confirmPasswordc.text) {
                                  setState(() => _isLoading = true);
                                  await _controller.register(namec.text,
                                      emailc.text, passwordc.text, context);
                                  if (mounted)
                                    setState(() => _isLoading = false);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text("Passwords do not match"),
                                          behavior: SnackBarBehavior.floating));
                                }
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
                            : const Text("Create Account",
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
                        Text("Already a member? ",
                            style: TextStyle(
                                color: Colors.blueGrey[600],
                                fontWeight: FontWeight.w500)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text("Sign In",
                              style: TextStyle(
                                  color: Color(0xFF0F62FE),
                                  fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
