import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _profileImageBase64;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _statusController = TextEditingController();
  bool _isEditing = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('userEmail');

    if (userEmail != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userEmail).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _profileImageBase64 = userData['profileImage'];
          _nameController.text = userData['name'] ?? '';
          _statusController.text = userData['status'] ?? '';
        });
      }
    }
  }

  Future<void> _saveProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('userEmail');

    if (userEmail != null) {
      await _firestore.collection('users').doc(userEmail).set({
        'name': _nameController.text,
        'status': _statusController.text,
        'profileImage': _profileImageBase64,
      });

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate('profileSaved'))),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final resizedImage = await _resizeImage(File(pickedFile.path));
      final imageBytes = await resizedImage.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('userEmail');

      if (userEmail != null) {
        await _firestore.collection('users').doc(userEmail).update({
          'profileImage': base64Image,
        });

        setState(() {
          _profileImageBase64 = base64Image;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('profileImageUploaded'))),
        );
      }
    }
  }

  Future<File> _resizeImage(File file) async {
    Uint8List imageBytes = await file.readAsBytes();

    img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) throw Exception('Cannot load image');

    img.Image resizedImage =
        img.copyResize(originalImage, width: 200, height: 200);

    Uint8List resizedBytes = Uint8List.fromList(img.encodePng(resizedImage));

    final tempDir = await getTemporaryDirectory();
    final resizedFile = File('${tempDir.path}/resized_image.png');
    await resizedFile.writeAsBytes(resizedBytes);

    return resizedFile;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? Colors.grey[850] : const Color(0xDBEF950E),
        title: Text(AppLocalizations.of(context).translate('profile')),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: _viewFullImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImageBase64 != null
                          ? MemoryImage(base64Decode(_profileImageBase64!))
                          : AssetImage('assets/default_profile.png')
                              as ImageProvider,
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange,
                        ),
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _isEditing
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Your Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    )
                  : _buildProfileInfo('Name', _nameController.text),
              const SizedBox(height: 16),
              _isEditing
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: TextField(
                        controller: _statusController,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    )
                  : _buildProfileInfo('Status', _statusController.text),
              const SizedBox(height: 16),
              _isEditing
                  ? ElevatedButton(
                      onPressed: _saveProfileData,
                      child: const Text('Save Changes'),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      child: const Text('Edit Profile'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _viewFullImage() {
    if (_profileImageBase64 != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullImageView(imageBase64: _profileImageBase64!),
        ),
      );
    }
  }
}

class FullImageView extends StatelessWidget {
  final String imageBase64;

  FullImageView({required this.imageBase64});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Image View'),
      ),
      body: Center(
        child: Image.memory(base64Decode(imageBase64)),
      ),
    );
  }
}
