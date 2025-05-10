import 'package:flutter/material.dart';
import 'package:fyp_two/models/petModel.dart'; // adjust import
import 'adopter_chat_screen.dart'; // adjust import

class PetProfileScreen extends StatelessWidget {
  final PetModel pet;

  const PetProfileScreen({Key? key, required this.pet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (pet.imageUrl != null && pet.imageUrl!.isNotEmpty)
              Image.network(pet.imageUrl!, height: 250, fit: BoxFit.cover)
            else
              Image.asset('assets/images/petlogo.png',
                  height: 250, fit: BoxFit.cover), // fallback image

            SizedBox(height: 16),
            Text(
              pet.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (pet.breed != null)
              Text("Breed: ${pet.breed}", style: TextStyle(fontSize: 16)),
            Text(
              "Age: ${pet.age != null ? pet.age.toString() : 'N/A'}",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              "Description: ${pet.description}",
              style: TextStyle(fontSize: 16),
            ),
            if (pet.location != null && pet.location!.isNotEmpty)
              Text("Location: ${pet.location}", style: TextStyle(fontSize: 16)),
            if (pet.price != null)
              Text("Price: \$${pet.price}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),

            // Chat with Owner button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdopterChatScreen(
                      petId: pet.id,
                      ownerId: pet.ownerId,
                    ),
                  ),
                );
              },
              child: Text("Chat with Owner"),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
