import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_two/e-commerce/cart_service.dart';
import 'package:fyp_two/e-commerce/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  final cartService = CartService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Cart")),
      body: StreamBuilder<QuerySnapshot>(
        stream: cartService.getCartItemsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final items = snapshot.data!.docs;

          if (items.isEmpty) return Center(child: Text("Cart is empty"));

          double total = 0;
          items.forEach((doc) {
            final data = doc.data() as Map<String, dynamic>;
            total += data['price'] * data['quantity'];
          });

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final doc = items[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final productId = doc.id;

                    return ListTile(
                      leading: data['imageUrl'] != null
                          ? Image.network(data['imageUrl'], width: 50)
                          : Icon(Icons.image_not_supported),
                      title: Text(data['name']),
                      subtitle: Text("₹${data['price']} x ${data['quantity']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              if (data['quantity'] > 1) {
                                cartService.updateQuantity(productId, data['quantity'] - 1);
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              cartService.updateQuantity(productId, data['quantity'] + 1);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              cartService.removeFromCart(productId);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "Total: ₹${total.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      child: Text("Proceed to Checkout"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckoutScreen(cartItems: items, total: total),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
