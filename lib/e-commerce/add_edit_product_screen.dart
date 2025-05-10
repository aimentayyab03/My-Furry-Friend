import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEditProductScreen extends StatefulWidget {
  final String? productId;

  AddEditProductScreen({this.productId});

  @override
  _AddEditProductScreenState createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String? selectedCategory;

  bool isLoading = false;

  final List<String> categories = [
    'Food',
    'Toys',
    'Accessories',
    'Grooming',
    'Medicine'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      loadProduct();
    }
  }

  Future<void> loadProduct() async {
    final doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      _nameController.text = data['name'];
      _priceController.text = data['price'].toString();
      _imageUrlController.text = data['imageUrl'];
      selectedCategory = data['category'];
      setState(() {});
    }
  }

  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final data = {
      'name': _nameController.text.trim(),
      'price': double.parse(_priceController.text.trim()),
      'imageUrl': _imageUrlController.text.trim(),
      'category': selectedCategory,
      'sellerId': FirebaseAuth.instance.currentUser!.uid,
    };

    final docRef = FirebaseFirestore.instance.collection('products');

    if (widget.productId == null) {
      await docRef.add(data);
    } else {
      await docRef.doc(widget.productId).update(data);
    }

    setState(() => isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId == null ? "Add Product" : "Edit Product"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
                validator: (value) =>
                value!.isEmpty ? 'Enter product name' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Enter price' : null,
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'Image URL'),
                validator: (value) =>
                value!.isEmpty ? 'Enter image URL' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Category'),
                validator: (value) =>
                value == null ? 'Select a category' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveProduct,
                child: Text(widget.productId == null
                    ? "Add Product"
                    : "Update Product"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
