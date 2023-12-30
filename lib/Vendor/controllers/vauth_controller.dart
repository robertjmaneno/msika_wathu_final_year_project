import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseStorage _storage = FirebaseStorage.instance;

class AuthController {
  final ImagePicker _imagePicker = ImagePicker();

  Future<String> uploadProfileImageToStorage(XFile? globalImage) async {
    try {
      if (globalImage == null) {
        throw Exception('Image is null');
      }

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User is not logged in');
      }

      Reference ref = _storage.ref().child('profile').child(user.uid);

      // Read the image file and convert it to bytes
      Uint8List imageBytes = await globalImage.readAsBytes();

      UploadTask uploadTask = ref.putData(imageBytes);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  Future<XFile?> imagePicker(BuildContext context, ImageSource source) async {
    try {
      final pickedImage = await _imagePicker.pickImage(source: source);

      if (pickedImage != null) {
        return pickedImage;
      } else {
        return null;
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('An error occurred while picking an image: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return null;
    }
  }

  Future<String> signUpUsers(
    String email,
    String fullName,
    String phoneNumber,
    String password,
    //XFile? globalImage,
    bool isSeller,
    String businessName,
    bool approved,
    String country,
    String TA,
    String city,
  ) async {
    try {
      if (email.isEmpty &&
          fullName.isEmpty &&
          phoneNumber.isEmpty &&
          password.isEmpty &&
          businessName.isEmpty &&
          city.isEmpty &&
          country.isEmpty &&
          TA.isEmpty) {
        return 'Please fill in all the fields.';
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //String profileImageUrl = await uploadProfileImageToStorage(globalImage);
      User? user = userCredential.user;
      if (user != null) {
        // Store additional user information in Firestore
        await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'email': email,
          'address': '',
          'profileImageUrl': 'https://i.pinimg.com/550x/18/b9/ff/18b9ffb2a8a791d50213a9d595c4dd52.jpg',
          'isSeller': isSeller,
          'approved': true,
          'vendorId': userCredential.user!.uid,
          'businessName': businessName,
          'city': city,
          'country': country,
          'TA': TA,
          // Add more user data fields as needed
        });

        return 'Success';
      } else {
        return 'Registration failed. Please try again later.';
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'weak-password':
            return 'The password provided is too weak.';
          case 'email-already-in-use':
            return 'The account already exists for that email.';
          case 'invalid-email':
            return 'The email address is not valid.';
          default:
            return 'Registration failed. Please try again later.';
        }
      }

      return 'An error occurred during registration.';
    }
  }

  Future<String> signInUsers(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return 'Please provide both email and password.';
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        return 'Success';
      } else {
        return 'Login failed. Please check your credentials and try again.';
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            return 'Wrong email or password. Please try again or signup.';
          case 'wrong-password':
            return 'Wrong password provided. Please try again.';
          default:
            return 'Login failed. Please check your credentials and try again.';
        }
      }

      print('Error during login: $e');
      return 'An error occurred during login.';
    }
  }

  Future<void> showAlertDialog(
      BuildContext context, String title, String message,
      [bool showSignupButton = false]) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
            if (showSignupButton)
              TextButton(
                onPressed: () {
                  if (message.contains('signup')) {
                    // Navigate to the signup screen or perform any other action here
                    Navigator.of(context).pop();
                    // Add your navigation logic here
                  }
                },
                child: const Text('Signup'),
              ),
          ],
        );
      },
    );
  }
}
