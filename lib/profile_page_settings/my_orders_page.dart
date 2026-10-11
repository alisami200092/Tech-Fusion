import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

class MyOrdersPage extends StatelessWidget {
  final int initialTabIndex;

  const MyOrdersPage({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return DefaultTabController(
      length: 3,
      initialIndex: initialTabIndex,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text("My Orders",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Color(0xFF000033),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF000033),
            indicatorWeight: 3,
            tabs: [
              Tab(text: "Active"),
              Tab(text: "Delivered"),
              Tab(text: "Cancelled"),
            ],
          ),
        ),
        body: currentUser == null
            ? const Center(child: Text("Please log in to view your orders."))
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('ShippingInformation')
                        .where('userId', isEqualTo: currentUser.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF000033)));
                      }

                      final allOrders = snapshot.data?.docs ?? [];

                      allOrders.sort((a, b) {
                        final aData = a.data() as Map<String, dynamic>;
                        final bData = b.data() as Map<String, dynamic>;
                        final aTime = aData['orderTime'] as Timestamp?;
                        final bTime = bData['orderTime'] as Timestamp?;
                        if (aTime == null || bTime == null) {
                          return 0;
                        }
                        return bTime.compareTo(aTime);
                      });

                      // Define what status goes to what tab
                      final deliveredStatuses = [
                        'delivered',
                        'return_requested',
                        'refunded',
                        'return_rejected'
                      ];

                      final activeOrders = allOrders.where((doc) {
                        final status = (doc.data()
                                    as Map<String, dynamic>)['shippingStatus']
                                ?.toString()
                                .toLowerCase() ??
                            'pending';
                        return !deliveredStatuses.contains(status) &&
                            status != 'cancelled';
                      }).toList();

                      final deliveredOrders = allOrders.where((doc) {
                        final status = (doc.data()
                                    as Map<String, dynamic>)['shippingStatus']
                                ?.toString()
                                .toLowerCase() ??
                            'pending';
                        return deliveredStatuses.contains(status);
                      }).toList();

                      final cancelledOrders = allOrders.where((doc) {
                        final status = (doc.data()
                                    as Map<String, dynamic>)['shippingStatus']
                                ?.toString()
                                .toLowerCase() ??
                            'pending';
                        return status == 'cancelled';
                      }).toList();

                      return TabBarView(
                        children: [
                          _buildOrderList(activeOrders, isActiveTab: true),
                          _buildOrderList(deliveredOrders, isActiveTab: false),
                          _buildOrderList(cancelledOrders, isActiveTab: false),
                        ],
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildOrderList(List<DocumentSnapshot> orders,
      {required bool isActiveTab}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isActiveTab)
              Lottie.asset('animations/preparing-order.json',
                  width: 200,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: Colors.grey.shade300))
            else
              Icon(Icons.receipt_long_outlined,
                  size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text("No orders found in this section.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final data = orders[index].data() as Map<String, dynamic>;
        return _buildOrderTrackingCard(orders[index].id, data, context);
      },
    );
  }

  Widget _buildStatusAnimation(String currentStatus) {
    String animationPath = '';
    if (['pending', 'approved', 'warehouse', 'loading']
        .contains(currentStatus)) {
      animationPath = 'animations/preparing-order.json';
    } else if ([
      'shipped',
      'in_transit',
      'departed',
      'arrived',
      'custom_clearance',
      'out_for_delivery'
    ].contains(currentStatus)) {
      animationPath = 'animations/shipping-truck.json';
    } else {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Lottie.asset(animationPath,
            height: 120,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink()),
      ),
    );
  }

  Widget _buildOrderTrackingCard(
      String orderId, Map<String, dynamic> data, BuildContext context) {
    final String shippingStatus =
        (data['shippingStatus'] ?? 'pending').toString().toLowerCase();

    Color statusColor = Colors.orange;
    if (shippingStatus == 'approved') {
      statusColor = Colors.blue;
    } else if ([
      'shipped',
      'in_transit',
      'departed',
      'arrived',
      'custom_clearance',
      'out_for_delivery'
    ].contains(shippingStatus)) {
      statusColor = Colors.purple;
    } else if (shippingStatus == 'delivered' || shippingStatus == 'refunded') {
      statusColor = Colors.green;
    } else if (shippingStatus == 'cancelled' ||
        shippingStatus == 'return_rejected') {
      statusColor = Colors.red;
    }

    String displayStatus = shippingStatus.replaceAll('_', ' ').toUpperCase();
    if (shippingStatus == 'return_requested') {
      displayStatus = 'REVIEWING RETURN';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  child: Text(displayStatus,
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          if (data['items'] != null && data['items'] is List)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "${(data['items'] as List).length} Item(s) in this order",
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  ...(data['items'] as List).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade100,
                              image: DecorationImage(
                                  image: NetworkImage(
                                      item['imageUrl']?.toString() ?? ''),
                                  fit: BoxFit.cover,
                                  onError: (e, s) => {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['title']?.toString() ?? 'N/A',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Qty: ${item['quantity']}",
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13)),
                                    Text("\$${item['price']}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green)),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  })
                ],
              ),
            ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          _buildStatusAnimation(shippingStatus),
          if (shippingStatus != 'return_requested' &&
              shippingStatus != 'refunded' &&
              shippingStatus != 'return_rejected') ...[
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            _buildTrackingTimeline(shippingStatus),
          ],
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
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
                    Text(data['expectedArrival'] ?? "TBD",
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                if (!['pending', 'approved', 'cancelled']
                    .contains(shippingStatus))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Tracking ID",
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                          data['trackingID'] ??
                              data['tracking'] ??
                              'Pending Assignment',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF000033))),
                    ],
                  ),
              ],
            ),
          ),
          // --- THE CUSTOMER RETURN SECTION ---
          if (shippingStatus == 'delivered')
            _buildReturnSection(orderId, data, context),
          if (shippingStatus == 'return_requested')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16))),
              child: Text(
                  "Your return request is currently being reviewed by our team.",
                  style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
            ),
          if (shippingStatus == 'refunded')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16))),
              child: const Text(
                  "Return Accepted. Your refund has been processed.",
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
            ),
        ],
      ),
    );
  }

  Widget _buildReturnSection(
      String orderId, Map<String, dynamic> data, BuildContext context) {
    Timestamp? lastUpdate = data['timestamp'] as Timestamp?;
    if (lastUpdate == null) {
      return const SizedBox.shrink();
    }

    DateTime deliveryDate = lastUpdate.toDate();
    int daysSinceDelivery = DateTime.now().difference(deliveryDate).inDays;

    if (daysSinceDelivery <= 7) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Not satisfied?",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red)),
                const SizedBox(height: 2),
                Text("Return window closes in ${7 - daysSinceDelivery} days",
                    style: TextStyle(fontSize: 12, color: Colors.red.shade700)),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0),
              onPressed: () => _showReturnRequestDialog(orderId, context),
              child: const Text("Request Return",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16))),
        child: Text(
            "Return window closed on ${deliveryDate.add(const Duration(days: 7)).toString().split(' ')[0]}",
            style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontStyle: FontStyle.italic)),
      );
    }
  }

  Future<void> _showReturnRequestDialog(
      String orderId, BuildContext context) async {
    final TextEditingController reasonController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Request Return',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF000033))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Why are you returning this item?',
                  style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                    hintText: 'E.g., Item was damaged, changed my mind...',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel",
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000033),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0),
              onPressed: () async {
                final String reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please provide a reason.'),
                      backgroundColor: Colors.orange));
                  return;
                }
                final dialogNavigator = Navigator.of(dialogContext);
                final scMessenger = ScaffoldMessenger.of(context);
                try {
                  await FirebaseFirestore.instance
                      .collection('ShippingInformation')
                      .doc(orderId)
                      .update({
                    'shippingStatus': 'return_requested',
                    'returnReason': reason,
                    'timestamp': Timestamp.now()
                  });
                  dialogNavigator.pop();
                  scMessenger.showSnackBar(const SnackBar(
                      content: Text('Return requested successfully.'),
                      backgroundColor: Colors.green));
                } catch (e) {
                  scMessenger.showSnackBar(SnackBar(
                      content: Text("Error: $e"), backgroundColor: Colors.red));
                }
              },
              child: const Text("Submit Request",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrackingTimeline(String currentStatus) {
    if (currentStatus == 'cancelled') {
      return const SizedBox.shrink();
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
    if (currentIndex == -1) {
      if (['warehouse', 'loading'].contains(currentStatus)) {
        currentIndex = 1;
      } else if (currentStatus != 'pending') {
        currentIndex = 2;
      } else {
        currentIndex = 0;
      }
    }

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
                            width: 2)),
                    child: Icon(trackingSteps[index]["icon"],
                        size: 20, color: iconColor),
                  ),
                  if (!isLast)
                    Container(
                        width: 2,
                        height: 30,
                        color: isCompleted
                            ? Colors.green.shade300
                            : Colors.grey.shade200),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
                  child: Text(trackingSteps[index]["title"],
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.w600,
                          color: isCompleted
                              ? Colors.black87
                              : Colors.grey.shade400)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
