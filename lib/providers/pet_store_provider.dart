// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/product.dart';
//
// class PetStoreProvider with ChangeNotifier {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   List<Product> _products = [];
//   List<Product> _cart = [];
//   String _selectedCategory = 'All';
//
//   List<Product> get products => _selectedCategory == 'All'
//       ? _products
//       : _products.where((p) => p.category == _selectedCategory).toList();
//
//   List<String> get categories => ['All', ..._products.map((p) => p.category).toSet().toList()];
//   List<Product> get cart => _cart;
//   String get selectedCategory => _selectedCategory;
//
//   Future<void> loadProducts() async {
//     try {
//       final snapshot = await _firestore.collection('products').get();
//       _products = snapshot.docs.map((doc) {
//         return Product(
//           id: doc.id,
//           name: doc['name'],
//           description: doc['description'],
//           price: doc['price'].toDouble(),
//           imageUrl: doc['imageUrl'],
//           category: doc['category'],
//           stock: doc['stock'],
//         );
//       }).toList();
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error loading products: $e');
//     }
//   }
//
//   void addToCart(Product product) {
//     _cart.add(product);
//     notifyListeners();
//   }
//
//   void removeFromCart(Product product) {
//     _cart.remove(product);
//     notifyListeners();
//   }
//
//   void setCategory(String category) {
//     _selectedCategory = category;
//     notifyListeners();
//   }
//
//   void clearCart() {
//     _cart.clear();
//     notifyListeners();
//   }
// }