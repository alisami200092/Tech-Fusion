import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeline_tile/timeline_tile.dart';

class UserShippingPage extends StatelessWidget {
  const UserShippingPage({super.key});

  // Define the shipping steps in order. Adjust these as needed.
  static const List<String> shippingSteps = [
    "warehouse",         // Order reached warehouse
    "loading",           // Getting loaded on cargo
    "in_transit",        // Cargo is in transit
    "departed",          // Left departing country
    "arrived",           // Arrived at destination country
    "custom_clearance",  // Undergoing customs clearance
    "out_for_delivery",  // Out for delivery
    "delivered",         // Delivered to customer
  ];

  /// Builds a timeline widget based on the order's shipping status.
  Widget _buildShippingTimeline(Map<String, dynamic> data) {
    final String currentStatus = (data['shippingStatus'] ?? 'pending')
        .toString()
        .toLowerCase();

    // If shippingStatus is still pending, indicate that the order hasn't been updated.
    if (currentStatus == 'pending') {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            "Order is waiting to be approved.",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    // Determine the current index for shipping status.
    int currentIndex = shippingSteps.indexOf(currentStatus);
    if (currentIndex == -1) {
      // If the status does not match any of our expected values, default to the first step.
      currentIndex = 0;
    }

    // Build a list of timeline tiles.
    List<Widget> timelineTiles = [];
    for (int i = 0; i < shippingSteps.length; i++) {
      bool isCompleted = (i <= currentIndex);
      timelineTiles.add(
        TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.1, // Positions vertical line toward the left.
          isFirst: i == 0,
          isLast: i == shippingSteps.length - 1,
          indicatorStyle: IndicatorStyle(
            width: 20,
            color: isCompleted ? Colors.green : Colors.grey,
            padding: const EdgeInsets.all(6),
          ),
          beforeLineStyle: LineStyle(
            color: isCompleted ? Colors.green : Colors.grey,
            thickness: 2,
          ),
          startChild: Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted ? Colors.green : Colors.grey,
            ),
          ),
          endChild: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              shippingSteps[i].capitalize(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                color: isCompleted ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    // Return the timeline as a Column.
    return Column(
      children: timelineTiles,
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // If no user is signed in, show an error.
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Shipping Status"),
        ),
        body: const Center(
          child: Text("No user signed in."),
        ),
      );
    }

    // Query: Get all orders for the current user from the ShippingInformation collection.
    Query orderQuery = firestore
        .collection('ShippingInformation')
        .where("uid", isEqualTo: currentUser.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shipping Status"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: orderQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error fetching orders"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No orders found.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          final orders = snapshot.data!.docs;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot order = orders[index];
              final Map<String, dynamic> data =
              order.data() as Map<String, dynamic>;
              // Use shippingStatus instead of status.
              final String shippingStatus = (data['shippingStatus'] ?? 'pending')
                  .toString()
                  .toLowerCase();
              // Retrieve other optional fields.
              final String expectedArrival =
                  data['expectedArrival']?.toString() ?? "N/A";
              final String trackingID = data['trackingID']?.toString() ??
                  data['tracking']?.toString() ??
                  "N/A";
              // Retrieve and format the timestamp.
              final String timestamp = data['timestamp'] != null
                  ? (data['timestamp'] as Timestamp).toDate().toString()
                  : "N/A";

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          "Order ID: ${order.id}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Current Status: ${shippingStatus.capitalize()}"),
                            Text("Last Updated: $timestamp"),
                          ],
                        ),
                      ),
                      const Divider(),
                      _buildShippingTimeline(data),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Expected Arrival: $expectedArrival",
                              style: const TextStyle(fontSize: 14)),
                          Text("Tracking ID: $trackingID",
                              style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}