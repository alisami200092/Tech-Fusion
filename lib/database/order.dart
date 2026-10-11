import 'package:flutter_techfusion_project/shoppingCart/orderitem.dart';  

class Order {
  final Shipping shipping;  
  final Map<String, String> payment;  
  final List<OrderItem> items;  

  Order({
    required this.shipping,
    required this.payment,
    required this.items,
  });
}

class Shipping {
  final String name;
  final String address;
  final String city;
  final String state;
  final String country;
  final String zipCode;

  Shipping({
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.zipCode,
  });
}
