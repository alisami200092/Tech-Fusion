import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_techfusion_project/shoppingCart/product.dart';
import 'package:flutter_techfusion_project/shoppingCart/orderitem.dart';
import 'package:flutter_techfusion_project/database/order.dart' as custom_order;
import 'package:logging/logging.dart';  // Import logger

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Logger _logger = Logger('FirestoreServiceLogger');  // Logger initialization

  // Add a new product (your current method)
  Future<void> addProduct(Product product) async {
    try {
      final productRef = _db.collection('products');

      await productRef.add({
        'title': product.title,
        'imageUrl': product.imageUrl,
        'description': product.description,
        'price': product.price,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _logger.info('Product added successfully: ${product.title}');  // Log success
    } catch (e) {
      _logger.severe('Error adding product: $e');  // Log error
    }
  }

  // Save Order to Firestore
  Future<void> saveOrder(custom_order.Order order) async {
    try {
      final ordersRef = _db.collection('orders');
      
      // Add new order document to Firestore
      await ordersRef.add({
        'shipping': {
          'name': order.shipping.name,
          'address': order.shipping.address,
          'city': order.shipping.city,
          'state': order.shipping.state,
          'country': order.shipping.country,
          'zipCode': order.shipping.zipCode,
        },
        'payment': order.payment,
        'items': order.items.map((item) {
          return {
            'name': item.name,
            'quantity': item.quantity,
            'price': item.price,
          };
        }).toList(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _logger.info('Order saved successfully with ${order.items.length} items');
    } catch (e) {
      _logger.severe('Error saving order: $e');
    }
  }

  // Fetch Orders from Firestore
  Future<List<custom_order.Order>> fetchOrders() async {
    try {
      final ordersRef = _db.collection('orders');
      final querySnapshot = await ordersRef.get();

      List<custom_order.Order> ordersList = querySnapshot.docs.map((doc) {
        final data = doc.data();

        List<OrderItem> items = (data['items'] as List).map((itemData) {
          return OrderItem(
            name: itemData['name'],
            quantity: itemData['quantity'],
            price: itemData['price'].toDouble(),
          );
        }).toList();

        var shippingData = data['shipping'];
        var shipping = custom_order.Shipping(
          name: shippingData['name'],
          address: shippingData['address'],
          city: shippingData['city'],
          state: shippingData['state'],
          country: shippingData['country'],
          zipCode: shippingData['zipCode'],
        );

        return custom_order.Order(
          shipping: shipping,
          payment: Map<String, String>.from(data['payment']),
          items: items,
        );
      }).toList();

      _logger.info('Fetched ${ordersList.length} orders from Firestore');
      return ordersList;
    } catch (e) {
      _logger.severe('Error fetching orders: $e');
      return [];
    }
  }
}