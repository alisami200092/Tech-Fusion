import 'package:flutter/material.dart';
import 'two_factor_auth_page.dart';
import 'change_password_page.dart'; // Make sure this matches your file name!

class SecurityPrivacyPage extends StatelessWidget {
  const SecurityPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Premium modern backdrop
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Security & Privacy",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. LOGIN & SECURITY CARD
            // ==========================================
            _buildSectionHeader("Login & Security"),
            _buildSettingsCard([
              _buildSettingsTile(
                title: "Change Password",
                icon: Icons.password_outlined,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChangePasswordPage())),
              ),
              const Divider(height: 1, indent: 48),
              _buildSettingsTile(
                title: "Two-Factor Authentication",
                icon: Icons.security_outlined,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TwoFactorAuthPage())),
              ),
              const Divider(height: 1, indent: 48),
              _buildSettingsTile(
                title: "Manage Devices",
                icon: Icons.devices_other_outlined,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManageDevicesPage())),
              ),
              const Divider(height: 1, indent: 48),
              _buildSettingsTile(
                title: "Account Activity",
                icon: Icons.history_outlined,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AccountActivityPage())),
              ),
            ]),
            const SizedBox(height: 32),

            // ==========================================
            // 2. DATA & PRIVACY CARD
            // ==========================================
            _buildSectionHeader("Data & Privacy"),
            _buildSettingsCard([
              _buildSettingsTile(
                title: "Privacy Settings",
                icon: Icons.privacy_tip_outlined,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PrivacySettingsPage())),
              ),
              const Divider(height: 1, indent: 48),
              _buildSettingsTile(
                title: "Data Sharing",
                icon: Icons.share_outlined,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DataSharingPage())),
              ),
              const Divider(height: 1, indent: 48),
              _buildSettingsTile(
                title: "Ad Personalization",
                icon: Icons.ads_click_outlined,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdPersonalizationPage())),
              ),
              const Divider(height: 1, indent: 48),
              _buildSettingsTile(
                title: "Cookie Preferences",
                icon: Icons.cookie_outlined,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CookiePreferencesPage())),
              ),
            ]),
            const SizedBox(height: 32),

            // ==========================================
            // 3. DANGER ZONE CARD
            // ==========================================
            _buildSectionHeader("Account Management"),
            _buildSettingsCard([
              _buildSettingsTile(
                title: "Data Access & Deletion",
                icon: Icons.delete_outline,
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DataAccessDeletionPage())),
              ),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER WIDGETS ---

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
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile(
      {required String title,
      required IconData icon,
      required VoidCallback onTap,
      Color iconColor = const Color(0xFF000033),
      Color textColor = Colors.black87}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: iconColor.withValues(alpha: 0.06),
        child: Icon(icon, size: 20, color: iconColor),
      ),
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 15, color: textColor)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black38),
      onTap: onTap,
    );
  }
}

// ---------------------------------
// Privacy & Security Placeholders
// ---------------------------------

class DataAccessDeletionPage extends StatelessWidget {
  const DataAccessDeletionPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text("Data Access & Deletion",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      body: const Center(
          child: Text("Data Access and Deletion Options",
              style: TextStyle(color: Colors.grey))),
    );
  }
}

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text("Privacy Settings",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      body: const Center(
          child: Text("Privacy Settings Options",
              style: TextStyle(color: Colors.grey))),
    );
  }
}

class AdPersonalizationPage extends StatelessWidget {
  const AdPersonalizationPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text("Ad Personalization",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      body: const Center(
          child: Text("Ad Personalization Options",
              style: TextStyle(color: Colors.grey))),
    );
  }
}

class DataSharingPage extends StatelessWidget {
  const DataSharingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text("Data Sharing",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      body: const Center(
          child: Text("Data Sharing Options",
              style: TextStyle(color: Colors.grey))),
    );
  }
}

class CookiePreferencesPage extends StatelessWidget {
  const CookiePreferencesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text("Cookie Preferences",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      body: const Center(
          child: Text("Cookie Preferences Options",
              style: TextStyle(color: Colors.grey))),
    );
  }
}

class AccountActivityPage extends StatelessWidget {
  const AccountActivityPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text("Account Activity",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      body: const Center(
          child: Text("Account Activity Options Placeholder",
              style: TextStyle(color: Colors.grey))),
    );
  }
}

class ManageDevicesPage extends StatelessWidget {
  const ManageDevicesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text("Manage Devices",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      body: const Center(
          child: Text("Manage Devices Options Placeholder",
              style: TextStyle(color: Colors.grey))),
    );
  }
}
