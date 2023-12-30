import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class UserProvider extends ChangeNotifier {
  String? profileImageUrl;

  void setProfileImageUrl(String url) {
    profileImageUrl = url;
    notifyListeners();
  }
}

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({
    Key? key,
  });

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;
  bool _isLoading = false; // Initialize _isLoading to false

  Future<void> _imagePicker() async {
    // Set loading to true when starting the upload
    setState(() {
      _isLoading = true;
    });

    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
      maxWidth: 150,
    );

    if (pickedImage == null) {
      // Set loading to false when no image is picked
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Upload the image to Firebase Storage
    final Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('user_images/${DateTime.now()}.jpg');
    final UploadTask uploadTask = storageRef.putFile(File(pickedImage.path));

    // Handle the upload task
    uploadTask.whenComplete(() async {
      // Get the download URL of the uploaded image
      final imageUrl = await storageRef.getDownloadURL();

      // Get the UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setProfileImageUrl(imageUrl);

      // Get the current user
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Update the user's profile image URL in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'profileImage': imageUrl,
        });
      }

      // Set loading to false when upload is complete
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
      // Handle errors during the upload
      print('Error uploading image: $error');
      // Set loading to false on error
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: const Color.fromARGB(255, 191, 191, 193),
              foregroundImage: userProvider.profileImageUrl != null
                  ? NetworkImage(userProvider.profileImageUrl!)
                  : null,
            ),
            if (_isLoading)
              const CircularProgressIndicator(), // Show loading indicator if uploading
          ],
        ),
        TextButton(
          onPressed:
              _isLoading ? null : _imagePicker, // Disable button when uploading
          child: const Text(
            'Add image',
            style: TextStyle(color: Colors.green),
          ),
        ),
      ],
    );
  }
}
