import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  static Future<void> updateShippingStatus(String orderId, String newStatus) async {
    final firestore = FirebaseFirestore.instance;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('No user is signed in');
    }

    final orderRef = firestore.collection('ShippingInformation').doc(orderId);

    await orderRef.update({
      'shippingStatus': newStatus,
      'timestamp': Timestamp.now(), // Automatically sets the current time
    });
  }
}