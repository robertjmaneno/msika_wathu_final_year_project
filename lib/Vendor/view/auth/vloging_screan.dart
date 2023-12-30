import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:msika_wathu/Vendor/view/auth/vregister_screen.dart';
import 'package:msika_wathu/Vendor/view/screens/dasbooard.dart';
import 'package:msika_wathu/forgot_password.dart';
import 'package:msika_wathu/views/buyer/main_screen.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class VLoginScreen extends StatefulWidget {
  const VLoginScreen({Key? key}) : super(key: key);

  @override
  _VLoginScreenState createState() => _VLoginScreenState();
}

class _VLoginScreenState extends State<VLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  String? _firebaseError;
  bool _isLoading = false;
  bool _showPassword = false;

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
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return const Dashboard();
            }));
          } else {
            // Redirect to the BuyerScreen for non-sellers
            // ignore: use_build_context_synchronously
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
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

  void _showFirebaseErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            if (message.contains('sign up'))
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const VRegisterScreen();
                  }));
                },
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.white,
          elevation: 2,
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
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 13.0, right: 13.0),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: const Icon(Icons.email),
                        errorText: _emailError,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0), // Adjust the vertical padding
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 13.0, right: 13.0),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                        errorText: _passwordError,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0), // Adjust the vertical padding
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                          child: Icon(
                            _showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  // Add the code to handle "Forgot Password" here
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
                            return const VendorResetPassword();
                          }));
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.blue, fontSize: 15),
                    ),
                    SizedBox(
                      width: 15,
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Not a Member?',
                    style: TextStyle(fontSize: 15),
                  ),
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
                                return const VRegisterScreen();
                              }));
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.blue, fontSize: 15),
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

  bool isValidEmail(String email) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
    );
    return emailRegExp.hasMatch(email);
  }
}
