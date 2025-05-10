import 'package:flutter/material.dart';
import 'adopter_dashboard.dart';

class AdopterLandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Cute gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF71C9F8), // Light blue sky
                  Color(0xFF29B6F6), // Medium blue
                ],
              ),
            ),
          ),

          // Decorative clouds
          Positioned(
            top: 50,
            left: 20,
            child: _buildCloud(80),
          ),
          Positioned(
            top: 30,
            right: 40,
            child: _buildCloud(60),
          ),
          Positioned(
            top: 150,
            left: 60,
            child: _buildCloud(50),
          ),

          // House and grass
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Color(0xFF8BC34A), // Grass green
              ),
            ),
          ),

          // House
          Positioned(
            bottom: 150,
            right: 40,
            child: Container(
              height: 120,
              width: 100,
              decoration: BoxDecoration(
                color: Color(0xFFFFF59D), // Light yellow house
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Roof
                  Positioned(
                    top: -20,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xFFFF7043), // Orange-red roof
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // Door
                  Positioned(
                    bottom: 0,
                    left: 35,
                    child: Container(
                      height: 40,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Color(0xFF795548), // Brown door
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pet illustration
          Positioned(
            bottom: 200,
            left: 50,
            child: Image.asset(
              "assets/pet_illustration.png", // Make sure to add this cute illustration to assets
              height: 200,
            ),
          ),

          // Main content
          Positioned(
            top: 120,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  "Adopt a Pet",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(2, 2),
                      )
                    ],
                  ),
                ),
                Text(
                  "Save Their Life",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(2, 2),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "Start adoption to give them a fur-ever home!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 280),
                // Button container
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRoundedButton("Login", Colors.white, Color(0xFF5C6BC0), () {}),
                    SizedBox(width: 20),
                    _buildRoundedButton("Sign Up", Color(0xFF5C6BC0), Colors.white, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AdopterDashboard()));
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create cloud shapes
  Widget _buildCloud(double size) {
    return Container(
      width: size,
      height: size * 0.6,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(size / 2),
      ),
    );
  }

  // Helper method for buttons
  Widget _buildRoundedButton(String text, Color bgColor, Color textColor, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}