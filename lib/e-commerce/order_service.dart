import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> placeOrder(List<Map<String, dynamic>> items, String address, double total) async {
    final orderRef = FirebaseFirestore.instance.collection('orders').doc(userId).collection('user_orders').doc();

    await orderRef.set({
      'items': items,
      'address': address,
      'total': total,
      'paymentStatus': 'paid',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Clear cart
    final cartItems = FirebaseFirestore.instance.collection('cart').doc(userId).collection('items');
    final snapshot = await cartItems.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
