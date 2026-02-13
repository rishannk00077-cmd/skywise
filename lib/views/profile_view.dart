import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skywise/controllers/profile_controller.dart';
import 'package:skywise/providers/theme_provider.dart';
import 'package:skywise/views/login_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
      appBar: AppBar(
        title: const Text("Account"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(isDark),
            const SizedBox(height: 40),
            _buildSectionHeader("Account Settings"),
            _buildProfileTile(Icons.person_outline, "Edit Profile",
                "Change your name or bio", isDark),
            _buildProfileTile(Icons.notifications_none, "Notifications",
                "Weather alerts & advice", isDark),
            _buildProfileTile(
                Icons.lock_outline, "Privacy", "Manage your data", isDark),
            const SizedBox(height: 20),
            _buildSectionHeader("Appearance"),
            _buildThemeToggle(themeProvider, isDark),
            const SizedBox(height: 20),
            _buildSectionHeader("App Information"),
            _buildProfileTile(
                Icons.info_outline, "About Skywise", "v1.0.0 Stable", isDark),
            _buildProfileTile(
                Icons.help_outline, "Help Center", "FAQs and support", isDark),
            const SizedBox(height: 40),
            _buildLogoutButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    final primaryColor = Theme.of(context).primaryColor;
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            GestureDetector(
              onTap: _isUploading ? null : _handleImageUpload,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration:
                    BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor:
                      isDark ? Colors.grey[800] : const Color(0xFFF0F5FA),
                  backgroundImage: _profileImageUrl != null
                      ? CachedNetworkImageProvider(_profileImageUrl!)
                      : null,
                  child: _profileImageUrl == null
                      ? Icon(Icons.person, size: 70, color: primaryColor)
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
                  child: const Icon(Icons.edit, color: Colors.white, size: 18),
                ),
              ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          _userName,
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E3A8A)),
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

  Widget _buildThemeToggle(ThemeProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: isDark ? Colors.white10 : const Color(0xFFF0F5FA),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(isDark ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).primaryColor),
        ),
        title: const Text("Dark Mode",
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Switch between light and dark themes",
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: Switch(
          value: isDark,
          onChanged: (value) => provider.toggleTheme(),
          activeColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildProfileTile(
      IconData icon, String title, String subtitle, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: isDark ? Colors.white10 : const Color(0xFFF0F5FA),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
