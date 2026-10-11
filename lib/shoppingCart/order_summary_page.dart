import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'cart_item.dart';
import 'cart_provider.dart';

class OrderSummaryPage extends StatelessWidget {
  final List<CartItem> cartItems;
  final Map<String, String> paymentDetails;
  final Map<String, String> shippingDetails;

  const OrderSummaryPage({
    super.key,
    required this.cartItems,
    required this.paymentDetails,
    required this.shippingDetails,
  });

  @override
  Widget build(BuildContext context) {
    // Calculates the exact total amount
    double totalAmount = cartItems.fold(
      0,
      // ignore: avoid_types_as_parameter_names
      (sum, item) => sum + (item.product.price * item.quantity),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOrderItems(totalAmount),
          const SizedBox(height: 16),
          _buildShippingDetails(),
          const SizedBox(height: 16),
          _buildPaymentDetails(),
          const SizedBox(height: 32),

          // ===== THE BULLETPROOF PLACE ORDER BUTTON =====
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () async {
              // 1. Capture Navigator, Scaffold, and Provider BEFORE the async gap!
              // This completely prevents the "deactivated widget" crash.
              final navigator = Navigator.of(context);
              final scaffold = ScaffoldMessenger.of(context);
              final cartProvider =
                  Provider.of<CartProvider>(context, listen: false);

              // 2. Grab User
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                scaffold.showSnackBar(
                  const SnackBar(
                      content: Text('Error: User not logged in!'),
                      backgroundColor: Colors.red),
                );
                return;
              }

              // 3. Prepare items list
              final itemsList = cartItems
                  .map((item) => {
                        'title': item.product.title,
                        'price': item.product.price,
                        'quantity': item.quantity,
                        'imageUrl': item.product.imageUrl,
                      })
                  .toList();

              // 4. Sanitize Payment Details (Fixes the COD Freeze)
              bool isCOD = paymentDetails['method'] == 'Cash on Delivery';
              Map<String, dynamic> cleanPaymentDetails = isCOD
                  ? {
                      'method': 'Cash on Delivery',
                      'cardNumber': '',
                      'cardHolderName': '',
                    }
                  : {
                      'method': paymentDetails['method'] ?? 'Card',
                      'cardNumber': paymentDetails['cardNumber'] ?? '',
                      'cardHolderName': paymentDetails['cardHolderName'] ?? '',
                    };

              // 5. Sanitize Shipping Details (Prevents Firebase null errors)
              Map<String, dynamic> cleanShippingDetails = {
                'name': shippingDetails['name'] ?? '',
                'address': shippingDetails['address'] ?? '',
                'city': shippingDetails['city'] ?? '',
                'state': shippingDetails['state'] ?? '',
                'zipCode': shippingDetails['zipCode'] ?? '',
                'country': shippingDetails['country'] ?? '',
              };

              try {
                // 6. Save everything securely to Firestore
                await FirebaseFirestore.instance
                    .collection('ShippingInformation')
                    .add({
                  'userId': user.uid,
                  'totalAmount': totalAmount,
                  'orderTime': Timestamp.now(),
                  'shippingStatus': 'pending',
                  'trackingID': '',
                  'expectedArrival': 'TBD',
                  'shippingDetails': cleanShippingDetails,
                  'paymentDetails': cleanPaymentDetails,
                  'items': itemsList,
                });

                // 7. Clear cart & show success using the CAPTURED variables
                cartProvider.clearCart();

                scaffold.showSnackBar(
                  const SnackBar(
                      content: Text('Order Placed Successfully!'),
                      backgroundColor: Colors.green),
                );

                // 8. Navigate back to Home using the CAPTURED navigator
                final displayName = user.displayName ?? '';
                final nameParts = displayName.split(' ');
                final firstName = nameParts.isNotEmpty ? nameParts.first : '';
                final lastName =
                    nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

                navigator.pushReplacementNamed(
                  '/main',
                  arguments: {
                    'firstName': firstName,
                    'lastName': lastName,
                  },
                );
              } catch (e) {
                scaffold.showSnackBar(
                  SnackBar(
                      content: Text('Failed to place order: $e'),
                      backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('PLACE ORDER',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
          // ==============================================
        ],
      ),
    );
  }

  Widget _buildOrderItems(double totalAmount) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: _containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000033))),
          const SizedBox(height: 16),
          ...cartItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text('${item.product.title} (x${item.quantity})',
                          style: TextStyle(color: Colors.grey.shade700))),
                  Text(
                      '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('\$${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000033))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingDetails() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: _containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Shipping Details',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000033))),
          const SizedBox(height: 12),
          Text(shippingDetails['name'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(shippingDetails['address'] ?? '',
              style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 4),
          Text(
              '${shippingDetails['city'] ?? ''}, ${shippingDetails['state'] ?? ''} ${shippingDetails['zipCode'] ?? ''}',
              style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 4),
          Text(shippingDetails['country'] ?? '',
              style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    bool isCOD = paymentDetails['method'] == 'Cash on Delivery';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: _containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Method',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000033))),
          const SizedBox(height: 12),
          if (isCOD)
            Row(
              children: [
                const Icon(Icons.money, color: Colors.green),
                const SizedBox(width: 8),
                Text('Cash on Delivery',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800)),
              ],
            )
          else ...[
            Row(
              children: [
                const Icon(Icons.credit_card, color: Color(0xFF000033)),
                const SizedBox(width: 8),
                Text(
                    'Card ending in ${paymentDetails['cardNumber']?.length != null && paymentDetails['cardNumber']!.length >= 4 ? paymentDetails['cardNumber']!.substring(paymentDetails['cardNumber']!.length - 4) : '****'}',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800)),
              ],
            ),
            const SizedBox(height: 4),
            Text('Name: ${paymentDetails['cardHolderName'] ?? ''}',
                style: TextStyle(color: Colors.grey.shade600)),
          ]
        ],
      ),
    );
  }

  BoxDecoration _containerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.0),
      border: Border.all(color: Colors.grey.shade200),
    );
  }
}
