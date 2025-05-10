import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_two/e-commerce/seller_home_screen.dart';
import 'package:fyp_two/screens/lib/adopter_landing_screen.dart';
import 'package:fyp_two/screens/petdetails.dart';

class UserType extends StatefulWidget {
  const UserType({super.key});

  @override
  _UserTypeState createState() => _UserTypeState();
}

class _UserTypeState extends State<UserType> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void saveUserType(String userType) async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .set({'userType': userType}, SetOptions(merge: true));

        if (userType == 'Pet Owner') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PetDetails()),
          );
        } else if ( userType == 'Pet Adopter') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdopterLandingScreen()),
          );
        }
        else if ( userType == 'Pet Accessory Seller') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SellerHomeScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No user is signed in.'),
            backgroundColor: const Color(0xFFFF8844),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save user type: ${e.toString()}'),
          backgroundColor: const Color(0xFFFF8844),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pet-themed color palette
    const Color primaryColor = Color(0xFF55AAEE); // Sky blue
    const Color accentColor = Color(0xFFFF8844); // Warm orange
    const Color backgroundColor = Color(0xFFF5FAFF); // Light blue background

    return Scaffold(
      body: Stack(
        children: [
          // Background with cute pet-themed pattern
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  backgroundColor,
                  primaryColor.withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Decorative paw prints
          Positioned(
            top: 40,
            left: 20,
            child: Icon(
              Icons.pets,
              size: 28,
              color: primaryColor.withOpacity(0.3),
            ),
          ),
          Positioned(
            top: 80,
            left: 60,
            child: Icon(
              Icons.pets,
              size: 20,
              color: primaryColor.withOpacity(0.3),
            ),
          ),
          Positioned(
            bottom: 60,
            right: 30,
            child: Icon(
              Icons.pets,
              size: 32,
              color: primaryColor.withOpacity(0.3),
            ),
          ),
          Positioned(
            bottom: 100,
            right: 80,
            child: Icon(
              Icons.pets,
              size: 24,
              color: primaryColor.withOpacity(0.3),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // Header with animation
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.elasticOut,
                    )),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Who's Using My Furry Friend?",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Choose your role to continue",
                            style: TextStyle(
                              fontSize: 16,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // User Type Options
                  Expanded(
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeOutCubic,
                      )),
                      child: FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: const Interval(0.4, 1.0),
                          ),
                        ),
                        child: GridView.count(
                          crossAxisCount: 1,
                          childAspectRatio: 2.5,
                          mainAxisSpacing: 20,
                          children: [
                            userTypeButton(
                              'Pet Owner',
                              Icons.pets,
                                  () => saveUserType('Pet Owner'),
                              primaryColor,
                              accentColor,
                              'Take care of your pets',
                            ),
                            userTypeButton(
                              'Pet Accessory Seller',
                              Icons.storefront,
                                  () => saveUserType('Pet Accessory Seller'),
                              primaryColor,
                              accentColor,
                              'Sell pet products and accessories',
                            ),
                            userTypeButton(
                              'Pet Adopter',
                              Icons.favorite,
                                  () => saveUserType('Pet Adopter'),
                              primaryColor,
                              accentColor,
                              'Find a new furry friend to adopt',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget userTypeButton(
      String label,
      IconData icon,
      VoidCallback onTap,
      Color primaryColor,
      Color accentColor,
      String description,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.15),
              ),
              child: Icon(
                icon,
                size: 32,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: primaryColor,
              size: 16,
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}