// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/product.dart';
//
// class StoreProvider with ChangeNotifier {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   List<Product> _products = [];
//   List<CartItem> _cart = [];
//   String _selectedCategory = 'All';
//   bool _isLoading = false;
//
//   List<Product> get products => _selectedCategory == 'All'
//       ? _products
//       : _products.where((p) => p.category == _selectedCategory).toList();
//
//   List<String> get categories => ['All', ..._products.map((p) => p.category).toSet().toList()];
//   List<CartItem> get cart => _cart;
//   double get cartTotal => _cart.fold(0, (sum, item) => sum + item.totalPrice);
//   String get selectedCategory => _selectedCategory;
//   bool get isLoading => _isLoading;
//
//   Future<void> loadProducts() async {
//     _isLoading = true;
//     notifyListeners();
//
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
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   void addToCart(Product product) {
//     final index = _cart.indexWhere((item) => item.product.id == product.id);
//     if (index >= 0) {
//       _cart[index].quantity++;
//     } else {
//       _cart.add(CartItem(product: product));
//     }
//     notifyListeners();
//   }
//
//   void removeFromCart(String productId) {
//     _cart.removeWhere((item) => item.product.id == productId);
//     notifyListeners();
//   }
//
//   void updateQuantity(String productId, int quantity) {
//     final index = _cart.indexWhere((item) => item.product.id == productId);
//     if (index >= 0) {
//       _cart[index].quantity = quantity;
//       notifyListeners();
//     }
//   }
//
//   void setCategory(String category) {
//     _selectedCategory = category;
//     notifyListeners();
//   }
//
//   Future<void> placeOrder(String address) async {
//     try {
//       await _firestore.collection('orders').add({
//         'items': _cart.map((item) => {
//           'productId': item.product.id,
//           'name': item.product.name,
//           'quantity': item.quantity,
//           'price': item.product.price,
//         }).toList(),
//         'total': cartTotal,
//         'address': address,
//         'date': FieldValue.serverTimestamp(),
//         'status': 'Pending',
//       });
//       _cart.clear();
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error placing order: $e');
//       rethrow;
//     }
//   }
// }