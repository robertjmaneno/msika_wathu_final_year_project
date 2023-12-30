import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:msika_wathu/Vendor/custom_widgets/admin_appBar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _taController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initUserData();
  }

  Future<void> initUserData() async {
    try {
      final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userSnapshot.exists) {
        Map<String, dynamic> user = userSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _fullNameController.text = user['fullName'];
          _phoneNumberController.text = user['phoneNumber'];
          _addressController.text = user['address'];
          _businessNameController.text = user['businessName'];
          _cityController.text = user['city'];
          _countryController.text = user['country'];
          _taController.text = user['TA'];
        });
      } else {
        print('Document does not exist');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void _updateUserProfile() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'fullName': _fullNameController.text,
        'phoneNumber': _phoneNumberController.text,
        'address': _addressController.text,
        'businessName': _businessNameController.text,
        'city': _cityController.text,
        'country': _countryController.text,
        'TA': _taController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
        ),
      );

      // Return to the previous screen or navigate to the user's profile page.
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(75.0), // Adjust the height as needed,
        child: AdminAppBar(
          title: 'Update Profile',
          imagePath: 'assets/images/edit_profile.png',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Create TextFormField for each user data field with titles
            buildTextFormField("Full Name", _fullNameController),
            buildTextFormField("Phone Number", _phoneNumberController),
            buildTextFormField("Address", _addressController),
            buildTextFormField("Business Name", _businessNameController),
            buildTextFormField("City", _cityController),
            buildTextFormField("Country", _countryController),
            buildTextFormField("TA", _taController),

            const SizedBox(height: 16.0),

            SizedBox(
              width: double.infinity, // Spans across the screen horizontally
              child: ElevatedButton(
                onPressed: () {
                  _updateUserProfile();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        8.0), // Adjust border radius as needed
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 13.0), // Increase button height
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 20, // Increase font size
                    fontWeight: FontWeight.bold, // Adjust font weight as needed
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextFormField(String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 16.0), // Add vertical padding
          child: Column(
            children: [
              TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Enter $title',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
