import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'shopping_cart_product_provider.dart';
import 'cart_provider.dart';
import 'wishlist_provider.dart';

class NewArrivalsPage extends StatelessWidget {
  const NewArrivalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final newArrivals = Provider.of<ProductProvider>(context).newArrivals;

    // Determine the number of columns based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 200).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Arrivals'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.65,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: newArrivals.length,
              itemBuilder: (context, index) {
                final product = newArrivals[index];
                final isWishlisted = Provider.of<WishlistProvider>(context).wishlistItems.contains(product);
                return Card(
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                Provider.of<CartProvider>(
                                  context,
                                  listen: false,
                                ).addItem(product);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow,
                              ),
                              child: const Text('Add to Cart'),
                            ),
                            IconButton(
                              icon: Icon(isWishlisted ? Icons.favorite : Icons.favorite_border),
                              color: isWishlisted ? Colors.pink : Colors.black, // change color to pink if clicked
                              onPressed: () {
                                if (isWishlisted) {
                                  Provider.of<WishlistProvider>(
                                    context,
                                    listen: false,
                                  ).removeItem(product);
                                } else {
                                  Provider.of<WishlistProvider>(
                                    context,
                                    listen: false,
                                  ).addItem(product);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}