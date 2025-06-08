import 'dart:io';
import 'package:deep_fake/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final File? initialImage;
  final String? initialUsername;
  //final String? initialEmail;
  //final String? initialPhone;

  EditProfileScreen({
    this.initialImage,
    this.initialUsername,
    //this.initialEmail,
    //this.initialPhone,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _image;
  final TextEditingController nameController = TextEditingController();
  //final TextEditingController phoneController = TextEditingController();

  bool _isLoading = false;

  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _image = widget.initialImage;
    nameController.text = widget.initialUsername ?? '';
    //phoneController.text = widget.initialPhone ?? '';
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _profileService.updateProfile(
        fullName: nameController.text,
        //phone: phoneController.text,
        profileImage: _image,
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, {
          'image': _image,
          'username': nameController.text,
          //'phone': phoneController.text,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : AssetImage('assets/gallery_placeholder.png')
                              as ImageProvider,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.edit, size: 16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Full Name'),
                  ),
                  //SizedBox(height: 10),
                  //TextField(
                    //controller: phoneController,
                    //decoration: InputDecoration(labelText: 'Phone'),
                  //),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: nameController.text.trim().isEmpty //||
                            //phoneController.text.trim().isEmpty
                        ? null
                        : _updateProfile,
                    child: Text('Update Profile'),
                  ),
                ],
              ),
            ),
    );
  }
}
