import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  final String userId;

  const EditProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: Center(
        child: Text("Edit profile screen for user $userId (Coming Soon!)"),
      ),
    );
  }
}
