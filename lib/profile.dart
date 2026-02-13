import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skywise/login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String _userName = "User Name";
  String _userEmail = "user@example.com";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userName = doc['NAME'] ?? "User";
          _userEmail = doc['EMAIL'] ?? user.email;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text("Account",
            style: TextStyle(
                color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(),
            const SizedBox(height: 40),
            _buildSectionHeader("Account Settings"),
            _buildProfileTile(Icons.person_outline, "Edit Profile",
                "Change your name or bio"),
            _buildProfileTile(Icons.notifications_none, "Notifications",
                "Weather alerts & advice"),
            _buildProfileTile(
                Icons.lock_outline, "Privacy", "Manage your data"),
            const SizedBox(height: 20),
            _buildSectionHeader("App Information"),
            _buildProfileTile(
                Icons.info_outline, "About Skywise", "v1.0.0 Stable"),
            _buildProfileTile(
                Icons.help_outline, "Help Center", "FAQs and support"),
            const SizedBox(height: 40),
            _buildLogoutButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                  color: Color(0xFF1E3A8A), shape: BoxShape.circle),
              child: const CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFFF0F5FA),
                child: Icon(Icons.person, size: 70, color: Color(0xFF1E3A8A)),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6), shape: BoxShape.circle),
              child: const Icon(Icons.edit, color: Colors.white, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          _userName,
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A)),
        ),
        Text(
          _userEmail,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.blueGrey.shade200,
              letterSpacing: 1.5),
        ),
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: const Color(0xFFF0F5FA),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF1E3A8A)),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios,
            color: Colors.black12, size: 16),
        onTap: () {},
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextButton(
        onPressed: () async {
          await _auth.signOut();
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
              (route) => false,
            );
          }
        },
        style: TextButton.styleFrom(
          foregroundColor: Colors.redAccent,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout),
            SizedBox(width: 10),
            Text("Logout Session",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
