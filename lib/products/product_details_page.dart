import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shoppingCart/product.dart';
import '../shoppingCart/cart_provider.dart';
import '../shoppingCart/wishlist_provider.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;

  const ProductDetailsPage({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          product.title,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Consumer<WishlistProvider>(
            builder: (context, wishlistProvider, child) {
              bool isFavorite = wishlistProvider.wishlistItems
                  .any((item) => item.title == product.title);

              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  scaffoldMessenger.hideCurrentSnackBar();

                  if (isFavorite) {
                    final itemToRemove = wishlistProvider.wishlistItems
                        .firstWhere((item) => item.title == product.title);
                    wishlistProvider.removeItem(itemToRemove);

                    // Delay displaying the snackbar until the frame is stable
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                              content: Text('Removed from Wishlist'),
                              duration: Duration(seconds: 1)),
                        );
                      }
                    });
                  } else {
                    wishlistProvider.addItem(product);

                    // Delay displaying the snackbar until the frame is stable
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                              content: Text('Added to Wishlist'),
                              duration: Duration(seconds: 1)),
                        );
                      }
                    });
                  }
                },
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Image
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey.shade50,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported,
                        size: 100,
                        color: Colors.grey),
                  ),
                ),
              ),
            ),

            // 2. Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  4,
                  (index) => Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 16),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              index == 0 ? Colors.black : Colors.grey.shade300,
                        ),
                      )),
            ),

            // 3. Title & Price Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      product.title,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000033)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 4. Rating & Reviews
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text('4.5',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('125+ Review',
                      style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 5. Specs / Description Bullet Points
            ...product.description
                .split(RegExp(r'[|\n]'))
                .where((text) => text.trim().isNotEmpty)
                .map((sentence) => _buildBulletPoint(sentence.trim())),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // ==========================================
      // 6. SPLIT ACTION BUTTONS (ADD TO CART & BUY NOW)
      // ==========================================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5)),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // --- ADD TO CART BUTTON ---
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF000033), width: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // 1. Capture the scaffold messenger before updating state
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    // 2. Perform the state update
                    Provider.of<CartProvider>(context, listen: false)
                        .addItem(product);

                    // 3. Delay the UI presentation to the next frame when the element tree is stable
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        scaffoldMessenger.hideCurrentSnackBar();
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Added to Cart!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    });
                  },
                  child: const Text(
                    'ADD TO CART',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000033)),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // --- BUY NOW BUTTON ---
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000033),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    Provider.of<CartProvider>(context, listen: false)
                        .addItem(product);
                    navigator.pushNamed('/view_cart');
                  },
                  child: const Text(
                    'BUY NOW',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0, right: 12.0),
            child: CircleAvatar(radius: 3, backgroundColor: Colors.grey),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey.shade600, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
