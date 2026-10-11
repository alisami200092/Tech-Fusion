import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
f

class TwoFactorAuthPage extends StatefulWidget {
  const TwoFactorAuthPage({super.key});

  @override
  State<TwoFactorAuthPage> createState() => _TwoFactorAuthPageState();
}

class _TwoFactorAuthPageState extends State<TwoFactorAuthPage> {
  final LocalAuthentication auth = LocalAuthentication();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isBiometricAuthenticated = false;
  bool _isEmailVerified = false;
  bool _isLoading = true;
  String? _userId;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadcurrentUserAndStatus();
  }

  /// Load current user information and retrieve their 2FA settings from Firestore
  Future<void> _loadcurrentUserAndStatus() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _userId = user.uid;
      _userEmail = user.email;

      try {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(_userId)
            .collection('security_settings')
            .doc('mfa')
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _isEmailVerified = data['emailMfaEnabled'] ?? false;
            _isBiometricAuthenticated = data['biometricsMfaEnabled'] ?? false;
          });
        }
      } catch (e) {
        _showSnackBar("Error loading settings: $e", Colors.red);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  String _generate6DigitCode() {
    Random rand = Random();
    return List.generate(6, (index) => rand.nextInt(10).toString()).join();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  /// Sends the 6-digit OTP: Stores it in Firestore and creates an email trigger document
  Future<bool> _sendOTP() async {
    if (_userId == null || _userEmail == null) return false;

    String code = _generate6DigitCode();
    DateTime expiresAt = DateTime.now().add(const Duration(minutes: 5));

    try {
      // 1. Store the OTP securely in the user's private security subcollection
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('security_settings')
          .doc('email_otp')
          .set({
        'code': code,
        'expiresAt': Timestamp.fromDate(expiresAt),
      });

      // 2. Write a document to 'mail' collection to trigger Firebase Email Extension
      await _firestore.collection('mail').add({
        'to': _userEmail,
        'message': {
          'subject': 'Your 2FA Verification Code',
          'text': 'Your verification code is $code. It expires in 5 minutes.',
          'html':
              '<h3>Your verification code is <b>$code</b>.</h3><p>It expires in 5 minutes.</p>',
        }
      });
      return true;
    } catch (e) {
      _showSnackBar("Failed to send code: $e", Colors.red);
      return false;
    }
  }

  Future<void> _handleEmailVerification() async {
    if (_userId == null) return;

    setState(() => _isLoading = true);
    bool sent = await _sendOTP();
    setState(() => _isLoading = false);

    if (!sent) return;

    int remainingSeconds = 300; // 5 minutes validity
    Timer? timer;
    TextEditingController codeController = TextEditingController();

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              setStateDialog(() {
                if (remainingSeconds > 0) {
                  remainingSeconds--;
                } else {
                  t.cancel();
                }
              });
            });
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text("Email Verification",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF000033))),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "A 6-digit verification code has been sent to $_userEmail.",
                        style: TextStyle(color: Colors.grey.shade700)),
                    const SizedBox(height: 16),
                    Text("Time Remaining: ${_formatTime(remainingSeconds)}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: codeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: "Enter 6-digit Code",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    timer?.cancel();
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                if (remainingSeconds == 0)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000033),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      bool success = await _sendOTP();
                      if (success) {
                        setStateDialog(() {
                          remainingSeconds = 300;
                          timer?.cancel();
                          timer =
                              Timer.periodic(const Duration(seconds: 1), (t) {
                            setStateDialog(() {
                              if (remainingSeconds > 0) {
                                remainingSeconds--;
                              } else {
                                t.cancel();
                              }
                            });
                          });
                        });
                      }
                    },
                    child: const Text("Request New Code",
                        style: TextStyle(color: Colors.white)),
                  )
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000033),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      await _verifyEmailCode(
                          codeController.text.trim(), timer, context);
                    },
                    child: const Text("Verify",
                        style: TextStyle(color: Colors.white)),
                  ),
              ],
            );
          },
        );
      },
    );
    timer?.cancel();
  }

  /// Verifies user input against the OTP document in Firestore
  Future<void> _verifyEmailCode(
      String enteredCode, Timer? timer, BuildContext dialogContext) async {
    if (_userId == null) return;

    try {
      DocumentSnapshot otpDoc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('security_settings')
          .doc('email_otp')
          .get();

      if (!otpDoc.exists) {
        _showSnackBar("No active verification session found.", Colors.red);
        return;
      }

      final data = otpDoc.data() as Map<String, dynamic>;
      String actualCode = data['code'];
      Timestamp expiresAt = data['expiresAt'];

      if (DateTime.now().isAfter(expiresAt.toDate())) {
        _showSnackBar(
            "Code has expired. Please request a new one.", Colors.red);
        return;
      }

      if (enteredCode == actualCode) {
        // Update user's enrollment status in Firestore
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('security_settings')
            .doc('mfa')
            .set({'emailMfaEnabled': true}, SetOptions(merge: true));

        setState(() {
          _isEmailVerified = true;
        });

        timer?.cancel();
        if (dialogContext.mounted) Navigator.pop(dialogContext);
        _showSnackBar("Email 2FA Activated Successfully", Colors.green);
      } else {
        _showSnackBar("Incorrect code. Please try again.", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Verification error: $e", Colors.red);
    }
  }

  /// Registers and verifies Biometric Auth
  Future<void> _handleBiometricAuth() async {
    if (_userId == null) {
      _showSnackBar("User session not found.", Colors.red);
      return;
    }

    try {
      bool hasBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();

      if (!hasBiometrics && !isDeviceSupported) {
        _showSnackBar("Biometrics not available on this device", Colors.orange);
        return;
      }

      bool authenticated = await auth.authenticate(
        localizedReason: 'Enable biometric login for extra security',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!mounted) return;

      if (authenticated) {
        // Store a persistent flag on device to mark biometric setup
        await _secureStorage.write(key: 'biometric_enabled', value: 'true');

        // Update Firestore security status
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('security_settings')
            .doc('mfa')
            .set({'biometricsMfaEnabled': true}, SetOptions(merge: true));

        setState(() {
          _isBiometricAuthenticated = true;
        });
        _showSnackBar("Biometrics Activated Successfully", Colors.green);
      }
    } on PlatformException catch (e) {
      _showSnackBar("Biometric error: ${e.message}", Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  Widget _buildCustomListTile(String title, VoidCallback onTap,
      {bool isVerified = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: isVerified ? Colors.green : Colors.grey.shade200),
      ),
      child: ListTile(
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isVerified ? Colors.green : Colors.black)),
        trailing: isVerified
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Two-Factor Authentication",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.security_outlined,
                      size: 64, color: Color(0xFF000033)),
                  const SizedBox(height: 16),
                  const Text(
                    "Secure Your Account",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000033)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Choose a Two-Factor Authentication method to guard access to your data.",
                    style: TextStyle(
                        fontSize: 16, color: Colors.grey.shade600, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  _buildCustomListTile(
                      "Email Verification", _handleEmailVerification,
                      isVerified: _isEmailVerified),
                  if (!kIsWeb)
                    _buildCustomListTile(
                        "Biometric Authentication", _handleBiometricAuth,
                        isVerified: _isBiometricAuthenticated),
                ],
              ),
            ),
    );
  }
}
