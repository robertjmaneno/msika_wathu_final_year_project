import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:msika_wathu/Vendor/custom_widgets/profile_menu.dart';
import 'package:msika_wathu/views/buyer/auth/loging_screan.dart';
import 'package:msika_wathu/views/buyer/edit_buyer.dart';
import 'package:msika_wathu/views/buyer/forgot_password.dart';
import 'package:msika_wathu/views/buyer/nav_screens/cart_screen.dart';
import 'package:msika_wathu/views/buyer/nav_screens/screens/homeProduct.dart/load_orders.dart';

class UserImage extends StatelessWidget {
  const UserImage({Key? key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                    animation =
                        CurvedAnimation(parent: animation, curve: Curves.ease);
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
            text: 'My Cart',
            onChanged: (Null) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(seconds: 1),
                  transitionsBuilder:
                      (context, animation, animationTime, child) {
                    animation =
                        CurvedAnimation(parent: animation, curve: Curves.ease);
                    return ScaleTransition(
                      alignment: Alignment.center,
                      scale: animation,
                      child: child,
                    );
                  },
                  pageBuilder: (context, animation, animationTime) {
                    return const CartScreen();
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
            text: 'My Orders',
            onChanged: (Null) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(seconds: 1),
                  transitionsBuilder:
                      (context, animation, animationTime, child) {
                    animation =
                        CurvedAnimation(parent: animation, curve: Curves.ease);
                    return ScaleTransition(
                      alignment: Alignment.center,
                      scale: animation,
                      child: child,
                    );
                  },
                  pageBuilder: (context, animation, animationTime) {
                    return LoadOrders();
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
                    animation =
                        CurvedAnimation(parent: animation, curve: Curves.ease);
                    return ScaleTransition(
                      alignment: Alignment.center,
                      scale: animation,
                      child: child,
                    );
                  },
                  pageBuilder: (context, animation, animationTime) {
                    return const ResetPassword();
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
                const BLoginScreen(),
          ),
        );
      },
    ).show();
  }
}
