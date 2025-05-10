import 'package:flutter/material.dart';
import '../models/postModel.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Image.network(post.petImage),
          Text(post.petName),
          Text(post.petAbout),
        ],
      ),
    );
  }
}
