import 'package:flutter/material.dart';
import 'package:msika_wathu/Vendor/view/auth/vloging_screan.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({Key? key}) : super(key: key);

  Future<void> _performLogout(BuildContext context) async {
    // Simulate a logout process here (replace with your actual logout logic).
    // You can use 'await' here for asynchronous operations.
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Logout Confirmation"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () async {
                        await _performLogout(context);
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const VLoginScreen(),
                          ),
                        );
                      },
                      child: const Text("Yes, Logout"),
                    ),
                  ],
                );
              },
            );
          },
          child: Text("Logout"),
        ),
      ),
    );
  }
}
