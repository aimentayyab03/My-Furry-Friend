// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/product.dart';
//
// class ProductProvider with ChangeNotifier {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // State
//   List<Product> _products = [];
//   List<String> _categories = [];
//   String _selectedCategory = 'All';
//   bool _isLoading = false;
//   String? _error;
//
//   // Getters
//   List<Product> get products => _selectedCategory == 'All'
//       ? _products
//       : _products.where((p) => p.category == _selectedCategory).toList();
//
//   List<String> get categories => _categories;
//   String get selectedCategory => _selectedCategory;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//
//   // Initialize products
//   Future<void> loadProducts() async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
//
//     try {
//       final QuerySnapshot snapshot = await _firestore.collection('products').get();
//
//       _products = snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return Product(
//           id: doc.id,
//           name: data['name'] ?? 'Unnamed Product',
//           description: data['description'] ?? '',
//           price: (data['price'] as num?)?.toDouble() ?? 0.0,
//           imageUrl: data['imageUrl'] ?? '',
//           category: data['category'] ?? 'General',
//           stock: (data['stock'] as num?)?.toInt() ?? 0,
//         );
//       }).toList();
//
//       _categories = ['All', ..._products.map((p) => p.category).toSet().toList()];
//     } catch (e) {
//       _error = 'Failed to load products: ${e.toString()}';
//       debugPrint(_error!);
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   // Category selection
//   void selectCategory(String category) {
//     _selectedCategory = category;
//     notifyListeners();
//   }
//
//   // For debugging - add sample products
//   Future<void> addSampleProducts() async {
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       final sampleProducts = [
//         {
//           'name': 'Premium Dog Food',
//           'description': 'High-quality nutrition for adult dogs',
//           'price': 29.99,
//           'imageUrl': 'https://images.unsplash.com/photo-1589927986089-35812388d1f4',
//           'category': 'Food',
//           'stock': 50,
//         },
//         {
//           'name': 'Cat Toy Set',
//           'description': 'Interactive toys for cats',
//           'price': 15.99,
//           'imageUrl': 'https://images.unsplash.com/photo-1494256997604-768d1f608cac',
//           'category': 'Toys',
//           'stock': 30,
//         },
//       ];
//
//       final batch = _firestore.batch();
//       for (var product in sampleProducts) {
//         final docRef = _firestore.collection('products').doc();
//         batch.set(docRef, product);
//       }
//       await batch.commit();
//
//       await loadProducts(); // Refresh the product list
//     } catch (e) {
//       _error = 'Failed to add samples: ${e.toString()}';
//       debugPrint(_error!);
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }