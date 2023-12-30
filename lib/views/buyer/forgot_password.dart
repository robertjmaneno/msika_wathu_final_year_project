import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:msika_wathu/Vendor/custom_widgets/admin_appBar.dart';
import 'package:msika_wathu/views/buyer/auth/loging_screan.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());

      // Show a success message using a snackbar.

      Fluttertoast.showToast(
          msg: "An email has been sent to your email address",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green.shade500,
          textColor: Colors.white,
          fontSize: 16.0);

      // Navigate to the login screen.
      // ignore: use_build_context_synchronously
      Navigator.push(
          context,
          PageRouteBuilder(
              transitionDuration: const Duration(seconds: 1),
              transitionsBuilder: (context, animation, animationTime, child) {
                animation =
                    CurvedAnimation(parent: animation, curve: Curves.ease);
                return ScaleTransition(
                  alignment: Alignment.center,
                  scale: animation,
                  child: child,
                );
              },
              pageBuilder: (context, animation, animationTime) {
                return const BLoginScreen();
              }));
    } catch (e) {
      if (e is FirebaseAuthException) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'An error occurred'),
            duration: const Duration(
                seconds: 3), // You can adjust the duration as needed.
          ),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred'),
            duration:
                Duration(seconds: 3), // You can adjust the duration as needed.
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AdminAppBar(
              title: 'Reset Password',
              imagePath: 'assets/images/reset.png',
            ),
            const SizedBox(
              height: 90,
            ),
            const Image(image: AssetImage('assets/images/pass.png')),
            const SizedBox(
              height: 20,
            ),
            const Center(
              child: Text(
                'Enter the email associated with the account\n and we will send an email with instructions to\nreset your password',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 50),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: Column(
                  children: [
                    _buildTextField("Email", Icons.email),
                    const SizedBox(height: 16),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Validate the form when the "Reset" button is pressed.
                          if (_formKey.currentState!.validate()) {
                            // Handle the form submission here.
                            resetPassword();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: const Color(0xFF469C46),
                        ),
                        child: const Text(
                          "Reset",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon) {
    return TextFormField(
      controller: emailController,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return "Email cannot be empty";
        }
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
          return "Please enter a valid email";
        } else {
          return null;
        }
      },
    );
  }
}
