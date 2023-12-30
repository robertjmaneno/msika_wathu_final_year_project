import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:msika_wathu/Vendor/custom_widgets/appBar.dart';
import 'package:msika_wathu/views/buyer/auth/loging_screan.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({Key? key}) : super(key: key);

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  Future<void> _performLogout(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(75.0), // Adjust the height as needed,
        child: Center(
          child: AdminApp(
            title: 'Loging Out',
            imagePath: 'assets/images/loging_out.jpeg',
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 90,
            ),
            const Image(
              image: AssetImage('assets/images/profile_logout.png'),
              height: 200,
              width: 200,
            ),
            const SizedBox(
              height: 20,
            ),
            const Center(
              child: Text(
                'You may press logout to exit the app',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(13.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _showLogOutDialogue(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: const Color(0xFF469C46),
                    ),
                    child: const Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showLogOutDialogue(BuildContext context) async {
  await AwesomeDialog(
    context: context,
    dialogType: DialogType.warning,
    animType: AnimType.topSlide,
    title: "Logout Confirmation",
    desc: "Are you sure you want to logout?",
    btnOkText: "Yes, Logout",
    btnCancelText: "Cancel",
    btnOkColor: Colors.red,
    btnCancelColor: Colors.green,
    showCloseIcon: false,
    btnCancelOnPress: () {},
    btnOkOnPress: () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(seconds: 1),
          transitionsBuilder: (context, animation, animationTime, child) {
            animation = CurvedAnimation(parent: animation, curve: Curves.ease);
            return ScaleTransition(
              alignment: Alignment.center,
              scale: animation,
              child: child,
            );
          },
          pageBuilder: (context, animation, animationTime) =>
              const BLoginScreen(),
        ),
      );
    },
  ).show();
}
