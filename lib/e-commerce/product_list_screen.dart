import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_two/e-commerce/cart_service.dart';
import 'package:fyp_two/e-commerce/product_card.dart';
import 'package:fyp_two/e-commerce/product_model.dart';
import 'package:fyp_two/e-commerce/cart_screen.dart'; // Ensure this exists

class ProductListScreen extends StatefulWidget {
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String selectedCategory = 'All';

  List<String> categories = ['All', 'Food', 'Toys', 'Grooming', 'Accessories'];

  Future<List<ProductModel>> fetchProducts() async {
    QuerySnapshot snapshot;

    if (selectedCategory == 'All') {
      snapshot = await FirebaseFirestore.instance.collection('products').get();
    } else {
      snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('category', isEqualTo: selectedCategory)
          .get();
    }

    return snapshot.docs.map((doc) =>
        ProductModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shop for your Pet"),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CartScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category selection
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selectedCategory == cat,
                    onSelected: (_) => setState(() => selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          // Product Grid
          Expanded(
            child: FutureBuilder<List<ProductModel>>(
              future: fetchProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());

                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  return Center(child: Text("No products found"));

                return GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final product = snapshot.data![index];
                    return ProductCard(
                      product: product,
                      onAddToCart: () {
                        CartService().addToCart(product.id, {
                          'name': product.name,
                          'price': product.price,
                          'imageUrl': product.imageUrl
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${product.name} added to cart')),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CartScreen()),
          );
        },
        label: Text("View Cart"),
        icon: Icon(Icons.shopping_bag),
      ),
    );
  }
}
