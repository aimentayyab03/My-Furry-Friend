import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class DescriptionScreen extends StatefulWidget {
  final bool isLostPet; // Flag to distinguish between Lost and Found Pet

  DescriptionScreen({required this.isLostPet});

  @override
  _DescriptionScreenState createState() => _DescriptionScreenState();
}

class _DescriptionScreenState extends State<DescriptionScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  bool _isLoading = false;

  // Pick an image
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Convert image to base64 string
  Future<String> _imageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  // Save pet data
  Future<void> _savePet() async {
    if (_nameController.text.isEmpty ||
        _breedController.text.isEmpty ||
        _colorController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields and select an image")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String base64Image = await _imageToBase64(_image!);

      await FirebaseFirestore.instance.collection(widget.isLostPet ? 'lostPets' : 'foundPets').add({
        'name': _nameController.text,
        'breed': _breedController.text,
        'color': _colorController.text,
        'location': _locationController.text,
        'description': _descriptionController.text,
        'image': base64Image, // Store image as base64
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${widget.isLostPet ? 'Lost' : 'Found'} pet reported successfully!")));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isLostPet ? "Report Lost Pet" : "Report Found Pet")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Pet Name"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _breedController,
                decoration: InputDecoration(labelText: "Breed"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _colorController,
                decoration: InputDecoration(labelText: "Color"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(labelText: "Location"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Description"),
                maxLines: 4,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text("Pick an Image"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoading ? null : _savePet,
                child: _isLoading ? CircularProgressIndicator() : Text("Submit Report"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
