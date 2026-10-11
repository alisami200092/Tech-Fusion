import 'package:flutter/material.dart';

class CardMembershipPage extends StatelessWidget {
  const CardMembershipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Image.asset(
          'images/TechFusion.png',
          height: 40,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TechFusion+ Membership',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Save even more with TechFusion+ exclusive offers. Membership is FREE.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildMembershipBenefit(
                    context,
                    Icons.local_shipping,
                    'Free Shipping',
                    'Enjoy free shipping on all your orders.',
                  ),
                  _buildMembershipBenefit(
                    context,
                    Icons.local_offer,
                    'Exclusive Offers',
                    'Get access to exclusive deals and offers.',
                  ),
                  _buildMembershipBenefit(
                    context,
                    Icons.card_membership,
                    'Member-Only Discounts',
                    'Avail special discounts only for members.',
                  ),
                  _buildMembershipBenefit(
                    context,
                    Icons.assignment,
                    'Product Warranty Discount',
                    'Get discounted warranty on products.',
                  ),
                  _buildMembershipBenefit(
                    context,
                    Icons.refresh,
                    'Enhanced Returns',
                    'Enjoy an extended return policy for your purchases.',
                  ),
                  _buildMembershipBenefit(
                    context,
                    Icons.support_agent,
                    'Dedicated Customer Service',
                    'Access priority customer support for all your queries.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Add your navigation or action here
                },
                child: const Text('Learn More'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipBenefit(BuildContext context, IconData icon, String title, String description) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        subtitle: Text(description, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          // Add your navigation or action here
        },
      ),
    );
  }
}