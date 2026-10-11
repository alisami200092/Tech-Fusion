import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FacebookAuthService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<UserCredential?> signInWithFacebook(
      BuildContext context) async {
    try {
      UserCredential? userCredential;

      if (kIsWeb) {
        FacebookAuthProvider authProvider = FacebookAuthProvider();
        userCredential =
            await FirebaseAuth.instance.signInWithPopup(authProvider);
      } else {
        final LoginResult loginResult = await FacebookAuth.instance.login();

        if (loginResult.status == LoginStatus.success) {
          final OAuthCredential facebookAuthCredential =
              FacebookAuthProvider.credential(
                  '${loginResult.accessToken?.tokenString}');
          userCredential = await FirebaseAuth.instance
              .signInWithCredential(facebookAuthCredential);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Facebook login failed: ${loginResult.message}')),
            );
          }
          return null;
        }
      }

      final user = userCredential.user;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          String firstName = "";
          String lastName = "";
          if (user.displayName != null) {
            List<String> parts = user.displayName!.split(" ");
            if (parts.isNotEmpty) {
              firstName = parts.first;
              if (parts.length > 1) {
                lastName = parts.sublist(1).join(" ");
              }
            }
          }
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email ?? "",
            'firstName': firstName,
            'lastName': lastName,
            'role': 'user',
          });
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Successfully signed in with Facebook!')),
          );
        }
      }
      return userCredential;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during Facebook login: $e')),
        );
      }
      return null;
    }
  }

  static Future<void> signOutFromFacebook(BuildContext context) async {
    try {
      // Only call the plugin logout if we are on mobile
      if (!kIsWeb) {
        await FacebookAuth.instance.logOut();
      }
      await FirebaseAuth.instance
          .signOut(); // Ensure Firebase signs out on both platforms

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Successfully logged out from Facebook!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during Facebook logout: $e')),
        );
      }
    }
  }
}
