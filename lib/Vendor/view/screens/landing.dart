import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:msika_wathu/Vendor/models/vendor_user_model.dart';
import 'package:msika_wathu/Vendor/view/screens/main_vendor_screen.dart';
import '../auth/vloging_screan.dart'; // Import the LoginScreen

class Landing extends StatelessWidget {
  const Landing({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final CollectionReference vendorStream =
        FirebaseFirestore.instance.collection('users');

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: vendorStream.doc(auth.currentUser!.uid).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Your Application has been sent to the Administrator',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          VendorUserModel vendorUserModel = VendorUserModel.fromJson(
              snapshot.data!.data()! as Map<String, dynamic>);

          if (vendorUserModel.approved == true) {
            return const MainVendorScreen(); // Navigate to the main farmer screen
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(50), // Rounded profile picture
                  child: Image.network(
                    vendorUserModel.profileImageUrl.toString(),
                    width: 100, // Adjust the size of the profile picture
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  vendorUserModel.businessName.toString(),
                  style: const TextStyle(
                    fontSize: 28, // Increase the font size for business name
                    fontWeight: FontWeight.bold, // Make it bold
                  ),
                ),
                const SizedBox(height: 20), // Increased spacing
                const Text(
                  'Your Application is pending approval by the Administrator.\n\n'
                  'The Administrator will get back to you soon.',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20), // Increased spacing
                TextButton(
                  onPressed: () async {
                    await auth.signOut();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) =>
                            const VLoginScreen(), // Navigate to LoginScreen
                      ),
                    );
                  },
                  child: const Text('Signout'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
