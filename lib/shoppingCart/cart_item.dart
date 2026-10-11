import 'package:flutter_techfusion_project/shoppingCart/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  // Convert CartItem to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'product': {
        'title': product.title,
        'imageUrl': product.imageUrl,
        'description': product.description,
        'price': product.price,
      },
      'quantity': quantity,
    };
  }

  // Create CartItem from Firestore data
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product(
        title: map['product']['title'],
        imageUrl: map['product']['imageUrl'],
        description: map['product']['description'],
        price: (map['product']['price'] as num).toDouble(), 
        id: '',
      ),
      quantity: map['quantity'] as int,
    );
  }
}