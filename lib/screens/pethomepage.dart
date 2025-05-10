import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_two/e-commerce/product_list_screen.dart';
import 'package:fyp_two/screens/petInstaFeed.dart';
import 'package:fyp_two/screens/planner_screen.dart';
import 'package:fyp_two/screens/social_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'breeddetection.dart';
import 'health_screen.dart';
import 'lostFoundScreen.dart';
import 'owner_adoption_landing.dart';

// Pet-friendly color palette
class PetColors {
  static const Color primary = Color(0xFF6B9AC4);      // Soft blue
  static const Color secondary = Color(0xFFF8A978);    // Peachy orange
  static const Color accent = Color(0xFFFFD166);       // Sunny yellow
  static const Color background = Color(0xFFF7F9FC);   // Light background
  static const Color cardLight = Color(0xFFE4F0FB);    // Light card color
  static const Color textDark = Color(0xFF4A5568);     // Dark text
  static const Color greenAccent = Color(0xFF97D1A7);  // Minty green
  static const Color purpleAccent = Color(0xFFD4B2D8); // Soft purple
}

class Pethomepage extends StatefulWidget {
  @override
  _PethomepageState createState() => _PethomepageState();
}

class _PethomepageState extends State<Pethomepage> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _petName = "";
  String _profileImage = "";
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fetchPetData();

    // Animation for interactive elements
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchPetData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot petData = await _firestore.collection('pets').doc(user.uid).get();
      if (petData.exists) {
        setState(() {
          _petName = petData['name'] ?? 'Your Pet';
          _profileImage = petData['image'] ?? 'assets/images/petlogo.png';

        });
      }
    }
  }

  final List<Map<String, dynamic>> activities = [
    {
      "title": "Health",
      "image": "assets/images/checkup.jpeg",
      "screen": const HealthScreen(),
      "color": PetColors.greenAccent,
      "icon": Icons.favorite,
    },
    {
      "title": "Social",
      "image": "assets/images/petinsta.png",
      "screen": SocialScreen(),
      "color": PetColors.purpleAccent,
      "icon": Icons.pets,
    },
    {
      "title": "Breed Detection",
      "image": "assets/images/petlogo.png",
      "screen": const Breeddetection(),
      "color": PetColors.secondary,
      "icon": Icons.search,
    },
    {
      "title": "Planner",
      "image": "assets/images/planner.jpeg",
      "screen": const PlannerScreen(),
      "color": PetColors.accent,
      "icon": Icons.calendar_today,
    },
    {
      "title": "Lost & Found",
      "image": "assets/images/lostnfound.jpeg",
      "screen": LostAndFoundScreen(),
      "color": PetColors.primary,
      "icon": Icons.location_on,
    },
    {
      "title": "Adoption Portal",
      "image": "assets/images/petlogo.png",
      "screen": const OwnerAdoptionLanding(),
      "color": PetColors.secondary.withOpacity(0.8),
      "icon": Icons.home,
    },
    {
      "title": "Training",
      "image": "assets/images/checkup.jpeg",
      "screen": const HealthScreen(),
      "color": PetColors.greenAccent,
      "icon": Icons.favorite,
    },
    {
      "title": "Shop",
      "image": "assets/images/checkup.jpeg",
      "screen": ProductListScreen(),
      "color": PetColors.greenAccent,
      "icon": Icons.favorite,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: PetColors.primary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            Text(
              "Pet's Diary",
              style: GoogleFonts.bubblegumSans(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.3),
              child: IconButton(
                icon: Icon(Icons.notifications, color: Colors.white),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [PetColors.background, PetColors.cardLight],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: PetColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                accountName: Text(
                  _petName,
                  style: GoogleFonts.bubblegumSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                accountEmail: null,
                currentAccountPicture: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(_profileImage),
                    radius: 40,
                  ),
                ),
              ),
              _buildDrawerItem(Icons.pets, 'My Pets', () {}),
              _buildDrawerItem(Icons.settings, 'Settings', () {}),
              _buildDrawerItem(Icons.logout, 'Logout', () async {
                await _auth.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              }),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PetColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: PetColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.support, color: Colors.white),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Need Help?',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: PetColors.textDark,
                              ),
                            ),
                            Text(
                              'Contact support',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: PetColors.textDark.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [PetColors.background, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top wave pattern
              ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: PetColors.primary,
                  ),
                ),
              ),

              // User Information Section
              Transform.translate(
                offset: Offset(0, -100),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(_profileImage),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.pets, color: PetColors.primary),
                            SizedBox(width: 8),
                            Text(
                              "Hello, $_petName!",
                              style: GoogleFonts.bubblegumSans(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: PetColors.textDark,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.favorite, color: PetColors.secondary, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Activities Section
              Transform.translate(
                offset: Offset(0, -50),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: PetColors.accent),
                      SizedBox(width: 8),
                      Text(
                        "Fun Activities",
                        style: GoogleFonts.bubblegumSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: PetColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, -40),
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    return _ActivityCard(
                      activity: activities[index],
                      scaleAnimation: _scaleAnimation,
                      onTapDown: () => _animationController.forward(),
                      onTapUp: () => _animationController.reverse(),
                    );
                  },
                ),
              ),

              // Cute paw prints pattern at bottom
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Transform.rotate(
                      angle: index * 0.5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          Icons.pets,
                          color: PetColors.primary.withOpacity(0.3),
                          size: 20,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PetColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: PetColors.primary),
              ),
              SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: PetColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 4), size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _ActivityCard extends StatelessWidget {
  final Map<String, dynamic> activity;
  final Animation<double> scaleAnimation;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;

  const _ActivityCard({
    Key? key,
    required this.activity,
    required this.scaleAnimation,
    required this.onTapDown,
    required this.onTapUp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: onTapUp,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => activity["screen"]),
        );
      },
      child: AnimatedBuilder(
        animation: scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: scaleAnimation.value,
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: activity["color"].withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Activity icon in a circle
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: activity["color"].withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  activity["icon"],
                  color: activity["color"],
                  size: 28,
                ),
              ),
              SizedBox(height: 12),

              // Activity title
              Text(
                activity["title"],
                style: GoogleFonts.bubblegumSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: PetColors.textDark,
                ),
              ),

              // Stylized activity image at the bottom
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        Image.asset(
                          activity["image"],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                activity["color"].withOpacity(0.2),
                                activity["color"].withOpacity(0.5),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}