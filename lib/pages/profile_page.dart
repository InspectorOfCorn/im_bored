import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// A page that displays and allows editing of the user's profile.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _isDescriptionFilled = false; // Indicates if the description is filled
  File? _profileImage; // Holds the selected profile image

  /// Picks an image from the gallery and updates the profile image.
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path); // Update the profile image
      });
    }
  }

  /// Toggles the edit state of the description.
  void _toggleEdit() {
    setState(() {
      _isDescriptionFilled = false; // Resets the description filled state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'), // Title of the app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the content
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage, // Picks an image when tapped
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!) // Displays the selected image
                    : const AssetImage('assets/user_photo.png') as ImageProvider, // Default image
                child: _profileImage == null
                    ? const Icon(Icons.camera_alt, size: 30, color: Colors.white) // Icon when no image is selected
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Username', // Replace with actual username
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (!_isDescriptionFilled)
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Add a description about yourself', // Label for the text field
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  setState(() {
                    _isDescriptionFilled = true; // Marks the description as filled
                  });
                },
              ),
            if (_isDescriptionFilled)
              Column(
                children: [
                  Text(
                    _descriptionController.text, // Displays the filled description
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _toggleEdit, // Button to edit the description
                    child: const Text('Edit'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
