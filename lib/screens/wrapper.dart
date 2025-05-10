import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_two/screens/login.dart';
import 'package:fyp_two/screens/pethomepage.dart';
import '../services/firestore_service.dart';

class Wrapper extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Login();
        }

        final User user = snapshot.data!;
        if (user.email == null || user.email!.isEmpty) {
          return const Login();
        }
        return FutureBuilder<bool>(
          future: _firestoreService.userExists(user.email!),
          builder: (context, userExistsSnapshot) {
            if (userExistsSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (userExistsSnapshot.hasData && userExistsSnapshot.data!) {
              return  Pethomepage();
            } else {
              return const Login();
            }
          },
        );
      },
    );
  }
}
