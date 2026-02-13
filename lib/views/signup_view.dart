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
                const Icon(Icons.person_add_outlined,
                    size: 70, color: Color(0xFF1E3A8A)),
                const SizedBox(height: 10),
                const Text(
                  "Create Account",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E3A8A)),
                ),
                const Text(
                  "Join Skywise for smart weather insights",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                _buildTextField(
                    namec, "Full Name", Icons.person_outline, false),
                const SizedBox(height: 15),
                _buildTextField(
                    emailc, "Email Address", Icons.email_outlined, false),
                const SizedBox(height: 15),
                _buildTextField(
                    passwordc, "Password", Icons.lock_outline, true),
                const SizedBox(height: 15),
                _buildTextField(confirmPasswordc, "Confirm Password",
                    Icons.lock_reset_outlined, true),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (passwordc.text == confirmPasswordc.text) {
                        _controller.register(
                            namec.text, emailc.text, passwordc.text, context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Passwords do not match")));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    child: const Text("Register",
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
                    const Text("Already have an account? ",
                        style: TextStyle(color: Colors.grey)),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login())),
                      child: const Text("Sign In",
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
