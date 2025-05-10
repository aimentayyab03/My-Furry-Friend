import 'package:flutter/material.dart';
import 'package:fyp_two/services/firestore_service.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final FirestoreService _firestoreService = FirestoreService();
  bool isLoading = false;

  // Function to update user profile
  void _updateUserProfile(String userId) async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> updatedData = {
      'username': 'Updated Username',
      'email': 'updatedemail@example.com',
    };

    try {
      await _firestoreService.updateUserDocument(userId, updatedData);
      _showSnackBar('Profile updated successfully');
    } catch (e) {
      _showSnackBar('Failed to update profile: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to show a snackbar with a message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String userId = 'poRkQtRgAoPvHGmHt6LtmGg7Y9l1';

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () => _updateUserProfile(userId),
                child: const Text('Update Profile'),
              ),
      ),
    );
  }
}
