import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'mainpage.dart';
import 'signup_page.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'profile_page_settings/profile_settings_page.dart';
import 'about.dart';
import 'email_verification_page.dart';
import 'adminpanel/admin_panel.dart';
import '/authentication/firebase_options.dart';
import 'shoppingCart/cart_provider.dart';
import 'shoppingCart/view_cart_page.dart';
import 'shoppingCart/checkout_page.dart';
import 'shoppingCart/wishlist_provider.dart';
import 'shoppingCart/wishlist_page.dart';
import 'shoppingCart/shopping_cart_product_provider.dart';
import 'shoppingCart/manage_products.dart';
import 'shoppingCart/manage_new_arrivals_page.dart';
import 'shoppingCart/manage_recommended.dart';
import 'shoppingCart/manage_deals.dart';
import 'shoppingCart/continue_page.dart';
import 'package:logger/logger.dart';

var logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TechFusion',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const AuthWrapper(),
        routes: {
          '/signup': (context) => const SignUpPage(),
          '/login': (context) => const LoginPage(),
          '/profile': (context) => const ProfilePage(),
          '/profile_settings': (context) => const ProfileSettingsPage(),
          '/view_cart': (context) => const ViewCartPage(),
          '/checkout': (context) => const CheckoutPage(),
          '/wishlist': (context) => const WishlistPage(),
          '/manage': (context) => ManageProductsPage(),
          '/manageNewArrivals': (context) => ManageNewArrivalsPage(),
          '/manageRecommended': (context) => ManageRecommendedPage(),
          '/manageDeals': (context) => ManageDealsPage(),
          '/about': (context) => AboutUsPage(),
          '/continue': (context) => const ContinuePage(),
          '/email-verification': (context) => const EmailVerificationPage(),

          // Added missing AdminPanel route mapping
          '/adminPanel': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, String>?;
            return AdminPanel(
              firstName: args?['firstName'] ?? '',
              lastName: args?['lastName'] ?? '',
              isAdmin: true,
            );
          },

          '/main': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, String>?;
            return HomeScreen(
              firstName: args?['firstName'] ?? '',
              lastName: args?['lastName'] ?? '',
            );
          },
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (context) => const UnknownPage());
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF000033)),
            ),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data;
          if (user == null || !user.emailVerified) {
            return const EmailVerificationPage();
          }

          // Log custom claims for debugging
          user.getIdTokenResult().then((tokenResult) {
            logger.d('Custom Claims: ${tokenResult.claims}');
          });

          final firstName = user.displayName?.split(' ').first ?? '';
          final lastName = user.displayName?.split(' ').last ?? '';

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: Color(0xFF000033)),
                  ),
                );
              }

              if (roleSnapshot.hasData && roleSnapshot.data!.exists) {
                final data = roleSnapshot.data!.data() as Map<String, dynamic>;
                final isAdmin = data['role'] == 'admin';

                // Return the views directly instead of calling Navigator
                if (isAdmin) {
                  return AdminPanel(
                    firstName: firstName,
                    lastName: lastName,
                    isAdmin: isAdmin,
                  );
                } else {
                  return HomeScreen(
                    firstName: firstName,
                    lastName: lastName,
                  );
                }
              }

              return const LoginPage(); // Fallback if document does not exist
            },
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

class UnknownPage extends StatelessWidget {
  const UnknownPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(
        child: Text(
          '404 - Page Not Found',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
