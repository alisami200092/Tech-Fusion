import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package

class UserPreparePage extends StatelessWidget {
  const UserPreparePage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

    // Query orders where status is either "pending" or "approved" for the current user.
    Query orderQuery = firestore.collection('ShippingInformation')
        .where("uid", isEqualTo: currentUid)
        .where("status", whereIn: ["pending", "approved"]);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Order (Preparing)"),
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
                "No orders are currently being prepared.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          final orders = snapshot.data!.docs;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final Map<String, dynamic> orderData =
                  order.data() as Map<String, dynamic>;
              String status = (orderData['status'] ?? "pending").toString();

              // Build the status widget.
              Widget statusWidget;
              if (status.toLowerCase() == "approved") {
                statusWidget = Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green, size: 24),
                    SizedBox(width: 8),
                    Text(
                      "Accepted",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16),
                    ),
                  ],
                );
              } else if (status.toLowerCase() == "pending") {
                statusWidget = Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.access_time, color: Colors.yellow, size: 24),
                    SizedBox(width: 8),
                    Text(
                      "Pending",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "...",
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                          fontSize: 16),
                    ),
                  ],
                );
              } else {
                statusWidget = Text(
                  status,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16),
                  textAlign: TextAlign.center,
                );
              }

              // Build order items widget as a list of ListTiles.
              Widget itemsWidget;
              if (orderData['items'] is List) {
                List<Widget> itemTiles = (orderData['items'] as List).map<Widget>((item) {
                  if (item is Map) {
                    String title = item['title']?.toString() ?? 'N/A';
                    String price = item['price']?.toString() ?? 'N/A';
                    String quantity = item['quantity']?.toString() ?? 'N/A';
                    String imageUrl = item['imageUrl']?.toString() ?? '';
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.shopping_bag, color: Colors.blue),
                      title: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      // Construct a Row in subtitle to show Price, Qty and then an image right after Qty.
                      subtitle: Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: "Price: ",
                                    style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  TextSpan(
                                    text: "\$$price  ",
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 14),
                                  ),
                                  const TextSpan(
                                    text: "Qty: ",
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  TextSpan(
                                    text: quantity,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Show the product image right after the quantity.
                          imageUrl.isNotEmpty
                              ? Container(
                                  width: 50,
                                  height: 50,
                                  margin: const EdgeInsets.only(left: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.image, color: Colors.grey, size: 50),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }).toList();
                itemsWidget = Column(
                  children: itemTiles,
                );
              } else {
                itemsWidget = const Text(
                  "No item information available",
                  textAlign: TextAlign.center,
                );
              }

              // Decorated container wrapping the entire order detail.
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Order ID with custom color.
                    Text(
                      "Order ID: ${order.id}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Centered animated Lottie image.
                    Center(
                      child: Lottie.asset(
                        'animations/preparing-order.json',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Status widget (Pending/Accepted)
                    statusWidget,
                    const Divider(),
                    // Order details list.
                    itemsWidget,
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}