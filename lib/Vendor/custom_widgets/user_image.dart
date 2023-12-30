import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:msika_wathu/Vendor/custom_widgets/profile_menu.dart';
import 'package:msika_wathu/Vendor/view/auth/vloging_screan.dart';
import 'package:msika_wathu/Vendor/view/screens/dasbooard.dart';
import 'package:msika_wathu/Vendor/view/screens/edit_profile_screen.dart';
import 'package:msika_wathu/Vendor/view/screens/received_order.dart';
import 'package:msika_wathu/forgot_password.dart';

class UserImage extends StatelessWidget {
  const UserImage({Key? key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            ProfileMenu(
              icon: 'assets/images/edit.svg',
              text: 'Edit your profile',
              onChanged: (Null) {
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
                      return const EditProfileScreen();
                    },
                  ),
                );
              },
            ),
            const SizedBox(
              height: 8, // Adjust the height as needed
            ),
            ProfileMenu(
              icon: 'assets/images/shopping-bag.svg',
              text: 'Received Orders',
              onChanged: (Null) {
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
                      return const ReceivedOrdersScreen();
                    },
                  ),
                );
              },
            ),
            const SizedBox(
              height: 8, // Adjust the height as needed
            ),
            ProfileMenu(
              icon: 'assets/images/navigation-2.svg',
              text: 'Dashboard',
              onChanged: (Null) {
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
                    },
                  ),
                );
              },
            ),
            const SizedBox(
              height: 8, // Adjust the height as needed
            ),
            ProfileMenu(
              icon: 'assets/images/key.svg',
              text: 'Reset Password',
              onChanged: (Null) {
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
                    },
                  ),
                );
              },
            ),
            const SizedBox(
              height: 8, // Adjust the height as needed
            ),
            ProfileMenu(
              icon: 'assets/images/log-out.svg',
              text: 'Log Out',
              onChanged: (Null) {
                _showLogOutDialogue(context);
              },
            ),
          ],
        ),
      ),
    );
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
              animation =
                  CurvedAnimation(parent: animation, curve: Curves.ease);
              return ScaleTransition(
                alignment: Alignment.center,
                scale: animation,
                child: child,
              );
            },
            pageBuilder: (context, animation, animationTime) =>
                const VLoginScreen(),
          ),
        );
      },
    ).show();
  }
}
