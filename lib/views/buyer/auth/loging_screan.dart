import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:msika_wathu/Vendor/view/screens/dasbooard.dart';
import 'package:msika_wathu/views/buyer/main_screen.dart';
import 'package:msika_wathu/views/buyer/auth/register_screen.dart';

// Initialize Firebase services
final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore =
    FirebaseFirestore.instance; // Firestore instance

// Define the login screen widget
class BLoginScreen extends StatefulWidget {
  const BLoginScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BLoginScreenState createState() => _BLoginScreenState();
}

// Define the state for the login screen
class _BLoginScreenState extends State<BLoginScreen> {
  // Text editing controllers for email and password fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Error messages for email, password, and Firebase-related errors
  String? _emailError;
  String? _passwordError;
  String? _firebaseError;
  bool _isPasswordVisible = false;

  // Loading state to prevent multiple login attempts
  bool _isLoading = false;

  // Function to clear error messages
  void _clearErrors() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _firebaseError = null;
    });
  }

  // Function to handle the login process
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    _clearErrors(); // Clear any previous error messages

    // Validate email
    if (email.isEmpty) {
      setState(() {
        _emailError = 'Email cannot be empty';
      });
    } else if (!isValidEmail(email)) {
      setState(() {
        _emailError = 'Enter a valid email';
      });
    }

    // Validate password
    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password cannot be empty';
      });
    }

    // If there are validation errors, return early
    if (_emailError != null || _passwordError != null) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // Attempt to sign in with Firebase Authentication
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Check the isSeller flag in Firestore for the user
        final DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(user.uid).get();

        if (userSnapshot.exists) {
          final bool isSeller = userSnapshot['isSeller'] ?? false;

          if (isSeller) {
            // Redirect to the main screen for sellers
            // ignore: use_build_context_synchronously
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
                      return const Dashboard();
                    }));
          } else {
            // Redirect to the BuyerScreen for non-sellers
            // ignore: use_build_context_synchronously
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
                      return const MainScreen();
                    }));
          }
        } else {
          // Handle if user data not found in Firestore
        }
      } else {
        // Handle authentication failure if needed.
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Authentication exceptions
      if (e.code == 'user-not-found') {
        _showFirebaseErrorDialog(
            'Account not found. Would you like to sign up?');
      } else if (e.code == 'wrong-password') {
        _showFirebaseErrorDialog('Wrong email or password. Please try again.');
      } else {
        _showFirebaseErrorDialog('An error occurred. Please try again later.');
      }
    } catch (e) {
      // Handle other exceptions
      _showFirebaseErrorDialog('An error occurred. Please try again later.');
    } finally {
      // Reset loading state
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to show a Firebase error dialog
  void _showFirebaseErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            // Optionally allow users to sign up when the account is not found
            if (message.contains('sign up'))
              TextButton(
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
                            return const RegisterScreen();
                          }));
                },
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Color(0xFF00695C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            // Close the dialog
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Color(0xFF00695C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.white,
          elevation: 2, // Adjust the elevation for a subtle shadow
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 0), // Add top margin of 16 logical pixels
                child: Image.asset(
                  'assets/images/logo.jpg', // Replace with the actual path to your image asset
                  fit: BoxFit
                      .cover, // Adjust the fitting of the image within the container
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Enter Email',
                    prefixIcon: const Icon(Icons.email),
                    border: const OutlineInputBorder(),
                    errorText: _emailError,
                  ),
                ),
              ),
              // Password input field
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Enter Password',
                    prefixIcon: const Icon(Icons.lock), // Icon for password
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ), // Ico
                    border: const OutlineInputBorder(),
                    errorText: _passwordError,
                  ),
                ),
              ),
              // Login button
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLoading
                      ? const Color(0xFF009689)
                      : const Color(0xFF009689),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(355, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text(
                        _isLoading ? 'Logging In...' : 'Login',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              // Display Firebase-related error messages
              if (_firebaseError != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _firebaseError!,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              // Link to the registration screen
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Not a Member?'),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
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
                                return const RegisterScreen();
                              }));
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 15),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to validate email format using RegExp
  bool isValidEmail(String email) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
    );
    return emailRegExp.hasMatch(email);
  }
}
