import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:msika_wathu/Vendor/custom_widgets/image_picker_widget.dart';
import 'package:msika_wathu/firebase_options.dart';
import 'package:msika_wathu/Vendor/view/auth/vloging_screan.dart';
import 'package:msika_wathu/provider/product_provider.dart';
import 'package:msika_wathu/splashscreen/splash_screen.dart';
import 'package:msika_wathu/views/buyer/auth/loging_screan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:msika_wathu/views/buyer/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Check if a user is already signed in
    User? user = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      title: 'msika_wathu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: user != null
          ? FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.data != null && snapshot.data!.exists) {
                  bool isSeller = snapshot.data!['isSeller'] ?? false;

                  return isSeller
                      ? const SplashScreen() // Navigate to the seller's home page if the user is a seller
                      : const SplashScreen(); // Navigate to the buyer's home page if the user is a buyer
                } else {
                  // Document doesn't exist, take the user to the role selection screen
                  return const SplashScreen();
                }
              },
            )
          : const SplashScreen(),
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customDialogTheme = ThemeData(
      dialogBackgroundColor: Colors.white,
    );
    return WillPopScope(
      onWillPop: () async {
        // Show an exit confirmation dialog
        return await showDialog<bool>(
              context: context,
              builder: (context) {
                return Theme(
                  data: customDialogTheme,
                  child: AlertDialog(
                    title: const Center(
                        child: Text(
                      'Exiting the App',
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.w300),
                    )),
                    content:
                        const Text('Are you sure you want to exit the app?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // Stay in the app
                        },
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () {
                          SystemNavigator.pop();
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                );
              },
            ) ??
            false; // Default to not exiting if the dialog is dismissed
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              'Select your role',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          backgroundColor: Color.fromARGB(255, 1, 133, 122),
          toolbarHeight: 90.0, // Set the desired height here
          automaticallyImplyLeading: false, // Remove the back arrow
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          transitionDuration: const Duration(seconds: 1),
                          transitionsBuilder:
                              (context, animation, animationTime, child) {
                            animation = CurvedAnimation(
                                parent: animation, curve: Curves.ease);
                            return ScaleTransition(
                              alignment: Alignment.center,
                              scale: animation,
                              child: child,
                            );
                          },
                          pageBuilder: (context, animation, animationTime) {
                            return const BLoginScreen();
                          }));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009689),
                  minimumSize: const Size(200, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Adjust the radius as needed
                  ),
                ),
                child: const Text(
                  'Customer',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          transitionDuration: const Duration(seconds: 1),
                          transitionsBuilder:
                              (context, animation, animationTime, child) {
                            animation = CurvedAnimation(
                                parent: animation, curve: Curves.ease);
                            return ScaleTransition(
                              alignment: Alignment.center,
                              scale: animation,
                              child: child,
                            );
                          },
                          pageBuilder: (context, animation, animationTime) {
                            return const VLoginScreen();
                          }));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009689),
                  minimumSize: const Size(200, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Adjust the radius as needed
                  ),
                ),
                child: const Text(
                  'Farmer',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
