import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PutPetForAdoption extends StatefulWidget {
  @override
  _PutPetForAdoptionState createState() => _PutPetForAdoptionState();
}

class _PutPetForAdoptionState extends State<PutPetForAdoption> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String _selectedPetType = 'Dog';
  final List<String> _petTypes = ['Dog', 'Cat'];

  /// Holds the selected image file (for local preview only).
  File? _imageFile;

  /// Lets the user pick an image from the gallery.
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  /// Simulates saving pet details (locally) without Firebase.
  Future<void> addPetForAdoption() async {
    // Validate the form fields
    if (!_formKey.currentState!.validate()) return;

    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final age = ageController.text.trim();
    final price = priceController.text.trim();

    // Here, you'd normally do something with the data (e.g., send to a server).
    // Since we're removing Firebase references, we'll simply show a success message.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pet "$name" added for adoption successfully!'),
        backgroundColor: const Color(0xFF6B4EFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );

    // Clear the form fields and the image
    nameController.clear();
    descriptionController.clear();
    ageController.clear();
    priceController.clear();
    setState(() {
      _imageFile = null;
      _selectedPetType = 'Dog';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Put Pet for Adoption',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B4EFF),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF6B4EFF)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF88D8FF), Color(0xFFD1FAFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative paw prints
              Positioned(
                top: 40,
                right: 20,
                child: _buildPawPrint(Colors.white.withOpacity(0.3), 40),
              ),
              Positioned(
                bottom: 120,
                left: 30,
                child: _buildPawPrint(Colors.white.withOpacity(0.3), 30),
              ),

              // Main Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Find a Loving Home",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B4EFF),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Share details about your pet to help them find their perfect match.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF515C7B),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Card Container
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Pet Image Section
                              Center(
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: _pickImage,
                                      child: Container(
                                        height: 150,
                                        width: 150,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5F8FF),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: const Color(0xFF6B4EFF).withOpacity(0.3),
                                            width: 2,
                                          ),
                                        ),
                                        child: _imageFile != null
                                            ? ClipRRect(
                                          borderRadius: BorderRadius.circular(18),
                                          child: Image.file(
                                            _imageFile!,
                                            height: 150,
                                            width: 150,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                            : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_photo_alternate_rounded,
                                              size: 50,
                                              color: const Color(0xFF6B4EFF).withOpacity(0.7),
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              "Add Pet Photo",
                                              style: TextStyle(
                                                color: Color(0xFF6B4EFF),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    if (_imageFile == null)
                                      TextButton.icon(
                                        onPressed: _pickImage,
                                        icon: const Icon(
                                          Icons.photo_library_rounded,
                                          size: 18,
                                        ),
                                        label: const Text("Select from Gallery"),
                                        style: TextButton.styleFrom(
                                          foregroundColor: const Color(0xFF6B4EFF),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Pet Type Dropdown
                              const Text(
                                "Pet Type",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF515C7B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F8FF),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedPetType,
                                    isExpanded: true,
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Color(0xFF6B4EFF),
                                    ),
                                    style: const TextStyle(
                                      color: Color(0xFF515C7B),
                                      fontSize: 16,
                                    ),
                                    items: _petTypes.map((String type) {
                                      return DropdownMenuItem<String>(
                                        value: type,
                                        child: Text(type),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _selectedPetType = newValue;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Pet Name Field
                              const Text(
                                "Pet Name",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF515C7B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: nameController,
                                hintText: "Enter pet's name",
                                icon: Icons.pets_rounded,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a pet name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Age Field
                              const Text(
                                "Age (years)",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF515C7B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: ageController,
                                hintText: "Enter pet's age",
                                icon: Icons.calendar_today_rounded,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the age';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Price Field
                              const Text(
                                "Adoption Fee",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF515C7B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: priceController,
                                hintText: "Enter adoption fee",
                                icon: Icons.attach_money_rounded,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the adoption fee';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Description Field
                              const Text(
                                "Pet Description",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF515C7B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: descriptionController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF5F8FF),
                                  hintText: "Describe your pet's personality, habits, needs...",
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 14,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.description_rounded,
                                    color: Color(0xFF6B4EFF),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF6B4EFF),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                maxLines: 4,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a description';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),

                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: addPetForAdoption,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6B4EFF),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Put Pet for Adoption',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F8FF),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF6B4EFF),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF6B4EFF),
            width: 2,
          ),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPawPrint(Color color, double size) {
    return Icon(
      Icons.pets,
      size: size,
      color: color,
    );
  }
}