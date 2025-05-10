import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_edit_product_screen.dart';

class SellerHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseFirestore.instance; // For seller filtering if needed

    return Scaffold(
      appBar: AppBar(title: Text("Seller Dashboard")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('sellerId', isEqualTo: userId.app.options.projectId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final products = snapshot.data!.docs;

          if (products.isEmpty)
            return Center(child: Text("No products added"));

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final data = products[index].data() as Map<String, dynamic>;
              final productId = products[index].id;

              return ListTile(
                leading: Image.network(data['imageUrl'], width: 50),
                title: Text(data['name']),
                subtitle: Text(
                  data['category'] != null && data['category'].toString().isNotEmpty
                      ? "₹${data['price']} • ${data['category']}"
                      : "₹${data['price']} • ⚠ No Category",
                  style: data['category'] == null
                      ? TextStyle(color: Colors.red)
                      : null,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditProductScreen(productId: productId),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('products')
                            .doc(productId)
                            .delete();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditProductScreen()),
          );
        },
      ),
    );
  }
}
