import 'package:flutter/material.dart';

class PetProfileDetailScreen extends StatefulWidget {
  final String petName;
  final String petImage;
  final String petAbout;

  const PetProfileDetailScreen(
      {super.key,
      required this.petName,
      required this.petImage,
      required this.petAbout});

  @override
  _PetProfileDetailScreenState createState() => _PetProfileDetailScreenState();
}

class _PetProfileDetailScreenState extends State<PetProfileDetailScreen> {
  bool isFollowing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.petName)),
      body: Column(
        children: [
          CircleAvatar(
              radius: 50, backgroundImage: NetworkImage(widget.petImage)),
          SizedBox(height: 10),
          Text(widget.petName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(widget.petAbout, style: TextStyle(fontSize: 16)),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isFollowing = !isFollowing;
              });
            },
            child: Text(isFollowing ? "Unfollow" : "Follow"),
          ),
          Divider(),
          Expanded(
            child: ListView(
              children: [
                Image.network("https://via.placeholder.com/150"),
                Image.network("https://via.placeholder.com/150"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
