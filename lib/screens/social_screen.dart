import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _posts = [];
  String? _imageUrl;
  String? _petName;
  String? _petImageUrl;
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _showHeartAnimation = false;
  AnimationController? _heartAnimationController;
  Map<String, List<Map<String, dynamic>>> _postComments = {};

  @override
  void initState() {
    super.initState();
    _heartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadPosts();
    _getPetProfile();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoading) {
        _loadMorePosts();
      }
    });
  }

  @override
  void dispose() {
    _heartAnimationController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getPetProfile() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final petProfileSnapshot = await _firestore
          .collection('pet_profiles')
          .doc(currentUser.uid)
          .get();

      if (petProfileSnapshot.exists) {
        setState(() {
          _petName = petProfileSnapshot['name'] as String?;
          _petImageUrl = petProfileSnapshot['imageUrl'] as String?;
        });
      }
    }
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      final posts = querySnapshot.docs.map((doc) {
        final data = doc.data();
        // Ensure likes is always treated as a List<String>
        dynamic likes = data['likes'];
        List<String> likesList = [];
        if (likes is List) {
          likesList = List<String>.from(likes.map((e) => e.toString()));
        } else if (likes != null) {
          likesList = [likes.toString()];
        }

        return {
          'id': doc.id,
          'uid': data['uid'] as String?,
          'petName': data['petName'] as String?,
          'petImageUrl': data['petImageUrl'] as String?,
          'caption': data['caption'] as String?,
          'imageUrl': data['imageUrl'] as String?,
          'timestamp': data['timestamp'] as Timestamp,
          'likes': likesList,
          'commentsCount': data['commentsCount'] as int? ?? 0,
        };
      }).toList();

      for (var post in posts) {
        await _loadComments(post['id'] as String);
      }

      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading posts: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadMorePosts() async {
    if (_posts.isEmpty || _isLoading) return;

    setState(() => _isLoading = true);
    try {
      final lastPost = _posts.last;
      final timestamp = lastPost['timestamp'] as Timestamp;

      final querySnapshot = await _firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .startAfter([timestamp])
          .limit(10)
          .get();

      final newPosts = querySnapshot.docs.map((doc) {
        final data = doc.data();
        // Ensure likes is always treated as a List<String>
        dynamic likes = data['likes'];
        List<String> likesList = [];
        if (likes is List) {
          likesList = List<String>.from(likes.map((e) => e.toString()));
        } else if (likes != null) {
          likesList = [likes.toString()];
        }

        return {
          'id': doc.id,
          'uid': data['uid'] as String?,
          'petName': data['petName'] as String?,
          'petImageUrl': data['petImageUrl'] as String?,
          'caption': data['caption'] as String?,
          'imageUrl': data['imageUrl'] as String?,
          'timestamp': data['timestamp'] as Timestamp,
          'likes': likesList,
          'commentsCount': data['commentsCount'] as int? ?? 0,
        };
      }).toList();

      for (var post in newPosts) {
        await _loadComments(post['id'] as String);
      }

      setState(() {
        _posts.addAll(newPosts);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading more posts: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadComments(String postId) async {
    try {
      final commentsSnapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('timestamp', descending: false)
          .limit(2)
          .get();

      final comments = commentsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'uid': data['uid'] as String?,
          'petName': data['petName'] as String?,
          'petImageUrl': data['petImageUrl'] as String?,
          'text': data['text'] as String?,
          'timestamp': data['timestamp'] as Timestamp,
        };
      }).toList();

      setState(() {
        _postComments[postId] = comments;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading comments: ${e.toString()}')),
      );
    }
  }

  Future<void> _addPost() async {
    if (_postController.text.isNotEmpty || _imageUrl != null) {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        setState(() => _isLoading = true);
        try {
          final newPost = {
            'uid': currentUser.uid,
            'petName': _petName,
            'petImageUrl': _petImageUrl,
            'caption': _postController.text,
            'imageUrl': _imageUrl,
            'timestamp': FieldValue.serverTimestamp(),
            'likes': [],
            'commentsCount': 0,
          };

          await _firestore.collection('posts').add(newPost);
          _postController.clear();
          setState(() {
            _imageUrl = null;
            _isLoading = false;
            _currentIndex = 0;
          });
          _loadPosts();
        } catch (e) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add post: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _isLoading = true);
      try {
        final file = await pickedFile.readAsBytes();
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final ref = _storage.ref().child('post_images/$fileName');
        final uploadTask = ref.putData(file);
        final snapshot = await uploadTask.whenComplete(() {});
        final imageUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          _imageUrl = imageUrl;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _toggleLike(String postId, List<dynamic> likes) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        final newLikes = List<String>.from(likes.map((e) => e.toString()));
        if (newLikes.contains(currentUser.uid)) {
          newLikes.remove(currentUser.uid);
        } else {
          newLikes.add(currentUser.uid);
          setState(() => _showHeartAnimation = true);
          _heartAnimationController?.forward().then((_) {
            setState(() => _showHeartAnimation = false);
          });
        }
        await _firestore.collection('posts').doc(postId).update({'likes': newLikes});
        _loadPosts();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to toggle like: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _addComment(String postId) async {
    if (_commentController.text.isNotEmpty) {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        setState(() => _isLoading = true);
        try {
          final newComment = {
            'uid': currentUser.uid,
            'petName': _petName,
            'petImageUrl': _petImageUrl,
            'text': _commentController.text,
            'timestamp': FieldValue.serverTimestamp(),
          };

          await _firestore
              .collection('posts')
              .doc(postId)
              .collection('comments')
              .add(newComment);

          await _firestore.collection('posts').doc(postId).update({
            'commentsCount': FieldValue.increment(1),
          });

          _commentController.clear();
          await _loadComments(postId);
          _loadPosts();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add comment: ${e.toString()}')),
          );
        } finally {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showCommentsBottomSheet(String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return CommentsBottomSheet(
          postId: postId,
          petName: _petName,
          petImageUrl: _petImageUrl,
          firestore: _firestore,
          auth: _auth,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _currentIndex == 0
          ? AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/petstagram_logo.png',
              height: 32,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.pets, size: 32),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_outline, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.send_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      )
          : null,
      body: _buildCurrentScreen(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeScreen();
      case 1:
        return _buildExploreScreen();
      case 2:
        return _buildPostScreen();
      case 3:
        return _buildActivityScreen();
      case 4:
        return _buildProfileScreen();
      default:
        return _buildHomeScreen();
    }
  }

  Widget _buildHomeScreen() {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadPosts,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _posts.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _posts.length) {
                return _buildLoadingIndicator();
              }
              final post = _posts[index];
              return _buildPostItem(post);
            },
          ),
        ),
        if (_showHeartAnimation)
          Center(
            child: ScaleTransition(
              scale: _heartAnimationController!,
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 120,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPostItem(Map<String, dynamic> post) {
    final likes = List<String>.from(post['likes'] as List<dynamic>? ?? []);
    final currentUser = _auth.currentUser;
    final isLiked = currentUser != null && likes.contains(currentUser.uid);
    final timestamp = post['timestamp'] as Timestamp?;
    final timeAgo = timestamp != null ? _getTimeAgo(timestamp.toDate()) : 'Just now';
    final comments = _postComments[post['id'] as String] ?? [];
    final commentsCount = post['commentsCount'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.pink, width: 2)),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: post['petImageUrl'] != null
                        ? CachedNetworkImageProvider(post['petImageUrl'] as String)
                        : const AssetImage('assets/images/logopet.jpg') as ImageProvider,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                post['petName'] as String? ?? 'Unknown Pet',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
          ),
        ),
        if (post['imageUrl'] != null && (post['imageUrl'] as String).isNotEmpty)
          GestureDetector(
            onDoubleTap: () => _toggleLike(post['id'] as String, likes),
            child: AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                imageUrl: post['imageUrl'] as String,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.black,
                ),
                onPressed: () => _toggleLike(post['id'] as String, likes),
              ),
              IconButton(
                icon: const Icon(Icons.comment_outlined),
                onPressed: () => _showCommentsBottomSheet(post['id'] as String),
              ),
              IconButton(
                icon: const Icon(Icons.send_outlined),
                onPressed: () {},
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: () {},
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '${likes.length} likes',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: '${post['petName'] as String? ?? 'Unknown Pet'} ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: post['caption'] as String? ?? ''),
              ],
            ),
          ),
        ),
        if (commentsCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: () => _showCommentsBottomSheet(post['id'] as String),
              child: Text(
                'View all $commentsCount comments',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        if (comments.isNotEmpty)
          ...comments.map((comment) => Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: '${comment['petName'] as String? ?? 'Unknown Pet'} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: comment['text'] as String? ?? ''),
                ],
              ),
            ),
          )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Text(
            timeAgo,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 14),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _addComment(post['id'] as String);
                    }
                  },
                ),
              ),
              TextButton(
                onPressed: _commentController.text.isEmpty
                    ? null
                    : () => _addComment(post['id'] as String),
                child: Text(
                  'Post',
                  style: TextStyle(
                    color: _commentController.text.isEmpty
                        ? Colors.blue[200]
                        : Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildExploreScreen() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Container(
            height: 35,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, size: 20),
                hintText: 'Search',
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 10),
              ),
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 0.5),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: 'https://source.unsplash.com/random/300x300/?pet=$index',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),
                );
              },
              childCount: 30,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (_imageUrl != null && _imageUrl!.isNotEmpty)
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(_imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image, size: 50, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No image selected'),
                ],
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.photo_library),
            label: const Text('Select Photo'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _postController,
            decoration: InputDecoration(
              hintText: 'Write a caption...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: (_imageUrl != null && _imageUrl!.isNotEmpty) ||
                _postController.text.isNotEmpty
                ? _addPost
                : null,
            child: _isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text('Share Post'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityScreen() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Activity'),
          centerTitle: false,
          pinned: true,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This Week',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                _buildNotificationItem(
                  'pawsome_pet',
                  'liked your photo',
                  '2h',
                  'https://source.unsplash.com/random/100x100/?dog',
                ),
                _buildNotificationItem(
                  'fluffy_buddy',
                  'started following you',
                  '5h',
                  'https://source.unsplash.com/random/100x100/?cat',
                ),
                _buildNotificationItem(
                  'max_the_dog',
                  'commented: "So cute!"',
                  '1d',
                  'https://source.unsplash.com/random/100x100/?dog',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(
      String username, String action, String time, String avatarUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' $action '),
                  TextSpan(
                    text: time,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          if (action.contains('liked'))
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                      'https://source.unsplash.com/random/100x100/?pet'),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else if (action.contains('following'))
            ElevatedButton(
              onPressed: () {},
              child: const Text('Follow'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 30),
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileScreen() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.lock_outline),
              Text(
                _petName ?? 'Your Pet',
                style: const TextStyle(fontSize: 16),
              ),
              const Icon(Icons.menu),
            ],
          ),
          centerTitle: true,
          pinned: true,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: _petImageUrl != null
                          ? CachedNetworkImageProvider(_petImageUrl!)
                          : const AssetImage('assets/images/logopet.jpg')
                      as ImageProvider,
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildProfileStat('24', 'Posts'),
                          _buildProfileStat('1.2K', 'Followers'),
                          _buildProfileStat('345', 'Following'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 0.5),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: 'https://source.unsplash.com/random/300x300/?pet=$index',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
                  ),
                );
              },
              childCount: 24,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileStat(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: _currentIndex == 0 ? Colors.black : Colors.grey,
                size: 28,
              ),
              onPressed: () => setState(() => _currentIndex = 0),
            ),
            IconButton(
              icon: Icon(
                Icons.search,
                color: _currentIndex == 1 ? Colors.black : Colors.grey,
                size: 28,
              ),
              onPressed: () => setState(() => _currentIndex = 1),
            ),
            IconButton(
              icon: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _currentIndex == 2 ? Colors.black : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: _currentIndex == 2 ? Colors.black : Colors.grey,
                  size: 28,
                ),
              ),
              onPressed: () => setState(() => _currentIndex = 2),
            ),
            IconButton(
              icon: Icon(
                Icons.favorite_border,
                color: _currentIndex == 3 ? Colors.black : Colors.grey,
                size: 28,
              ),
              onPressed: () => setState(() => _currentIndex = 3),
            ),
            GestureDetector(
              onTap: () => setState(() => _currentIndex = 4),
              child: CircleAvatar(
                radius: 14,
                backgroundImage: _petImageUrl != null
                    ? CachedNetworkImageProvider(_petImageUrl!)
                    : const AssetImage('assets/images/logopet.jpg') as ImageProvider,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }
}

class CommentsBottomSheet extends StatefulWidget {
  final String postId;
  final String? petName;
  final String? petImageUrl;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const CommentsBottomSheet({
    required this.postId,
    required this.petName,
    required this.petImageUrl,
    required this.firestore,
    required this.auth,
    super.key,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    try {
      final commentsSnapshot = await widget.firestore
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .orderBy('timestamp', descending: false)
          .get();

      setState(() {
        _comments = commentsSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'uid': data['uid'] as String?,
            'petName': data['petName'] as String?,
            'petImageUrl': data['petImageUrl'] as String?,
            'text': data['text'] as String?,
            'timestamp': data['timestamp'] as Timestamp,
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading comments: ${e.toString()}')),
      );
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty) {
      final currentUser = widget.auth.currentUser;
      if (currentUser != null) {
        setState(() => _isLoading = true);
        try {
          final newComment = {
            'uid': currentUser.uid,
            'petName': widget.petName,
            'petImageUrl': widget.petImageUrl,
            'text': _commentController.text,
            'timestamp': FieldValue.serverTimestamp(),
          };

          await widget.firestore
              .collection('posts')
              .doc(widget.postId)
              .collection('comments')
              .add(newComment);

          await widget.firestore.collection('posts').doc(widget.postId).update({
            'commentsCount': FieldValue.increment(1),
          });

          _commentController.clear();
          await _loadComments();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add comment: ${e.toString()}')),
          );
        } finally {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Comments',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading && _comments.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: comment['petImageUrl'] != null
                            ? CachedNetworkImageProvider(
                            comment['petImageUrl'] as String)
                            : const AssetImage('assets/images/logopet.jpg')
                        as ImageProvider,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style:
                                const TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: '${comment['petName']} ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: comment['text'] as String? ?? ''),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getTimeAgo(
                                  comment['timestamp'] as Timestamp),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_border, size: 16),
                        onPressed: () {},
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onSubmitted: (value) => _addComment(),
                ),
              ),
              TextButton(
                onPressed: _commentController.text.isEmpty
                    ? null
                    : _addComment,
                child: Text(
                  'Post',
                  style: TextStyle(
                    color: _commentController.text.isEmpty
                        ? Colors.blue[200]
                        : Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}