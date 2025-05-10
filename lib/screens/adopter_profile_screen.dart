import 'package:flutter/material.dart';

class AdopterProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Pet-themed color palette
    const Color primaryColor = Color(0xFF6A9ECF); // Soft blue
    const Color secondaryColor = Color(0xFFFFA5BA); // Soft pink
    const Color accentColor = Color(0xFFFFD166); // Warm yellow
    const Color backgroundColor = Color(0xFFF8F9FA); // Light background
    const Color textColor = Color(0xFF4A4A4A); // Dark gray for text

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          "My Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: secondaryColor,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage("https://via.placeholder.com/150"),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Username",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.email, "Email", "example@gmail.com", textColor),
                    Divider(),
                    _buildInfoRow(Icons.location_city, "City", "New York", textColor),
                  ],
                ),
              ),
              SizedBox(height: 24),
              _buildButton(
                "Edit Profile",
                primaryColor,
                Icons.edit,
                    () {
                  // Implement edit profile
                },
              ),
              SizedBox(height: 12),
              _buildButton(
                "Delete Account",
                secondaryColor,
                Icons.delete_outline,
                    () {
                  // Implement delete account
                },
                isOutlined: true,
              ),
              SizedBox(height: 20),
              _buildPetDecoration(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFFFFA5BA), size: 20),
          SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: textColor,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color color, IconData icon, VoidCallback onPressed, {bool isOutlined = false}) {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.white : color,
          foregroundColor: isOutlined ? color : Colors.white,
          elevation: isOutlined ? 0 : 2,
          side: BorderSide(
            color: color,
            width: isOutlined ? 2 : 0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetDecoration() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: 80,
          height: 80,
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(0xFFD1E3FF).withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Center(
                child: Icon(
                  Icons.pets,
                  size: 40,
                  color: Color(0xFF6A9ECF),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 80,
          height: 80,
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFE5EB).withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Center(
                child: Icon(
                  Icons.favorite,
                  size: 40,
                  color: Color(0xFFFFA5BA),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 80,
          height: 80,
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF5D6).withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Center(
                child: Icon(
                  Icons.home,
                  size: 40,
                  color: Color(0xFFFFD166),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}