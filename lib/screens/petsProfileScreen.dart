import 'package:flutter/material.dart';
import 'package:fyp_two/widgets/petcard.dart';

import '../models/petModel.dart';

class PetsProfileScreen extends StatelessWidget {
  final String petId;
  final String petName;
  final String petImage;
  final String petAbout;

  const PetsProfileScreen({
    super.key,
    required this.petId,
    required this.petName,
    required this.petImage,
    required this.petAbout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(petName)),
      body: ListView(
        children: [
          PetCard(
            petId: petId,
            petName: petName,
            petImage: petImage,
            petAbout: petAbout,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetDetailsScreen(
                    petId: petId,
                    petName: petName,
                    petImage: petImage,
                    petAbout: petAbout,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Example Detailed Pet Profile Screen
class PetDetailsScreen extends StatelessWidget {
  final String petId;
  final String petName;
  final String petImage;
  final String petAbout;

  const PetDetailsScreen({
    super.key,
    required this.petId,
    required this.petName,
    required this.petImage,
    required this.petAbout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(petName)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            backgroundImage: NetworkImage(petImage),
            radius: 50,
          ),
          const SizedBox(height: 10),
          Text(
            petName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            petAbout,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
