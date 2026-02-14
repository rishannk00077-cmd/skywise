import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:skywise/controllers/profile_controller.dart';
import 'package:skywise/providers/theme_provider.dart';
import 'package:skywise/views/login_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ProfileController _controller = ProfileController();
  final ImagePicker _picker = ImagePicker();
  String _userName = "User Name";
  String _userEmail = "user@example.com";
  String? _profileImageUrl;
  bool _isUploading = false;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSearchHistory();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && mounted) {
          setState(() {
            _userName = snapshot.data()?['NAME'] ?? "User Name";
            _userEmail = user.email ?? "user@example.com";
            _profileImageUrl = snapshot.data()?['PROFILE_IMAGE'];
          });
        }
      });
    }
  }

  Future<void> _loadSearchHistory() async {
    final history = await _controller.fetchSearchHistory();
    if (mounted) {
      setState(() => _history = history);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _isUploading = true);
      String? imageUrl = await _controller.updateProfileImage(image.path);
      if (mounted) {
        setState(() {
          _profileImageUrl = imageUrl;
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _showEditProfileDialog() async {
    final nameController = TextEditingController(text: _userName);
    return showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Update Profile",
              style: TextStyle(fontWeight: FontWeight.w900)),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: "Display Name",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Discard")),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await _controller.updateUserName(nameController.text);
                  if (mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildBackground(isDark),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  _buildProfileHeader(isDark),
                  const SizedBox(height: 48),
                  _buildSection(
                      "Account Intelligence",
                      [
                        _buildSettingsTile(Icons.history_rounded,
                            "Search History", "Your recent lookups", isDark,
                            onTap: () => _showHistoryBottomSheet(isDark)),
                        _buildSettingsTile(Icons.person_outline_rounded,
                            "Edit Profile", "Change display name", isDark,
                            onTap: _showEditProfileDialog),
                      ],
                      isDark),
                  const SizedBox(height: 24),
                  _buildSection(
                      "Preferences",
                      [
                        _buildThemeToggle(themeProvider, isDark),
                        _buildSettingsTile(Icons.notifications_none_rounded,
                            "Notifications", "Alerts & updates", isDark),
                      ],
                      isDark),
                  const SizedBox(height: 24),
                  _buildSection(
                      "About",
                      [
                        _buildSettingsTile(Icons.info_outline_rounded,
                            "App Version", "v1.2.0 Professional", isDark),
                        _buildSettingsTile(Icons.help_outline_rounded,
                            "Legal & Privacy", "Terms of service", isDark),
                      ],
                      isDark),
                  const SizedBox(height: 48),
                  _buildLogoutButton(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent,
                    Colors.purpleAccent.withOpacity(0.5)
                  ],
                ),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor:
                    isDark ? const Color(0xFF1E293B) : Colors.white,
                child: _isUploading
                    ? const CircularProgressIndicator()
                    : ClipOval(
                        child: _profileImageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: _profileImageUrl!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                              )
                            : Icon(Icons.person_rounded,
                                size: 60,
                                color:
                                    isDark ? Colors.white24 : Colors.grey[300]),
                      ),
              ),
            ),
            GestureDetector(
              onTap: _pickAndUploadImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Colors.blueAccent, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          _userName,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          _userEmail,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white54 : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: isDark ? Colors.white24 : Colors.grey[400],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey[200]!),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
      IconData icon, String title, String subtitle, bool isDark,
      {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.blueAccent.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon,
            color: isDark ? Colors.white70 : Colors.blueAccent, size: 22),
      ),
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87)),
      subtitle: Text(subtitle,
          style: TextStyle(
              fontSize: 12, color: isDark ? Colors.white38 : Colors.grey[600])),
      trailing:
          const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
    );
  }

  Widget _buildThemeToggle(ThemeProvider themeProvider, bool isDark) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.amberAccent.withOpacity(0.1)
              : Colors.blueAccent.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
            color: isDark ? Colors.amberAccent : Colors.blueAccent, size: 22),
      ),
      title: Text("Dark Appearance",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87)),
      trailing: Switch.adaptive(
        value: isDark,
        onChanged: (_) => themeProvider.toggleTheme(),
        activeColor: Colors.blueAccent,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
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
        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
        label: const Text("Sign Out",
            style: TextStyle(
                color: Colors.redAccent, fontWeight: FontWeight.w900)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  void _showHistoryBottomSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text("Search History",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            ),
            Expanded(
              child: _history.isEmpty
                  ? const Center(child: Text("No history yet"))
                  : ListView.builder(
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final item = _history[index];
                        final date =
                            (item['timestamp'] as Timestamp?)?.toDate() ??
                                DateTime.now();
                        return ListTile(
                          leading: const Icon(Icons.location_on_outlined,
                              color: Colors.blueAccent),
                          title: Text(item['city'] ?? "Unknown",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle:
                              Text(DateFormat('MMM d, h:mm a').format(date)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
