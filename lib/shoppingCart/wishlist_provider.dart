import 'package:flutter/material.dart';
import 'product.dart';

class WishlistProvider with ChangeNotifier {
  final List<Product> _wishlistItems = [];

  List<Product> get wishlistItems => _wishlistItems;

  void addItem(Product product) {
    if (!_wishlistItems.contains(product)) {
      _wishlistItems.add(product);
      notifyListeners();
    }
  }

  void removeItem(Product product) {
    _wishlistItems.remove(product);
    notifyListeners();
  }
}