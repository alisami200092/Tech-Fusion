import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'cart_item.dart';
import 'product.dart';

class CartProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, CartItem> _items = {};
  final Logger _logger = Logger(); // Instantiate logger

  Map<String, CartItem> get items => {..._items};
  int get itemCount => _items.length;
  double get totalAmount => _items.values
      .fold(0, (total, item) => total + (item.product.price * item.quantity));

  void addItem(Product product) {
    if (_items.containsKey(product.title)) {
      _items.update(
        product.title,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items[product.title] = CartItem(product: product);
    }
    notifyListeners();
  }

  void removeItem(String productTitle) {
    _items.remove(productTitle);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(
          productId,
          (existingCartItem) => CartItem(
                product: existingCartItem.product,
                quantity: existingCartItem.quantity - 1,
              ));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  // Save cart as an order in Firestore
  Future<void> saveOrder(String userId, BuildContext context) async {
    try {
      if (_items.isEmpty) return;

      String orderId = _firestore.collection('orders').doc().id;
      Map<String, dynamic> orderData = {
        'userId': userId,
        'orderId': orderId,
        'totalAmount': totalAmount,
        'status': 'pending',
        'items': _items.values.map((item) => item.toMap()).toList(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('orders').doc(orderId).set(orderData);
      clearCart(); // Clear cart after order is placed

      if (context.mounted) {
        // Show success message using Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order placed successfully!')),
        );
      }
    } catch (e) {
      _logger.e('Error saving order: $e'); // Log the error using Logger

      if (context.mounted) {
        // Show error message using Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving order. Please try again.')),
        );
      }
    }
  }
}
