import 'package:cloud_firestore/cloud_firestore.dart';

class PetModel {
  final String id;
  final String name;
  final String type;
  final String breed;
  final int? age;
  final String price;
  final String location;
  final String? imageUrl;
  final String ownerId;
  final String? description; // <-- Add description field

  PetModel({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    this.age,
    required this.price,
    required this.location,
    this.imageUrl,
    required this.ownerId,
    this.description,        // <-- Include in constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'breed': breed,
      'age': age ?? 0,           // Handle null age
      'price': price,
      'location': location,
      'imageUrl': imageUrl ?? '',// Default empty string for missing images
      'ownerId': ownerId,        // Include ownerId in map
      'description': description ?? '', // Include description in map
    };
  }

  factory PetModel.fromMap(Map<String, dynamic> map) {
    return PetModel(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unknown',
      type: map['type'] ?? 'Unknown',
      breed: map['breed'] ?? 'Unknown',
      age: map['age'] != null ? (map['age'] as num).toInt() : null,
      price: map['price'] ?? 'N/A',
      location: map['location'] ?? 'Unknown',
      imageUrl: map['imageUrl'] ?? '',
      ownerId: map['ownerId'] ?? '',
      description: map['description'] ?? '', // Retrieve description
    );
  }

  /// Use the Firestore document ID as the pet's [id].
  factory PetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id; // Assign the document ID to 'id'
    return PetModel.fromMap(data);
  }
}
