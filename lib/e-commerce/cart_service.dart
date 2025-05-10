import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final cartRef = FirebaseFirestore.instance.collection('cart');

  Future<void> addToCart(String productId, Map<String, dynamic> productData) async {
    final itemRef = cartRef.doc(userId).collection('items').doc(productId);

    final snapshot = await itemRef.get();
    if (snapshot.exists) {
      await itemRef.update({'quantity': FieldValue.increment(1)});
    } else {
      productData['quantity'] = 1;
      await itemRef.set(productData);
    }
  }

  Future<void> removeFromCart(String productId) async {
    await cartRef.doc(userId).collection('items').doc(productId).delete();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(productId);
    } else {
      await cartRef.doc(userId).collection('items').doc(productId).update({'quantity': quantity});
    }
  }

  Stream<QuerySnapshot> getCartItemsStream() {
    return cartRef.doc(userId).collection('items').snapshots();
  }
}
