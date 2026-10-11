import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb; // Needed to check if running on Web

class GoogleAuthService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '439935075567-kcv0bhqnfcnc8l2jlgsrkfkohn52fck5.apps.googleusercontent.com',
  );

  static Future<bool> signInWithGoogle(BuildContext context) async {
    try {
      User? user;

      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithPopup(authProvider);
        user = userCredential.user;
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return false; // user cancelled sign in

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        user = userCredential.user;
      }

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
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing in with Google: $e')),
        );
      }
      return false;
    }
  }

  static Future<void> signOutGoogle(BuildContext context) async {
    try {
      // Only call the plugin signOut if we are on mobile
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await FirebaseAuth.instance
          .signOut(); // Ensure Firebase signs out on both platforms

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User signed out of Google')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out of Google: $e')),
        );
      }
    }
  }
}
