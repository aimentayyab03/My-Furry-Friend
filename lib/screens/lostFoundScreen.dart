import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert'; // for base64 encoding

class LostAndFoundScreen extends StatefulWidget {
  @override
  _LostAndFoundScreenState createState() => _LostAndFoundScreenState();
}

class _LostAndFoundScreenState extends State<LostAndFoundScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  File? _image;
  bool _isLoading = false;

  List<Map<String, dynamic>> matchedPets = [];

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Convert image to base64 string
  Future<String> _imageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes); // Convert image to base64 string
  }

  // Show pet report form dialog
  void _showReportForm(bool isLostPet) {
    // Reset form fields
    _nameController.clear();
    _breedController.clear();
    _colorController.clear();
    _locationController.clear();
    _image = null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isLostPet ? "Report Lost Pet" : "Report Found Pet"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: "Pet Name"),
                    ),
                    TextField(
                      controller: _breedController,
                      decoration: InputDecoration(labelText: "Breed"),
                    ),
                    TextField(
                      controller: _colorController,
                      decoration: InputDecoration(labelText: "Color"),
                    ),
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(labelText: "Location"),
                    ),
                    SizedBox(height: 20),
                    _image != null
                        ? Image.file(_image!, height: 100)
                        : Text("No image selected"),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await _pickImage();
                        setState(() {}); // Update the dialog state
                      },
                      child: Text("Select Image"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (isLostPet) {
                      _reportLostPet();
                    } else {
                      _reportFoundPet();
                    }
                  },
                  child: Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Report the lost pet
  Future<void> _reportLostPet() async {
    if (_image == null || _nameController.text.isEmpty || _breedController.text.isEmpty || _colorController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields and select an image")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert image to base64 string
      String base64Image = await _imageToBase64(_image!);

      // Check for duplicate lost pet report
      bool isDuplicate = await _checkDuplicate('lostPets');
      if (isDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Duplicate lost pet report detected.")));
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Add to the "lostPets" collection
      await FirebaseFirestore.instance.collection('lostPets').add({
        'name': _nameController.text,
        'breed': _breedController.text,
        'color': _colorController.text,
        'location': _locationController.text,
        'image': base64Image, // Store base64 image in Firestore
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lost pet reported successfully!")));

      // Reset form fields
      setState(() {
        _image = null;
        _nameController.clear();
        _breedController.clear();
        _colorController.clear();
        _locationController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Report the found pet
  Future<void> _reportFoundPet() async {
    if (_image == null || _nameController.text.isEmpty || _breedController.text.isEmpty || _colorController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields and select an image")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert image to base64 string
      String base64Image = await _imageToBase64(_image!);

      // Check for duplicate found pet report
      bool isDuplicate = await _checkDuplicate('foundPets');
      if (isDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Duplicate found pet report detected.")));
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Add to the "foundPets" collection
      await FirebaseFirestore.instance.collection('foundPets').add({
        'name': _nameController.text,
        'breed': _breedController.text,
        'color': _colorController.text,
        'location': _locationController.text,
        'image': base64Image,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Found pet reported successfully!")));

      // Reset form fields
      setState(() {
        _image = null;
        _nameController.clear();
        _breedController.clear();
        _colorController.clear();
        _locationController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Check for duplicate pet reports in the specified collection
  Future<bool> _checkDuplicate(String collection) async {
    final snapshot = await FirebaseFirestore.instance.collection(collection)
        .where('name', isEqualTo: _nameController.text)
        .where('breed', isEqualTo: _breedController.text)
        .where('location', isEqualTo: _locationController.text)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // Get limited lost pets from Firestore for preview
  Stream<QuerySnapshot> _getLostPetsPreviewStream() {
    return FirebaseFirestore.instance.collection('lostPets')
        .orderBy('timestamp', descending: true)
        .limit(3) // Only show top 3 pets on landing page
        .snapshots();
  }

  // Get limited found pets from Firestore for preview
  Stream<QuerySnapshot> _getFoundPetsPreviewStream() {
    return FirebaseFirestore.instance.collection('foundPets')
        .orderBy('timestamp', descending: true)
        .limit(3) // Only show top 3 pets on landing page
        .snapshots();
  }

  // Get all lost pets from Firestore
  Stream<QuerySnapshot> _getAllLostPetsStream() {
    return FirebaseFirestore.instance.collection('lostPets')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get all found pets from Firestore
  Stream<QuerySnapshot> _getAllFoundPetsStream() {
    return FirebaseFirestore.instance.collection('foundPets')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Navigate to detailed pet list
  void _navigateToDetailedList(bool isLostPets) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailedPetListScreen(
          isLostPets: isLostPets,
          stream: isLostPets ? _getAllLostPetsStream() : _getAllFoundPetsStream(),
          title: isLostPets ? "Lost Pets" : "Found Pets",
        ),
      ),
    );
  }

  // Compare Lost and Found pets
  Future<void> _compareLostAndFoundPets() async {
    setState(() {
      _isLoading = true;
    });

    final lostPetsSnapshot = await FirebaseFirestore.instance.collection('lostPets').get();
    final foundPetsSnapshot = await FirebaseFirestore.instance.collection('foundPets').get();

    final lostPets = lostPetsSnapshot.docs;
    final foundPets = foundPetsSnapshot.docs;

    List<Map<String, dynamic>> tempMatchedPets = [];

    for (var lostPetDoc in lostPets) {
      var lostPet = lostPetDoc.data() as Map<String, dynamic>;

      for (var foundPetDoc in foundPets) {
        var foundPet = foundPetDoc.data() as Map<String, dynamic>;

        // Compare name, breed, and location for potential matches
        if (lostPet['name'] == foundPet['name'] ||
            lostPet['breed'] == foundPet['breed'] ||
            lostPet['location'] == foundPet['location']) {
          tempMatchedPets.add({
            'lostPet': lostPet,
            'foundPet': foundPet,
            'matchScore': _calculateMatchScore(lostPet, foundPet),
          });
        }
      }
    }

    // Sort matches by match score
    tempMatchedPets.sort((a, b) => b['matchScore'].compareTo(a['matchScore']));

    setState(() {
      matchedPets = tempMatchedPets;
      _isLoading = false;
    });

    if (matchedPets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No matches found")));
    } else {
      // Navigate to comparison results screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ComparisonResultsScreen(matchedPets: matchedPets),
        ),
      );
    }
  }

  // Calculate match score between lost and found pet
  int _calculateMatchScore(Map<String, dynamic> lostPet, Map<String, dynamic> foundPet) {
    int score = 0;

    if (lostPet['name'] == foundPet['name']) score += 3;
    if (lostPet['breed'] == foundPet['breed']) score += 2;
    if (lostPet['color'] == foundPet['color']) score += 2;
    if (lostPet['location'] == foundPet['location']) score += 3;

    return score;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lost & Found Pets"),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main Action Buttons
              Card(
                elevation: 3,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => _showReportForm(true),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text("Report Lost Pet"),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _showReportForm(false),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text("Report Found Pet"),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Lost Pets Section with View All icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      "Lost Pets",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () => _navigateToDetailedList(true),
                    tooltip: "View all lost pets",
                  ),
                ],
              ),

              StreamBuilder<QuerySnapshot>(
                stream: _getLostPetsPreviewStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var lostPets = snapshot.data!.docs;
                  if (lostPets.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text("No lost pets reported yet."),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: lostPets.length,
                    itemBuilder: (context, index) {
                      var pet = lostPets[index].data() as Map<String, dynamic>;

                      // Decode the base64 image
                      String base64Image = pet['image'] ?? "";
                      Uint8List? bytes;
                      Widget imageWidget;

                      try {
                        bytes = base64Decode(base64Image);
                        imageWidget = Image.memory(
                          bytes,
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                        );
                      } catch (e) {
                        // Fallback if image can't be decoded
                        imageWidget = Icon(Icons.pets, size: 60);
                      }

                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: imageWidget,
                          ),
                          title: Text(
                              pet['name'],
                              style: TextStyle(fontWeight: FontWeight.bold)
                          ),
                          subtitle: Text(
                              "${pet['breed']} | ${pet['color']} | ${pet['location']}"
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              SizedBox(height: 20),

              // Found Pets Section with View All icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      "Found Pets",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () => _navigateToDetailedList(false),
                    tooltip: "View all found pets",
                  ),
                ],
              ),

              StreamBuilder<QuerySnapshot>(
                stream: _getFoundPetsPreviewStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var foundPets = snapshot.data!.docs;
                  if (foundPets.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text("No found pets reported yet."),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: foundPets.length,
                    itemBuilder: (context, index) {
                      var pet = foundPets[index].data() as Map<String, dynamic>;

                      // Decode the base64 image
                      String base64Image = pet['image'] ?? "";
                      Uint8List? bytes;
                      Widget imageWidget;

                      try {
                        bytes = base64Decode(base64Image);
                        imageWidget = Image.memory(
                          bytes,
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                        );
                      } catch (e) {
                        // Fallback if image can't be decoded
                        imageWidget = Icon(Icons.pets, size: 60);
                      }

                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: imageWidget,
                          ),
                          title: Text(
                              pet['name'],
                              style: TextStyle(fontWeight: FontWeight.bold)
                          ),
                          subtitle: Text(
                              "${pet['breed']} | ${pet['color']} | ${pet['location']}"
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              SizedBox(height: 20),

              // Compare Button
              ElevatedButton(
                onPressed: _compareLostAndFoundPets,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.amber,
                ),
                child: Text(
                  "Compare Lost and Found Pets",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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

// Screen for showing detailed pet list
class DetailedPetListScreen extends StatelessWidget {
  final bool isLostPets;
  final Stream<QuerySnapshot> stream;
  final String title;

  DetailedPetListScreen({
    required this.isLostPets,
    required this.stream,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var pets = snapshot.data!.docs;

          if (pets.isEmpty) {
            return Center(
              child: Text("No ${isLostPets ? 'lost' : 'found'} pets reported."),
            );
          }

          return ListView.builder(
            itemCount: pets.length,
            itemBuilder: (context, index) {
              var pet = pets[index].data() as Map<String, dynamic>;

              // Decode the base64 image
              String base64Image = pet['image'] ?? "";
              Uint8List? bytes;
              Widget imageWidget;

              try {
                bytes = base64Decode(base64Image);
                imageWidget = Image.memory(
                  bytes,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                );
              } catch (e) {
                // Fallback if image can't be decoded
                imageWidget = Icon(Icons.pets, size: 80);
              }

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageWidget,
                  ),
                  title: Text(
                      pet['name'],
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text("Breed: ${pet['breed']}"),
                      Text("Color: ${pet['color']}"),
                      Text("Location: ${pet['location']}"),
                      Text("Reported: ${(pet['timestamp'] as Timestamp?)?.toDate().toString().split('.')[0] ?? 'Unknown'}"),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Screen for showing comparison results
class ComparisonResultsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> matchedPets;

  ComparisonResultsScreen({required this.matchedPets});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Potential Matches"),
      ),
      body: matchedPets.isEmpty
          ? Center(
        child: Text("No potential matches found."),
      )
          : ListView.builder(
        itemCount: matchedPets.length,
        padding: EdgeInsets.all(16),
        itemBuilder: (context, index) {
          var match = matchedPets[index];
          var lostPet = match['lostPet'];
          var foundPet = match['foundPet'];
          var matchScore = match['matchScore'];

          return Card(
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pets, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        "Match Score: $matchScore/10",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lost Pet Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Lost Pet",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(height: 8),
                            _buildMatchInfoRow("Name", lostPet['name']),
                            _buildMatchInfoRow("Breed", lostPet['breed']),
                            _buildMatchInfoRow("Color", lostPet['color']),
                            _buildMatchInfoRow("Location", lostPet['location']),
                          ],
                        ),
                      ),

                      SizedBox(width: 16),

                      // Found Pet Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Found Pet",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(height: 8),
                            _buildMatchInfoRow("Name", foundPet['name']),
                            _buildMatchInfoRow("Breed", foundPet['breed']),
                            _buildMatchInfoRow("Color", foundPet['color']),
                            _buildMatchInfoRow("Location", foundPet['location']),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Contact Information"),
                          content: Text(
                            "This feature will be implemented in the next version to allow pet owners to connect.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("OK"),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 40),
                    ),
                    child: Text("Connect with Owner"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMatchInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}