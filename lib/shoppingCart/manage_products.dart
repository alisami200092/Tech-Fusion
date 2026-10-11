import 'package:flutter/material.dart';

class ManageProductsPage extends StatelessWidget {
  const ManageProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Products')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.new_releases),
              title: Text('Manage New Arrivals'),
              subtitle: Text('Manage the latest products added'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to the manage new arrivals page
                Navigator.pushNamed(context, '/manageNewArrivals');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.star_border),
              title: Text('Manage Recommended Products'),
              subtitle: Text('Manage the products recommended for users'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to the manage recommended products page
                Navigator.pushNamed(context, '/manageRecommended');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.local_offer),
              title: Text('Manage Deals'),
              subtitle: Text('Manage products on sale or with discounts'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to the manage deals page
                Navigator.pushNamed(context, '/manageDeals');
              },
            ),
          ],
        ),
      ),
    );
  }
}