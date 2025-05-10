import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fyp_two/screens/login.dart';

class PetInstaFeed extends StatefulWidget {
  @override
  _PetInstaFeedState createState() => _PetInstaFeedState();
}

class _PetInstaFeedState extends State<PetInstaFeed> {
  final TextEditingController postController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> addPost() async {
    if (postController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('posts').add({
        'userId': _auth.currentUser!.uid,
        'content': postController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      postController.clear();
    }
  }

  Future<void> likePost(String postId) async {
    FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'likes': FieldValue.increment(1),
    });
  }


  Future<void> commentOnPost(String postId, String comment) async {
    FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').add({
      'comment': comment,
      'userId': _auth.currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          TextField(controller: postController, decoration: InputDecoration(labelText: 'What\'s on your mind?')),
          ElevatedButton(onPressed: addPost, child: Text('Post')),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No posts yet.'));
                }

                var posts = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    var post = posts[index];
                    return ListTile(
                      title: Text(post['content']),
                      subtitle: Text('Likes: ${post['likes'] ?? 0}'),
                      trailing: IconButton(
                        icon: Icon(Icons.thumb_up),
                        onPressed: () => likePost(post.id),
                      ),
                      onTap: () {
                        // Show comments here
                      },
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
