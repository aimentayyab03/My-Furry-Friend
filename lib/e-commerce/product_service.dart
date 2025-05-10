import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addProduct(Map<String, dynamic> productData) async {
    final sellerId = _auth.currentUser!.uid;
    final productRef = FirebaseFirestore.instance.collection('products').doc();

    productData['sellerId'] = sellerId;
    await productRef.set(productData);
  }

  Future<void> editProduct(String productId, Map<String, dynamic> productData) async {
    final productRef = FirebaseFirestore.instance.collection('products').doc(productId);
    await productRef.update(productData);
  }

  Future<void> deleteProduct(String productId) async {
    final productRef = FirebaseFirestore.instance.collection('products').doc(productId);
    await productRef.delete();
  }

  Stream<QuerySnapshot> getSellerProductsStream() {
    final sellerId = _auth.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots();
  }
}
