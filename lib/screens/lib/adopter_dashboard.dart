import 'package:flutter/material.dart';
import 'package:fyp_two/models/petModel.dart';
import 'package:fyp_two/screens/pet_profile_screen.dart';

import '../../services/firestore_service.dart';
// If ProfileScreen is not used, you can remove the import below.
// import '../profile_screen.dart';

class AdopterDashboard extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Choose a Pet")),
      body: StreamBuilder<List<PetModel>>(
        stream: _firestoreService.getAdoptionPets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No pets available for adoption."));
          }

          List<PetModel> pets = snapshot.data!;

          return ListView.builder(
            itemCount: pets.length,
            itemBuilder: (context, index) {
              PetModel pet = pets[index];

              return Card(
                child: ListTile(
                  // Safely check for a non-empty imageUrl before displaying
                  leading: (pet.imageUrl != null && pet.imageUrl!.isNotEmpty)
                      ? Image.network(
                    pet.imageUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : Icon(Icons.pets, size: 50),
                  title: Text(pet.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Breed: ${pet.breed}"),
                      Text("Age: ${pet.age ?? 'N/A'} years"),
                      Text("Location: ${pet.location}"),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PetProfileScreen(pet: pet),
                        ),
                      );
                    },
                    child: Text("View Pet"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
