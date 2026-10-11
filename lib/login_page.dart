import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import 'authentication/auth_service.dart';
import 'authentication/google_auth.dart';
import 'authentication/facebook_flutter_auth.dart';
import 'forgot_password_page.dart';
import 'profile_page_settings/profile_settings_page.dart';

var logger = Logger();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  User? _user;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    logger.d('Attempting sign-in with email: $email');
    try {
      User? user = await AuthService().signInWithEmailPassword(email, password);

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        String role = userDoc.exists ? userDoc['role'] : 'user';

        // 1. Check if widget is still alive before updating state or navigating
        if (!mounted) return;

        setState(() {
          _user = user;
        });

        Navigator.pushReplacementNamed(
          context,
          role == 'admin' ? '/adminPanel' : '/main',
          arguments: {
            'firstName': user.displayName?.split(' ').first ?? '',
            'lastName': user.displayName?.split(' ').last ?? '',
          },
        );
      } else {
        logger.w("Login failed. Please check your email and password.");

        // 2. Safely show SnackBar using mounted check
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Login failed. Please check your email and password.'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      logger.e("An error occurred during sign-in: $e");

      // 3. Safely show SnackBar using mounted check
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error signing in: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      bool success = await GoogleAuthService.signInWithGoogle(context);

      if (!mounted) return; // Check if still alive after async

      if (success) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String firstName = user.displayName?.split(' ').first ?? '';
          String lastName = user.displayName?.split(' ').last ?? '';

          setState(() => _user = user);

          Navigator.pushReplacementNamed(
            context,
            '/main',
            arguments: {'firstName': firstName, 'lastName': lastName},
          );
        }
      }
    } catch (e) {
      logger.e('Error signing in with Google: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('An error occurred during Google sign-in.'),
          backgroundColor: Colors.red));
    }
  }

  Future<void> _signInWithFacebook() async {
    try {
      UserCredential? userCredential =
          await FacebookAuthService.signInWithFacebook(context);

      if (!mounted) return; // Check if still alive after async

      if (userCredential != null) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String firstName = user.displayName?.split(' ').first ?? '';
          String lastName = user.displayName?.split(' ').last ?? '';

          setState(() => _user = user);

          Navigator.pushReplacementNamed(
            context,
            '/main',
            arguments: {'firstName': firstName, 'lastName': lastName},
          );
        }
      }
    } catch (e) {
      logger.e('Error signing in with Facebook: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('An error occurred during Facebook sign-in.'),
          backgroundColor: Colors.red));
    }
  }

  Future<void> _logout() async {
    await AuthService().signOut(context);
    if (!mounted) return;
    setState(() => _user = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 40.0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('images/techfusion-logo-text.png',
                  height: 120.0, fit: BoxFit.contain),
              const SizedBox(height: 16.0),
              if (_user == null) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Welcome Back',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF000033))),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Sign in to continue',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                    fillColor: Colors.grey.shade100,
                    prefixIcon:
                        const Icon(Icons.email_outlined, color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                    fillColor: Colors.grey.shade100,
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage())),
                    child: const Text('Forgot Password?',
                        style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF000033),
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000033),
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      elevation: 0,
                    ),
                    onPressed: _signIn,
                    child: const Text('SIGN IN',
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                        child:
                            Divider(color: Colors.grey.shade300, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('OR',
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                        child:
                            Divider(color: Colors.grey.shade300, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ),
                    icon: Image.asset('images/gmail.png', height: 20.0),
                    label: const Text('Continue with Google',
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    onPressed: _signInWithGoogle,
                  ),
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1877F2),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ),
                    icon: Image.asset('images/fb-logo.png', height: 20.0),
                    label: const Text('Continue with Facebook',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    onPressed: _signInWithFacebook,
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('New to Techfusion?',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600)),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        minimumSize: const Size(0, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Sign Up',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF000033))),
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ] else ...[
                CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFF000033),
                  child: Text(
                    _user!.displayName != null && _user!.displayName!.isNotEmpty
                        ? '${_user!.displayName![0]}${_user!.displayName!.split(' ').last[0]}'
                        : 'U',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF000033),
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0))),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfileSettingsPage())),
                    child: const Text('Profile Settings',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _logout,
                  child: const Text('Logout',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
