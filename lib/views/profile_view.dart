import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skywise/controllers/profile_controller.dart';
import 'package:skywise/providers/theme_provider.dart';
import 'package:skywise/views/login_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ProfileController _controller = ProfileController();

  String _userName = "User Name";
  String _userEmail = "user@example.com";
  String? _profileImageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await _controller.fetchUserData();
    if (data != null && mounted) {
      setState(() {
        _userName = data['NAME'] ?? "User";
        _userEmail = data['EMAIL'] ?? _controller.currentUser?.email ?? "";
        _profileImageUrl = data['PROFILE_IMAGE'];
      });
    }
  }

  Future<void> _handleImageUpload() async {
    setState(() => _isUploading = true);
    final url = await _controller.pickAndUploadImage();
    if (mounted) {
      if (url != null) {
        setState(() {
          _profileImageUrl = url;
          _isUploading = false;
        });
      } else {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to upload image")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Account",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Gradient matching app theme
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                    : [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileHeader(isDark),
                  const SizedBox(height: 40),
                  _buildGlassSection([
                    _buildSectionHeader("Account Settings"),
                    _buildProfileTile(Icons.person_outline, "Edit Profile",
                        "Change your name or bio", isDark),
                    _buildProfileTile(Icons.notifications_none, "Notifications",
                        "Weather alerts & advice", isDark),
                    _buildProfileTile(Icons.lock_outline, "Privacy",
                        "Manage your data", isDark),
                  ]),
                  const SizedBox(height: 20),
                  _buildGlassSection([
                    _buildSectionHeader("Appearance"),
                    _buildThemeToggle(themeProvider, isDark),
                  ]),
                  const SizedBox(height: 20),
                  _buildGlassSection([
                    _buildSectionHeader("App Information"),
                    _buildProfileTile(Icons.info_outline, "About Skywise",
                        "v1.0.0 Stable", isDark),
                    _buildProfileTile(Icons.help_outline, "Help Center",
                        "FAQs and support", isDark),
                  ]),
                  const SizedBox(height: 40),
                  _buildLogoutButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassSection(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(children: children),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            GestureDetector(
              onTap: _isUploading ? null : _handleImageUpload,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Colors.white24, shape: BoxShape.circle),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white10,
                  backgroundImage: _profileImageUrl != null
                      ? CachedNetworkImageProvider(_profileImageUrl!)
                      : null,
                  child: _profileImageUrl == null
                      ? const Icon(Icons.person, size: 70, color: Colors.white)
                      : null,
                ),
              ),
            ),
            if (_isUploading)
              const Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else
              GestureDetector(
                onTap: _handleImageUpload,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6), shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          _userName,
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5),
        ),
        Text(
          _userEmail,
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),
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
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.4),
              letterSpacing: 1.5),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(ThemeProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(isDark ? Icons.dark_mode : Icons.light_mode,
              color: Colors.white),
        ),
        title: const Text("Dark Mode",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text("Switch between themes",
            style:
                TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
        trailing: Switch(
          value: isDark,
          onChanged: (value) => provider.toggleTheme(),
          activeColor: const Color(0xFF3B82F6),
        ),
      ),
    );
  }

  Widget _buildProfileTile(
      IconData icon, String title, String subtitle, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(subtitle,
            style:
                TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
        trailing: Icon(Icons.arrow_forward_ios,
            color: Colors.white.withOpacity(0.2), size: 14),
        onTap: () {},
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
            ),
            child: TextButton(
              onPressed: () async {
                await _controller.signOut();
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
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, size: 20),
                  SizedBox(width: 10),
                  Text("Logout Session",
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
