import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import 'edit_profile_page.dart';
import 'security_privacy_page.dart'; // ChangePasswordPage now safely lives inside here!

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';
  XFile? _profileImage;
  double _profileProgress = 0.0;

  // Notification Preferences State
  bool _pushNotifications = false;
  bool _promotions = false;
  bool _appUpdates = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFullUserData();
  }

  // Fetches Auth and Firestore synchronously to update the profile progress bar live!
  Future<void> _loadFullUserData() async {
    setState(() => _isLoading = true);
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        _email = user.email ?? '';
        if (user.photoURL != null) {
          _profileImage = XFile(user.photoURL!);
        }

        // Fetch remaining metadata (like phone) directly from user db snapshot
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>?;
          if (data != null) {
            _firstName = data['firstName'] ?? '';
            _lastName = data['lastName'] ?? '';
            _phone = data['phone'] ?? '';

            // Fetch saved notification configurations if they exist
            _pushNotifications = data['pushNotifications'] ?? false;
            _promotions = data['promotionalEmails'] ?? false;
            _appUpdates = data['appUpdates'] ?? false;
          }
        }
        _calculateProfileCompletion();
      }
    } catch (e) {
      _logger.e("Error fetching user setup: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _calculateProfileCompletion() {
    int total = 4;
    int filled = 0;
    if (_firstName.trim().isNotEmpty) filled++;
    if (_lastName.trim().isNotEmpty) filled++;
    if (_email.trim().isNotEmpty) filled++;
    if (_phone.trim().isNotEmpty) filled++;
    setState(() {
      _profileProgress = filled / total;
    });
  }

  ImageProvider<Object> _getImageProvider() {
    if (_profileImage != null) return FileImage(File(_profileImage!.path));
    return const AssetImage("images/placeholder.png");
  }

  Future<String?> _saveProfileImageLocally(XFile image) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String newPath = '${directory.path}/profile_image.png';
      final File localImage = await File(image.path).copy(newPath);
      return localImage.path;
    } catch (e) {
      _logger.e("Error saving image locally: $e");
      return null;
    }
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 150,
          maxHeight: 150,
          imageQuality: 30);
      if (image != null) {
        String? localPath = await _saveProfileImageLocally(image);
        if (localPath != null) {
          User? user = _auth.currentUser;
          if (user != null) {
            await user.updatePhotoURL(localPath);
            await _firestore
                .collection("users")
                .doc(user.uid)
                .update({"photoURL": localPath});
            setState(() => _profileImage = image);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile picture updated!")));
          }
        }
      }
    } catch (e) {
      _logger.e("Error picking image: $e");
    }
  }

  // Updates specific toggles instantly to the database—no clunky manual save button needed!
  Future<void> _updateNotificationPreference(String field, bool value) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection("users")
            .doc(user.uid)
            .update({field: value});
      } catch (e) {
        _logger.e("Failed to drop sync settings: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Premium modern backdrop contrast
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Settings",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF000033)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==========================================
                  // 1. HEADER PROFILE CARD
                  // ==========================================
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickProfileImage,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleBorderAvatar(
                                  imageProvider: _getImageProvider()),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                    color: Color(0xFF000033),
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.camera_alt_outlined,
                                    size: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _firstName.isNotEmpty
                              ? "$_firstName $_lastName"
                              : "TechFusion User",
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF000033)),
                        ),
                        const SizedBox(height: 4),
                        Text(_email,
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildProfileProgressIndicator(),
                  const SizedBox(height: 32),

                  // ==========================================
                  // 2. ACCOUNT & SECURITY CARD BLOCK
                  // ==========================================
                  _buildSectionHeader("Account & Security"),
                  _buildSettingsCard([
                    _buildSettingsTile(
                      title: "Edit Personal Details",
                      icon: Icons.person_outline,
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const EditProfilePage()));
                        _loadFullUserData(); // Hot reload fields on back navigation
                      },
                    ),
                    const Divider(height: 1, indent: 48),
                    _buildSettingsTile(
                      title: "Security & Privacy",
                      subtitle: "Password, Two-Factor Authentication",
                      icon: Icons.security_outlined,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const SecurityPrivacyPage())),
                    ),
                  ]),
                  const SizedBox(height: 28),

                  // ==========================================
                  // 3. PREFERENCES CARD BLOCK (AUTO SAVING)
                  // ==========================================
                  _buildSectionHeader("Preferences"),
                  _buildSettingsCard([
                    _buildNotificationToggle(
                      title: "Push Notifications",
                      value: _pushNotifications,
                      onChanged: (val) {
                        setState(() => _pushNotifications = val);
                        _updateNotificationPreference('pushNotifications', val);
                      },
                    ),
                    const Divider(height: 1, indent: 16),
                    _buildNotificationToggle(
                      title: "Promotional Emails",
                      value: _promotions,
                      onChanged: (val) {
                        setState(() => _promotions = val);
                        _updateNotificationPreference('promotionalEmails', val);
                      },
                    ),
                    const Divider(height: 1, indent: 16),
                    _buildNotificationToggle(
                      title: "App Updates Notifications",
                      value: _appUpdates,
                      onChanged: (val) {
                        setState(() => _appUpdates = val);
                        _updateNotificationPreference('appUpdates', val);
                      },
                    ),
                  ]),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(title,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5)),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildProfileProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF000033).withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Profile Verification Status",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000033),
                      fontSize: 13)),
              Text("${(_profileProgress * 100).toInt()}%",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000033),
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _profileProgress,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF000033)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
      {required String title,
      String? subtitle,
      required IconData icon,
      required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: const Color(0xFF000033).withValues(alpha: 0.06),
        child: Icon(icon, size: 20, color: const Color(0xFF000033)),
      ),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black87)),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey))
          : null,
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black38),
      onTap: onTap,
    );
  }

  Widget _buildNotificationToggle(
      {required String title,
      required bool value,
      required ValueChanged<bool> onChanged}) {
    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: Colors.black87)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: const Color(0xFF000033),
    );
  }
}

// Custom clean avatar wrapper to eliminate boilerplate styling code
class CircleBorderAvatar extends StatelessWidget {
  final ImageProvider imageProvider;
  const CircleBorderAvatar({required this.imageProvider, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ]),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white,
        backgroundImage: imageProvider,
      ),
    );
  }
}
