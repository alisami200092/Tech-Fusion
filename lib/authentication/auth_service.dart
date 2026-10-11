import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';

var logger = Logger();

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to sign up with email and password
  Future<User?> signUpWithEmailPassword(
      String email, String password, String firstName, String lastName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        await user.sendEmailVerification(); // Send verification email

        // Assign a default role
        String role = 'user';

        // If you have logic to assign admin role, implement it here
        List<String> adminEmails = [
          'cheetayfastdl345@gmail.com'
        ]; // Add admin emails here
        if (adminEmails.contains(email)) {
          role = 'admin';
        }

        // Save user data and role to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid, // Ensure UID is stored
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'role': role,
        });

        logger.d('User successfully registered: $email');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      logger
          .e('FirebaseAuthException in signUpWithEmailPassword: ${e.message}');
      switch (e.code) {
        case 'email-already-in-use':
          logger.w('The email address is already in use.');
          break;
        case 'invalid-email':
          logger.w('Invalid email format.');
          break;
        case 'operation-not-allowed':
          logger.w('Email/password accounts are not enabled.');
          break;
        case 'weak-password':
          logger.w('The password is too weak.');
          break;
        default:
          logger.e('Unexpected FirebaseAuthException: ${e.message}');
      }
      return null;
    } catch (e) {
      logger.e('Error in signUpWithEmailPassword: $e');
      return null;
    }
  }

  // Method to sign in with email and password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      logger.d('Attempting to sign in with email: $email');
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null && !user.emailVerified) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Email is not verified. Check your inbox.',
        );
      }

      // Fetch user role safely
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          String? role = userDoc.data()?['role'];
          if (role != null) {
            logger.d('User role: $role');
          }
        }
      }

      logger.d('Sign in successful: $email');
      return user;
    } on FirebaseAuthException catch (e) {
      logger
          .e('FirebaseAuthException in signInWithEmailPassword: ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          logger.w('No user found for that email.');
          break;
        case 'wrong-password':
          logger.w('Wrong password provided.');
          break;
        case 'invalid-email':
          logger.w('Invalid email format.');
          break;
        case 'user-disabled':
          logger.w('This account has been disabled.');
          break;
        case 'email-not-verified':
          logger.w('Email is not verified.');
          break;
        default:
          logger.e('Unexpected FirebaseAuthException: ${e.message}');
      }
      return null;
    } catch (e) {
      logger.e('Error in signInWithEmailPassword: $e');
      return null;
    }
  }

  // Method to sign out inside auth_service.dart
  Future<void> signOut(BuildContext context) async {
    try {
      // 1. IMMEDIATELY navigate to the login screen.
      // This violently rips down the Admin Panel, the Drawer, and all active
      // Firestore streams so they can't throw permission errors!
      if (context.mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }

      // 2. Give Flutter 100 milliseconds to finish destroying the old screen
      await Future.delayed(const Duration(milliseconds: 100));

      // 3. NOW sign out of Firebase safely in the background
      await _auth.signOut();
      logger.d('User signed out from Firebase safely');
    } catch (e) {
      logger.e('Error in signOut: $e');
    }
  }

  // Method to check if user is logged in
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Method to check user role from Firestore
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['role'] as String?;
      }
    } catch (e) {
      logger.e('Error fetching user role: $e');
    }
    return null;
  }
}

// Example function to fetch admin data
Future<void> fetchAdminData() async {
  try {
    // Ensure the current user is authenticated
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Ensure the admin user's token includes the role claim
      IdTokenResult tokenResult = await user.getIdTokenResult();
      if (tokenResult.claims?['role'] == 'admin') {
        // Fetch admin data from Firestore
        QuerySnapshot<Map<String, dynamic>> adminData =
            await FirebaseFirestore.instance.collection('admin').get();
        // Handle the fetched admin data
        logger.d('Admin data: ${adminData.docs}');
      } else {
        logger.w('User is not an admin.');
      }
    } else {
      logger.w('No user is currently signed in.');
    }
  } catch (e) {
    logger.e('Error fetching admin data: $e');
  }
}
