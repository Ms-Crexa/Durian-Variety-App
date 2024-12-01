import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isPasswordVisible = false;
  String? _profileImageUrl;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Retrieve user data from Firestore
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (snapshot.exists) {
          Map<String, dynamic> userData = snapshot.data()!;
          setState(() {
            _usernameController.text = userData['username'] ?? 'New User';
            _emailController.text = user.email ?? '';
            _profileImageUrl = userData['profile_picture'];
          });
        } else {
          print("User document does not exist in Firestore.");
        }
      } catch (e) {
        print("Failed to load user profile: $e");
      }
    }
  }

  Future<void> _updateProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String? imageUrl = _profileImageUrl;

      // Upload the new profile image if there is one
      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/${user.uid}.jpg');
        await storageRef.putFile(_imageFile!);
        imageUrl = await storageRef.getDownloadURL();
      }

      // Update the user's photo URL in Firebase Authentication
      if (imageUrl != null) {
        await user.updatePhotoURL(imageUrl);
      }

      // Update the username in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'username': _usernameController.text}, SetOptions(merge: true));

      // Update the user's password if a new password is entered
      if (_passwordController.text.isNotEmpty) {
        await user.updatePassword(_passwordController.text);
      }

      await user.reload();
      _auth.currentUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF6FFAA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
          backgroundColor: const Color(0xFFFFEFBF),
          elevation: 0,
          titleSpacing: 0,
          title: const Text(
            'User Settings',
            style: TextStyle(
              fontFamily: 'KodeMono',
              fontWeight: FontWeight.w600,
              color: Color(0xFF464653),
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFF464653),
              size: 30,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFF464653), width: 5),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 120),
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEFBF),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF464653), width: 4),
                      ),
                      child: ClipOval(
                        child: _imageFile != null
                            ? Image.file(_imageFile!, fit: BoxFit.cover)
                            : (_profileImageUrl != null
                                ? Image.network(
                                    _profileImageUrl!,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      } else {
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    (loadingProgress
                                                            .expectedTotalBytes ??
                                                        1)
                                                : null,
                                          ),
                                        );
                                      }
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'lib/assets/images/logo.png',
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    'lib/assets/images/logo.png',
                                    fit: BoxFit.cover,
                                  )),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF464653),
                  fontFamily: 'KodeMono',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFF9F1D7),
                  labelText: 'Username',
                  labelStyle: TextStyle(
                    color: Color(0xFF464653),
                    fontFamily: 'KodeMono',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: Color(0xFF464653), width: 1),
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'KodeMono',
                  color: Color(0xFF464653),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                readOnly: true,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFF9F1D7),
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    fontFamily: 'KodeMono',
                    color: Color(0xFF464653),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: Color(0xFF464653), width: 1),
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'KodeMono',
                  color: Color(0xFF464653),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF9F1D7),
                  labelText: 'New Password',
                  labelStyle: const TextStyle(
                    color: Color(0xFF464653),
                    fontFamily: 'KodeMono',
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: Color(0xFF464653), width: 1),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color(0xFF464653),
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'KodeMono',
                  color: Color(0xFF464653),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEFBF),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(
                      fontFamily: 'KodeMono',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: const BorderSide(
                      color: Color(0xFF464653),
                      width: 3,
                    ),
                  ),
                  onPressed: () async {
                    await _updateProfile();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully!'),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Color(0xFF464653),
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
}
