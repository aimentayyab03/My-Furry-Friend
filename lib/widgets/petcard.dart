import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PetCard extends StatelessWidget {
  final String petId;
  final String petName;
  final String petImage;
  final String petAbout;
  final VoidCallback onTap;

  const PetCard({
    super.key,
    required this.petId,
    required this.petName,
    required this.petImage,
    required this.petAbout,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            Image.network(petImage),
            ListTile(
              title: Text(petName),
              subtitle: Text(petAbout),
            ),
          ],
        ),
      ),
    );
  }
}
