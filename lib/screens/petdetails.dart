import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pethomepage.dart';

class PetDetails extends StatefulWidget {
  const PetDetails({super.key});

  @override
  State<PetDetails> createState() => _PetDetailsState();
}

class _PetDetailsState extends State<PetDetails> {
  final TextEditingController petNameController = TextEditingController();
  final TextEditingController petAgeController = TextEditingController();
  final TextEditingController petColorController = TextEditingController();
  final TextEditingController petWeightController = TextEditingController();
  final TextEditingController petHeightController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false; // Variable to control the loading state

  // Submit pet details to Firestore
  void _submitDetails(BuildContext context) async {
    String petName = petNameController.text.trim();
    String petAge = petAgeController.text.trim();
    String petColor = petColorController.text.trim();
    String petWeight = petWeightController.text.trim();
    String petHeight = petHeightController.text.trim();

    // Check if all fields are filled
    if (petName.isEmpty ||
        petAge.isEmpty ||
        petColor.isEmpty ||
        petWeight.isEmpty ||
        petHeight.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
    } else {
      setState(() {
        isLoading = true; // Show loading indicator
      });

      try {
        User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          // Save pet details to Firestore
          await _firestore.collection('users').doc(currentUser.uid).set({
            'pet': {
              'name': petName,
              'age': petAge,
              'color': petColor,
              'weight': petWeight,
              'height': petHeight,
            },
          }, SetOptions(merge: true)); // Merge to avoid overwriting other data

          // Show success message and navigate to Pethomepage
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pet details saved successfully!")),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  Pethomepage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No user signed in")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('Enter Pet Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Pet Details Form',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: petNameController,
                decoration: const InputDecoration(
                  labelText: 'Pet Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: petAgeController,
                decoration: const InputDecoration(
                  labelText: 'Pet Age (e.g., 1y 4m)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: petColorController,
                decoration: const InputDecoration(
                  labelText: 'Pet Color',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: petWeightController,
                decoration: const InputDecoration(
                  labelText: 'Pet Weight (e.g., 15 kg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: petHeightController,
                decoration: const InputDecoration(
                  labelText: 'Pet Height (e.g., 30 cm)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              // Show a loading indicator if the form is being submitted
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () => _submitDetails(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    petNameController.dispose();
    petAgeController.dispose();
    petColorController.dispose();
    petWeightController.dispose();
    petHeightController.dispose();
    super.dispose();
  }
}
