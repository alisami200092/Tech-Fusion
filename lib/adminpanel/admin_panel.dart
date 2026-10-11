import 'package:flutter/material.dart';
import 'package:flutter_techfusion_project/authentication/auth_service.dart';
import 'package:flutter_techfusion_project/shoppingCart/manage_products.dart';
import 'package:flutter_techfusion_project/profile_page.dart';
import 'package:flutter_techfusion_project/profile_page_settings/profile_settings_page.dart';
import 'package:flutter_techfusion_project/shoppingCart/wishlist_page.dart';
import 'package:flutter_techfusion_project/shoppingCart/view_cart_page.dart';
import 'package:flutter_techfusion_project/shoppingCart/checkout_page.dart';
import 'dashboard_overview.dart';
import 'user_management.dart';
import 'orders_management.dart';

class AdminPanel extends StatelessWidget {
  final String firstName;
  final String lastName;
  final bool isAdmin;

  const AdminPanel({
    required this.firstName,
    required this.lastName,
    required this.isAdmin,
    super.key,
  });

  void _logout(BuildContext context) async {
    await AuthService().signOut(context);
  }

  // Modern Sidebar Tile
  Widget _buildDrawerItem(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: Colors.white70),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500)),
        hoverColor: Colors.white.withValues(alpha: 0.1),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF000033),
        elevation: 0,
        title: Image.asset('images/Techfusion-logo.png', height: 100),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'Admin Mode',
                style: TextStyle(
                    color: Colors.green.shade400,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2),
              ),
            ),
          )
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF000022),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF000033)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$firstName $lastName',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isAdmin ? 'Super Admin' : 'Customer',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildDrawerItem(
                icon: Icons.dashboard_outlined,
                title: 'Dashboard',
                onTap: () => Navigator.pop(context)),
            if (isAdmin) ...[
              _buildDrawerItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Manage Products',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ManageProductsPage()))),
              _buildDrawerItem(
                  icon: Icons.local_shipping_outlined,
                  title: 'Orders Management',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OrdersManagementPage()))),
              _buildDrawerItem(
                  icon: Icons.people_outline,
                  title: 'Users Management',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UserManagementPage()))),
            ] else ...[
              _buildDrawerItem(
                  icon: Icons.shopping_cart_outlined,
                  title: 'View Cart',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ViewCartPage()))),
              _buildDrawerItem(
                  icon: Icons.favorite_border,
                  title: 'Wishlist',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WishlistPage()))),
              _buildDrawerItem(
                  icon: Icons.payment_outlined,
                  title: 'Checkout',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CheckoutPage()))),
            ],
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Divider(color: Colors.white12)),
            _buildDrawerItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileSettingsPage()))),
            _buildDrawerItem(
                icon: Icons.person_outline,
                title: 'My Profile',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()))),
            _buildDrawerItem(
                icon: Icons.logout,
                title: 'Logout',
                onTap: () {
                  _logout(context);
                }),
          ],
        ),
      ),
      body: isAdmin
          ? const DashboardOverview()
          : const Center(
              child: Text(
                'Welcome to TechFusion',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000033)),
              ),
            ),
    );
  }
}
