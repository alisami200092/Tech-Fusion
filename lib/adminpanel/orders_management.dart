import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class OrdersManagementPage extends StatefulWidget {
  const OrdersManagementPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OrdersManagementPageState createState() => _OrdersManagementPageState();
}

class _OrdersManagementPageState extends State<OrdersManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _shippingSteps = [
    "warehouse",
    "loading",
    "in_transit",
    "departed",
    "arrived",
    "custom_clearance",
    "out_for_delivery",
    "delivered"
  ];

  Color _getStatusColor(String status) {
    if (_shippingSteps.contains(status) && status != 'delivered') {
      return Colors.purple;
    }
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'return_requested':
        return Colors.orange;
      case 'refunded':
        return Colors.green;
      case 'return_rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _generateTrackingId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    String randomPart =
        List.generate(10, (index) => chars[rnd.nextInt(chars.length)]).join();
    return 'TF-$randomPart';
  }

  String _generateExpectedDate() {
    final date = DateTime.now().add(const Duration(days: 5));
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // ===== STRICTER REFUND LOGIC =====
  Future<void> _processReturn(
      String orderId, String newStatus, BuildContext context,
      {required bool rejected, String? userId, double? refundAmount}) async {
    final scMessenger = ScaffoldMessenger.of(context);

    // Show a loading circle to prevent double-tapping!
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      // If approved, process the wallet refund first!
      if (!rejected) {
        // STRICT CHECKS: Don't fail silently anymore!
        if (userId == null || userId.isEmpty) {
          throw Exception("Cannot refund: No User ID attached to this order.");
        }
        if (refundAmount == null || refundAmount <= 0) {
          throw Exception("Cannot refund: Order amount is invalid or zero.");
        }

        // Add the money to the wallet
        await _firestore.collection('users').doc(userId).update({
          'walletBalance': FieldValue.increment(refundAmount),
        });
      }

      // Then update the order status
      await _firestore.collection('ShippingInformation').doc(orderId).update({
        'shippingStatus': newStatus,
        'refundStatus': rejected ? 'rejected' : 'approved',
        'timestamp': Timestamp.now(),
      });

      if (!context.mounted) return;
      Navigator.pop(context); // Close the loading dialog

      scMessenger.showSnackBar(SnackBar(
        content: Text(rejected
            ? 'Return request rejected.'
            : '✅ Return approved. \$${refundAmount?.toStringAsFixed(2)} refunded to user wallet.'),
        backgroundColor: rejected ? Colors.orange : Colors.green,
      ));
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close the loading dialog on error
      scMessenger.showSnackBar(
          SnackBar(content: Text("$e"), backgroundColor: Colors.red));
    }
  }

  Future<void> _showUpdateStatusDialog(
      DocumentSnapshot orderDoc, BuildContext context) async {
    final Map<String, dynamic> orderData =
        orderDoc.data() as Map<String, dynamic>;
    String currentShippingStatus =
        (orderData['shippingStatus'] ?? "pending").toString().toLowerCase();

    List<String> allValidStatuses = [
      "pending",
      "approved",
      "warehouse",
      "loading",
      "in_transit",
      "departed",
      "arrived",
      "custom_clearance",
      "out_for_delivery",
      "delivered",
      "cancelled"
    ];
    String selectedStatus = allValidStatuses.contains(currentShippingStatus)
        ? currentShippingStatus
        : "pending";

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Update Shipping Status',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF000033))),
          content: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              return DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none)),
                dropdownColor: Colors.white,
                items: allValidStatuses
                    .map((status) => DropdownMenuItem<String>(
                        value: status,
                        child: Text(status.replaceAll('_', ' ').capitalize(),
                            style:
                                const TextStyle(fontWeight: FontWeight.w500))))
                    .toList(),
                onChanged: (newValue) =>
                    setState(() => selectedStatus = newValue!),
              );
            },
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text("Cancel",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000033),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0),
              onPressed: () async {
                final dialogNavigator = Navigator.of(dialogContext);
                final scMessenger = ScaffoldMessenger.of(context);
                try {
                  Map<String, dynamic> updatePayload = {
                    'shippingStatus': selectedStatus,
                    'timestamp': Timestamp.now()
                  };
                  bool isShippingPhase = [
                    "warehouse",
                    "loading",
                    "in_transit",
                    "shipped",
                    "departed",
                    "arrived",
                    "custom_clearance",
                    "out_for_delivery",
                    "delivered"
                  ].contains(selectedStatus);
                  String currentTracking =
                      (orderData['trackingID'] ?? '').toString().trim();

                  if (isShippingPhase && currentTracking.length < 5) {
                    updatePayload['trackingID'] = _generateTrackingId();
                    updatePayload['expectedArrival'] = _generateExpectedDate();
                  }

                  await _firestore
                      .collection('ShippingInformation')
                      .doc(orderDoc.id)
                      .update(updatePayload);
                  dialogNavigator.pop();
                  if (!mounted) return;
                  scMessenger.showSnackBar(SnackBar(
                      content: Text(
                          'Status updated to ${selectedStatus.replaceAll('_', ' ').capitalize()}'),
                      backgroundColor: Colors.green));
                } catch (e) {
                  if (!mounted) return;
                  scMessenger.showSnackBar(SnackBar(
                      content: Text("Error: $e"), backgroundColor: Colors.red));
                }
              },
              child:
                  const Text("Update", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteOrderDialog(DocumentSnapshot orderDoc) async {
    final TextEditingController reasonController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Cancel Order',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          content: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Please provide a reason for cancellation:',
                      style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(height: 12),
                  TextField(
                      controller: reasonController,
                      decoration: InputDecoration(
                          hintText: 'Enter reason here',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none))),
                ],
              );
            },
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text("Keep Order",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0),
              onPressed: () async {
                final String reason = reasonController.text.trim();
                if (reason.isEmpty) return;

                final dialogNavigator = Navigator.of(dialogContext);
                final scMessenger = ScaffoldMessenger.of(context);
                try {
                  await _firestore
                      .collection('ShippingInformation')
                      .doc(orderDoc.id)
                      .update({
                    'shippingStatus': 'cancelled',
                    'cancellationReason': reason,
                    'refundStatus': 'pending',
                    'timestamp': Timestamp.now()
                  });
                  dialogNavigator.pop();
                  if (!mounted) return;
                  scMessenger.showSnackBar(const SnackBar(
                      content:
                          Text('Order cancelled. Refund process initiated.'),
                      backgroundColor: Colors.red));
                } catch (e) {
                  if (!mounted) return;
                  scMessenger.showSnackBar(SnackBar(
                      content: Text("Error: $e"), backgroundColor: Colors.red));
                }
              },
              child: const Text("Yes, Cancel",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShippingTimeline(Map<String, dynamic> data) {
    final String currentStatus =
        (data['shippingStatus'] ?? 'pending').toString().toLowerCase();
    int currentIndex = _shippingSteps.indexOf(currentStatus);
    if (currentIndex == -1) currentIndex = 0;

    List<Widget> timelineTiles = [];
    for (int i = 0; i < _shippingSteps.length; i++) {
      bool isCompleted = (i <= currentIndex);
      timelineTiles.add(
        TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.1,
          isFirst: i == 0,
          isLast: i == _shippingSteps.length - 1,
          indicatorStyle: IndicatorStyle(
              width: 24,
              color: isCompleted ? Colors.green : Colors.grey.shade300,
              iconStyle: IconStyle(
                  iconData: isCompleted ? Icons.check : Icons.circle,
                  color: Colors.white,
                  fontSize: 14)),
          beforeLineStyle: LineStyle(
              color: isCompleted ? Colors.green : Colors.grey.shade300,
              thickness: 2),
          endChild: Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, bottom: 20.0, top: 4.0),
              child: Text(_shippingSteps[i].replaceAll('_', ' ').capitalize(),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isCompleted ? FontWeight.bold : FontWeight.w500,
                      color: isCompleted
                          ? Colors.black87
                          : Colors.grey.shade400))),
        ),
      );
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: timelineTiles);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text('Orders Management',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('ShippingInformation')
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

                if (snapshot.hasData) {
                  final List<DocumentSnapshot> orders = snapshot.data!.docs;
                  if (orders.isEmpty) {
                    return const Center(
                        child: Text('No orders found.',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 16)));
                  }

                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot order = orders[index];
                      final Map<String, dynamic> orderData =
                          order.data() as Map<String, dynamic>;
                      final String shippingStatus =
                          (orderData['shippingStatus'] ?? "pending")
                              .toString()
                              .toLowerCase();

                      // Grab the userId and totalAmount to pass to our new refund system!
                      final String userId =
                          (orderData['userId'] ?? orderData['uid'] ?? '')
                              .toString();
                      final double totalAmount = (orderData['totalAmount'] ??
                              orderData['totalPrice'] ??
                              0.0)
                          .toDouble();

                      Color badgeColor = _getStatusColor(shippingStatus);
                      bool showTimeline =
                          _shippingSteps.contains(shippingStatus) ||
                              shippingStatus == 'shipped';

                      String displayStatus =
                          shippingStatus.replaceAll('_', ' ').capitalize();
                      if (shippingStatus == 'return_requested') {
                        displayStatus = 'Return Requested';
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4))
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Text('Order ID: ${order.id}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0xFF000033)),
                                          overflow: TextOverflow.ellipsis)),
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                          color:
                                              badgeColor.withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Text(displayStatus,
                                          style: TextStyle(
                                              color: badgeColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12))),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (shippingStatus == 'pending' ||
                                  shippingStatus == 'approved') ...[
                                Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: const Row(children: [
                                      Icon(Icons.info_outline,
                                          color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text("Waiting for warehouse processing.",
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w500))
                                    ])),
                                const SizedBox(height: 16),
                              ],
                              if (showTimeline) ...[
                                const Divider(),
                                const SizedBox(height: 8),
                                _buildShippingTimeline(orderData),
                                const SizedBox(height: 8),
                                const Divider(),
                              ],
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Expected Arrival: ${orderData['expectedArrival'] ?? 'TBD'}",
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600)),
                                      const SizedBox(height: 4),
                                      Text(
                                          "Tracking ID: ${orderData['trackingID'] ?? orderData['tracking'] ?? 'Pending Assignment'}",
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      if (shippingStatus !=
                                              'return_requested' &&
                                          shippingStatus != 'refunded' &&
                                          shippingStatus != 'return_rejected')
                                        IconButton(
                                            icon: const Icon(
                                                Icons.edit_outlined,
                                                color: Color(0xFF000033)),
                                            tooltip: 'Update Status',
                                            onPressed: () =>
                                                _showUpdateStatusDialog(
                                                    order, context)),
                                      if (shippingStatus != 'cancelled' &&
                                          shippingStatus != 'delivered' &&
                                          shippingStatus !=
                                              'return_requested' &&
                                          shippingStatus != 'refunded' &&
                                          shippingStatus != 'return_rejected')
                                        IconButton(
                                            icon: const Icon(
                                                Icons.cancel_outlined,
                                                color: Colors.red),
                                            tooltip: 'Cancel Order',
                                            onPressed: () =>
                                                _showDeleteOrderDialog(order)),
                                    ],
                                  ),
                                ],
                              ),
                              // --- ADMIN RETURN ACTION HANDLER ---
                              if (shippingStatus == 'return_requested') ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.orange.shade200)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(children: [
                                        Icon(Icons.assignment_return,
                                            color: Colors.orange),
                                        SizedBox(width: 8),
                                        Text("Return Requested",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange,
                                                fontSize: 16))
                                      ]),
                                      const SizedBox(height: 8),
                                      Text(
                                          "Reason: ${orderData['returnReason'] ?? 'No reason provided'}",
                                          style: TextStyle(
                                              color: Colors.grey.shade800,
                                              fontStyle: FontStyle.italic)),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: OutlinedButton(
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                          foregroundColor:
                                                              Colors.red,
                                                          side:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .red)),
                                                  onPressed: () =>
                                                      _processReturn(
                                                          order.id,
                                                          'return_rejected',
                                                          context,
                                                          rejected: true),
                                                  child: const Text("Reject"))),
                                          const SizedBox(width: 12),
                                          Expanded(
                                              child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.green,
                                                          elevation: 0),
                                                  onPressed: () =>
                                                      _processReturn(order.id,
                                                          'refunded', context,
                                                          rejected: false,
                                                          userId: userId,
                                                          refundAmount:
                                                              totalAmount),
                                                  child: const Text(
                                                      "Approve & Refund",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.white)))),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text('No orders found.'));
              },
            ),
          ),
        ),
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
