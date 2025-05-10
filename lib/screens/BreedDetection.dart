import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Breeddetection extends StatefulWidget {
  const Breeddetection({super.key});

  @override
  State<Breeddetection> createState() => _BreeddetectionState();
}

class _BreeddetectionState extends State<Breeddetection> {
  File? _image;
  String _breedResult = '';
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // Updated cute pet-themed color palette
  final Color _primaryColor = const Color(0xFFFF6B8B); // Pink
  final Color _secondaryColor = const Color(0xFF74D2E7); // Sky Blue
  final Color _accentColor = const Color(0xFFFFD166); // Sunny Yellow
  final Color _backgroundColor = const Color(0xFFFFF6F8); // Light Pink background
  final Color _surfaceColor = Colors.white;
  final Color _textPrimaryColor = const Color(0xFF4A4A4A); // Dark Grey
  final Color _textSecondaryColor = const Color(0xFF878787); // Medium Grey

  // ✅ Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        _breedResult = '';
      });
    }
  }

  // ✅ Detect breed using FastAPI
  Future<void> _detectBreed() async {
    if (_image == null || !_image!.existsSync()) {
      setState(() {
        _breedResult = "Invalid image. Please select a valid image.";
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _breedResult = '';
    });

    try {
      // ✅ Updated FastAPI endpoint URL
      var uri = Uri.parse('https://2e1f-34-125-152-230.ngrok-free.app//predict');

      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', _image!.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var result = json.decode(responseData);

        setState(() {
          _breedResult = result.containsKey('Predicted Class')
              ? result['Predicted Class']
              : 'No breed detected. Try again.';
        });
      } else {
        setState(() {
          _breedResult = 'Failed to detect breed. Please try again later.';
        });
      }
    } catch (e) {
      setState(() {
        _breedResult = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ✅ UI for the breed detection screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Breed Detective',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Quicksand',
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              // Show help dialog
            },
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildHeader(),
            const SizedBox(height: 25),
            _buildImageSection(),
            const SizedBox(height: 25),
            _buildActionButtons(),
            const SizedBox(height: 30),
            _buildDetectButton(),
            const SizedBox(height: 25),
            _buildResultSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: _secondaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _secondaryColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _secondaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _secondaryColor.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.search,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "What breed is your pet?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textPrimaryColor,
                    fontFamily: 'Quicksand',
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Upload or take a photo to find out!",
                  style: TextStyle(
                    fontSize: 14,
                    color: _textSecondaryColor,
                    fontFamily: 'Quicksand',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryColor, _secondaryColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (index) {
                    return Container(
                      margin: const EdgeInsets.only(top: 5),
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _accentColor.withOpacity(0.7),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: _image == null
                ? Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.width * 0.6,
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _primaryColor.withOpacity(0.3),
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignOutside,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Paw print decorations at corners
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Icon(
                          Icons.pets,
                          size: 20,
                          color: _primaryColor.withOpacity(0.3),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Icon(
                          Icons.pets,
                          size: 20,
                          color: _secondaryColor.withOpacity(0.3),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Icon(
                          Icons.pets,
                          size: 20,
                          color: _secondaryColor.withOpacity(0.3),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Icon(
                          Icons.pets,
                          size: 20,
                          color: _primaryColor.withOpacity(0.3),
                        ),
                      ),
                      // Center content
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: _primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.pets,
                                size: 60,
                                color: _primaryColor.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No image selected',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: _textPrimaryColor,
                                fontFamily: 'Quicksand',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Upload a clear photo of your pet',
                              style: TextStyle(
                                fontSize: 14,
                                color: _textSecondaryColor.withOpacity(0.7),
                                fontFamily: 'Quicksand',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
                : Column(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryColor.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          _image!,
                          height: MediaQuery.of(context).size.width * 0.6,
                          width: MediaQuery.of(context).size.width * 0.8,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _image = null;
                            _breedResult = '';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.close,
                            color: _primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: _primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Your pet looks pawsome!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _textPrimaryColor,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.favorite,
                      color: _primaryColor,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          icon: Icons.photo_library,
          label: 'Gallery',
          color: _secondaryColor,
          onPressed: () => _pickImage(ImageSource.gallery),
        ),
        const SizedBox(width: 20),
        _buildActionButton(
          icon: Icons.camera_alt,
          label: 'Camera',
          color: _primaryColor,
          onPressed: () => _pickImage(ImageSource.camera),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'Quicksand',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectButton() {
    return GestureDetector(
      onTap: _image == null || _isLoading ? null : _detectBreed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: _image == null
              ? null
              : LinearGradient(
            colors: [_accentColor, _secondaryColor],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          color: _image == null ? Colors.grey.shade300 : null,
          borderRadius: BorderRadius.circular(30),
          boxShadow: _image == null
              ? []
              : [
            BoxShadow(
              color: _accentColor.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pets,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Detect Breed',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'Quicksand',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    if (_breedResult.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool isError = _breedResult.startsWith('Error:') ||
        _breedResult.startsWith('Failed') ||
        _breedResult.startsWith('Invalid') ||
        _breedResult.startsWith('No breed');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
            color: isError
                ? Colors.red.withOpacity(0.3)
                : _primaryColor.withOpacity(0.2)
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isError
                      ? Colors.red.withOpacity(0.1)
                      : _primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isError ? Icons.error_outline : Icons.pets,
                  color: isError ? Colors.red : _primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Text(
                'Breed Detective Says:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textPrimaryColor,
                  fontFamily: 'Quicksand',
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isError
                  ? Colors.red.withOpacity(0.05)
                  : _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  color: isError
                      ? Colors.red.withOpacity(0.2)
                      : _primaryColor.withOpacity(0.2)
              ),
            ),
            child: Column(
              children: [
                Text(
                  isError
                      ? _breedResult
                      : 'Your furry friend appears to be a $_breedResult',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isError
                        ? Colors.red.shade700
                        : _primaryColor,
                    fontFamily: 'Quicksand',
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!isError)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emoji_emotions,
                          color: _accentColor,
                          size: 20,
                        ),
                        Text(
                          ' Woof! ',
                          style: TextStyle(
                            fontSize: 14,
                            color: _textSecondaryColor,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Quicksand',
                          ),
                        ),
                        Icon(
                          Icons.pets,
                          color: _accentColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (!isError)
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBreedInfoButton(
                    icon: Icons.info_outline,
                    label: 'Breed Info',
                  ),
                  const SizedBox(width: 15),
                  _buildBreedInfoButton(
                    icon: Icons.favorite_border,
                    label: 'Save Result',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBreedInfoButton({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: _primaryColor),
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            _primaryColor.withOpacity(0.1),
            _secondaryColor.withOpacity(0.1)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _primaryColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: _primaryColor,
              fontWeight: FontWeight.w500,
              fontFamily: 'Quicksand',
            ),
          ),
        ],
      ),
    );
  }
}