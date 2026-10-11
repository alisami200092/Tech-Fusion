import 'package:flutter/material.dart';
import 'package:flutter_techfusion_project/database/firestore_service.dart';
import 'package:flutter_techfusion_project/database/order.dart' as custom_order;
import 'package:flutter_techfusion_project/shoppingCart/orderitem.dart';
import 'package:logger/logger.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final Logger _logger = Logger();
  bool _isLoading = true;
  List<custom_order.Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // Fetch orders from Firestore
  Future<void> _fetchOrders() async {
    try {
      List<custom_order.Order> orders = await _firestoreService.fetchOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      _logger.e('Error fetching orders: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Widget to display loading spinner
  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  // Widget to display no orders message
  Widget _buildNoOrdersMessage() {
    return Center(
      child: Text('No orders found.', style: TextStyle(fontSize: 18)),
    );
  }

  // Widget to display order details
  Widget _buildOrderItem(custom_order.Order order) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display shipping info
            Text('Shipping Info:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Name: ${order.shipping.name}'),
            Text('Address: ${order.shipping.address}'),
            Text('City: ${order.shipping.city}, ${order.shipping.state}'),
            Text('Country: ${order.shipping.country}, ${order.shipping.zipCode}'),

            SizedBox(height: 10),

            // Display payment info
            Text('Payment Method: ${order.payment['method']}'),
            Text('Payment Status: ${order.payment['status']}'),

            SizedBox(height: 10),

            // Display items in the order
            Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...order.items.map((OrderItem item) {
              return Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text('${item.name} x${item.quantity} - \$${item.price}'),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order History')),
      body: _isLoading
          ? _buildLoadingIndicator()
          : _orders.isEmpty
              ? _buildNoOrdersMessage()
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (ctx, index) {
                    return _buildOrderItem(_orders[index]);
                  },
                ),
    );
  }
}