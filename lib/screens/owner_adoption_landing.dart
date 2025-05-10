import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp_two/screens/lib/adopter_dashboard.dart';
import 'package:fyp_two/screens/put_pet_for_adoption.dart';
import 'lib/adopter_landing_screen.dart';

class OwnerAdoptionLanding extends StatelessWidget {
  const OwnerAdoptionLanding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pet-themed color palette
    final primaryColor = Color(0xFF5B8EFF); // Blue
    final secondaryColor = Color(0xFFFF85A2); // Pink
    final accentColor = Color(0xFFFFC85C); // Orange/Yellow
    final backgroundColor = Color(0xFFF0F7FF); // Light blue background

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Adoption Portal",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Semi-transparent background overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  backgroundColor.withOpacity(0.7),
                  Colors.white.withOpacity(0.9),
                ],
              ),
            ),
          ),

          // Background Image with opacity
          Opacity(
            opacity: 0.2,
            child: Image.asset(
              'assets/images/petlogo.png',
              fit: BoxFit.cover,
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title card
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.pets,
                        size: 60,
                        color: secondaryColor,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Welcome to Adoption Portal",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Give a pet a forever home or help a pet find one",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40),

                // Put Pet for Adoption Button
                buildButton(
                  context: context,
                  label: "Put Pet for Adoption",
                  icon: Icons.volunteer_activism,
                  color: secondaryColor,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PutPetForAdoption(),
                      ),
                    );
                  },
                ),

                SizedBox(height: 20),

                // Adopt Another Pet Button
                buildButton(
                  context: context,
                  label: "Adopt Another Pet",
                  icon: Icons.favorite,
                  color: accentColor,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>AdopterDashboard(),
                      ),
                    );
                  },
                ),

                SizedBox(height: 40),

                // Small paw prints decoration
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                        (index) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.pets,
                        size: 14,
                        color: index % 2 == 0 ? primaryColor : secondaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}