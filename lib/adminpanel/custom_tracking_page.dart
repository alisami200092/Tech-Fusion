import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerTrackingPage extends StatelessWidget {
  const CustomerTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "My Orders",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: currentUser == null
          ? const Center(child: Text("Please log in to view your orders."))
          : StreamBuilder<QuerySnapshot>(
              // CRITICAL: We only fetch orders belonging to the logged-in user!
              stream: FirebaseFirestore.instance
                  .collection('ShippingInformation')
                  .where('uid', isEqualTo: currentUser.uid)
                  .orderBy('orderTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong!'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF000033)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  // Matches your clean empty state screenshot
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          "No orders are currently being prepared.",
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                final orders = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot order = orders[index];
                    final Map<String, dynamic> data =
                        order.data() as Map<String, dynamic>;

                    return _buildOrderTrackingCard(order.id, data);
                  },
                );
              },
            ),
    );
  }

  Widget _buildOrderTrackingCard(String orderId, Map<String, dynamic> data) {
    final String shippingStatus =
        (data['shippingStatus'] ?? 'pending').toString().toLowerCase();

    // Status colors
    Color statusColor = Colors.orange;
    if (shippingStatus == 'approved') statusColor = Colors.blue;
    if (shippingStatus == 'shipped') statusColor = Colors.purple;
    if (shippingStatus == 'delivered') statusColor = Colors.green;
    if (shippingStatus == 'cancelled') statusColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Order ID",
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(orderId,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF000033))),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    shippingStatus.toUpperCase(),
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          // Items Preview
          if (data['items'] != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                  "${(data['items'] as List).length} Item(s) in this order",
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),

          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          // The Beautiful Timeline
          _buildTrackingTimeline(shippingStatus),

          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          // Footer info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Expected Arrival",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                    const SizedBox(height: 4),
                    const Text("Standard Shipping",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                if (shippingStatus == 'shipped' ||
                    shippingStatus == 'delivered')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Tracking ID",
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(data['trackingID'] ?? data['tracking'] ?? 'N/A',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF000033))),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline(String currentStatus) {
    // Hide timeline if cancelled
    if (currentStatus == 'cancelled') {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text("This order has been cancelled.",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      );
    }

    final List<Map<String, dynamic>> trackingSteps = [
      {"id": "pending", "title": "Order Placed", "icon": Icons.receipt_long},
      {
        "id": "approved",
        "title": "Approved",
        "icon": Icons.inventory_2_outlined
      },
      {
        "id": "shipped",
        "title": "Shipped",
        "icon": Icons.local_shipping_outlined
      },
      {
        "id": "delivered",
        "title": "Delivered",
        "icon": Icons.check_circle_outline
      },
    ];

    int currentIndex =
        trackingSteps.indexWhere((step) => step["id"] == currentStatus);
    if (currentIndex == -1) currentIndex = 0; // Default to pending if unknown

    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: trackingSteps.length,
        itemBuilder: (context, index) {
          bool isCompleted = index <= currentIndex;
          bool isCurrent = index == currentIndex;
          bool isLast = index == trackingSteps.length - 1;

          Color iconColor = isCompleted ? Colors.white : Colors.grey.shade400;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? Colors.green
                          : (isCompleted
                              ? Colors.green.shade400
                              : Colors.white),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? Colors.transparent
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Icon(trackingSteps[index]["icon"],
                        size: 20, color: iconColor),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 30,
                      color: isCompleted
                          ? Colors.green.shade300
                          : Colors.grey.shade200,
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
                  child: Text(
                    trackingSteps[index]["title"],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                      color:
                          isCompleted ? Colors.black87 : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
