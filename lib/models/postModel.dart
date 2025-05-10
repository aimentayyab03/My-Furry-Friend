class PostModel {
  final String id;
  final String petName;
  final String petImage;
  final String petAbout;
  final String ownerId;

  PostModel({
    required this.id,
    required this.petName,
    required this.petImage,
    required this.petAbout,
    required this.ownerId,
  });

  // Factory constructor to create an instance from Firestore data
  factory PostModel.fromMap(Map<String, dynamic> data) {
    return PostModel(
      id: data['id'] ?? '',
      petName: data['petName'] ?? 'Unknown Pet',
      petImage: data['petImage'] ?? 'https://via.placeholder.com/150',
      petAbout: data['petAbout'] ?? 'No description available',
      ownerId: data['ownerId'] ?? '',
    );
  }

  // Convert an instance to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petName': petName,
      'petImage': petImage,
      'petAbout': petAbout,
      'ownerId': ownerId,
    };
  }
}
