import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:msika_wathu/Vendor/view/auth/vloging_screan.dart';

class VendorAuthScreen extends StatefulWidget {
  const VendorAuthScreen({
    super.key,
  });

  @override
  State<VendorAuthScreen> createState() => _VendorAuthScreenState();
}

class _VendorAuthScreenState extends State<VendorAuthScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // You can return a loading indicator if needed
          return const CircularProgressIndicator();
        }

        final User? user = snapshot.data;

        if (user == null) {
          // No user is authenticated, navigate to VLoginScreen
          return const VLoginScreen();
        } else {
          // User is authenticated, you can navigate to another screen or return any other widget as needed
          return const Text(
              'Authenticated'); // Replace Placeholder with your desired screen or widget
        }
      },
    );
  }
}
