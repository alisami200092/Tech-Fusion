import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_techfusion_project/profile_page_settings/my_orders_page.dart';
import 'login_page.dart';
import 'authentication/auth_service.dart';
import 'card_membership.dart';
import 'shoppingCart/wishlist_page.dart';
import 'adminpanel/orders_management.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoggedIn = false;
  String firstName = '';
  String lastName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() => _isLoading = true);

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        String fullName = user.displayName?.trim() ?? '';
        if (fullName.isNotEmpty) {
          List<String> nameParts = fullName.split(RegExp(r'\s+'));
          firstName = nameParts.first;
          lastName = nameParts.length > 1 ? nameParts.last : '';
        } else {
          firstName = user.email?.split('@').first ?? 'User';
          lastName = '';
        }
        isLoggedIn = true;
      });
    } else {
      setState(() => isLoggedIn = false);
    }

    setState(() => _isLoading = false);
  }

  void toggleLoginStatus() {
    setState(() => isLoggedIn = !isLoggedIn);
  }

  void navigateToPage(Widget page) {
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    }
  }

  Future<void> _handleOrderNavigation(int tabIndex) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? role = await AuthService().getUserRole(user.uid);
      if (role != null && role.toLowerCase() == 'admin') {
        navigateToPage(const OrdersManagementPage());
      } else {
        navigateToPage(MyOrdersPage(initialTabIndex: tabIndex));
      }
    } else {
      navigateToPage(const LoginPage());
    }
  }

  // Modernized Circular Action Icon
  Widget _buildOrderActionIcon(IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (color ?? const Color(0xFF000033)).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child:
                Icon(icon, size: 28, color: color ?? const Color(0xFF000033)),
          ),
          const SizedBox(height: 8),
          Text(label,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // Modernized Square Tool Card
  Widget _buildToolCard(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF000033)),
            const SizedBox(height: 12),
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String fullName =
        '$firstName ${lastName.isNotEmpty ? lastName : ''}'.trim();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Image.asset('images/techFusion-logo-text-drawer.png',
            height: 120, fit: BoxFit.contain),
        actions: [
          IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {}),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================================
            // 1. GREETING
            // ================================
            Text(
              isLoggedIn ? 'Welcome back,' : 'Welcome to TechFusion',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (isLoggedIn)
              Text(
                fullName,
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000033)),
                overflow: TextOverflow.ellipsis,
              )
            else
              GestureDetector(
                onTap: () => navigateToPage(const LoginPage()),
                child: const Text(
                  'Sign In / Register',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000033),
                      decoration: TextDecoration.underline),
                ),
              ),

            const SizedBox(height: 24),

            // ================================
            // 2. LIVE WALLET SECTION
            // ================================
            if (isLoggedIn && FirebaseAuth.instance.currentUser != null)
              StreamBuilder<DocumentSnapshot>(
                // This stream listens to the database live!
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  // Default to 0.0 while loading or if data is missing
                  double liveBalance = 0.0;

                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    if (data != null) {
                      // Safely extract and cast the balance
                      liveBalance = (data['walletBalance'] ?? 0.0).toDouble();
                    }
                  }

                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF000033),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color:
                                const Color(0xFF000033).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6))
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("TechFusion Wallet",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                            SizedBox(height: 4),
                            Text("Available Balance",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text(
                          "\$${liveBalance.toStringAsFixed(2)}",
                          style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 32),

            // ================================
            // 3. MY ORDERS SECTION
            // ================================
            const Text("My Orders",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000033))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildOrderActionIcon(Icons.inventory_2_outlined, 'Preparing',
                      () => _handleOrderNavigation(0),
                      color: Colors.orange),
                  _buildOrderActionIcon(Icons.local_shipping_outlined,
                      'Shipped', () => _handleOrderNavigation(0),
                      color: Colors.purple),
                  _buildOrderActionIcon(Icons.check_circle_outline, 'Delivered',
                      () => _handleOrderNavigation(1),
                      color: Colors.green),
                  _buildOrderActionIcon(Icons.assignment_return_outlined,
                      'Returns', () => _handleOrderNavigation(1),
                      color: Colors.red),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ================================
            // 4. MY TOOLS / SPECIAL SECTIONS
            // ================================
            const Text("My Tools",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000033))),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildToolCard(Icons.favorite_border, 'Wish List',
                    () => navigateToPage(const WishlistPage())),
                _buildToolCard(Icons.build_outlined, 'Build List', () {}),
                _buildToolCard(Icons.local_offer_outlined, 'Offers', () {}),
                _buildToolCard(Icons.card_membership, 'TechFusion+',
                    () => navigateToPage(const CardMembershipPage())),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
