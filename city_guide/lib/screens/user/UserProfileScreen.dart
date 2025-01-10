import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController _emailController =
      TextEditingController(); // Controller for email input
  final TextEditingController _fullNameController =
      TextEditingController(); // Controller for full name input
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Firebase Authentication instance
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance

  bool _isLoading = false; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Fetch user profile on initialization
  }

  Future<void> _fetchUserProfile() async {
    try {
      setState(() {
        _isLoading = true; // Set loading state to true
      });

      final User? currentUser = _auth.currentUser; // Get current user
      if (currentUser == null)
        throw Exception(
            "No user is logged in."); // Throw exception if no user is logged in

      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get(); // Fetch user document from Firestore
      if (userDoc.exists) {
        final data = userDoc.data(); // Get user data
        _emailController.text =
            data?['email'] ?? ''; // Set email controller text
        _fullNameController.text =
            data?['fullName'] ?? ''; // Set full name controller text
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error fetching profile: $e")), // Show error message
      );
    } finally {
      setState(() {
        _isLoading = false; // Set loading state to false
      });
    }
  }

  Future<void> _updateUserProfile() async {
    try {
      setState(() {
        _isLoading = true; // Set loading state to true
      });

      final User? currentUser = _auth.currentUser; // Get current user
      if (currentUser == null)
        throw Exception(
            "No user is logged in."); // Throw exception if no user is logged in

      await _firestore.collection('users').doc(currentUser.uid).update({
        'email': _emailController.text.trim(), // Update email in Firestore
        'fullName':
            _fullNameController.text.trim(), // Update full name in Firestore
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Profile updated successfully!")), // Show success message
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error updating profile: $e")), // Show error message
      );
    } finally {
      setState(() {
        _isLoading = false; // Set loading state to false
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"), // App bar title
        backgroundColor: const Color(0xFF6995B1), // App bar background color
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator if loading
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Edit Profile",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed:
                        _updateUserProfile, // Update user profile on button press
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF6995B1), // Button background color
                    ),
                    child: const Text("Save Changes"), // Button text
                  ),
                ],
              ),
            ),
    );
  }
}
