import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:msika_wathu/Vendor/view/auth/vloging_screan.dart';
import 'package:msika_wathu/Vendor/view/screens/chat_screen.dart';
import 'package:msika_wathu/Vendor/view/screens/main_screen_nav.dart';
import 'package:msika_wathu/Vendor/view/screens/profile_screen.dart';
import 'package:msika_wathu/Vendor/view/screens/received_order.dart';
import 'package:msika_wathu/Vendor/view/screens/upload_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List images = [
    'assets/images/banner_one.jpg',
    'assets/images/orders.png',
    'assets/images/chat.png',
    'assets/images/upload.png',
    'assets/images/profile.png',
    'assets/images/logout.png'
  ];

  List title = [
    'Product\nManagement',
    'Order\nManagement',
    'Chat',
    'Upload\nProducts',
    'My\nProfile',
    'Logout'
  ];

  // Function to navigate to a specific page based on the index
  void _navigateToPage(int index) {
    // Define your routes in the MaterialApp widget where you set up your app
    switch (index) {
      case 0:
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
                  return const MainScreen();
                }));
        break;
      case 1:
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
                  return const ReceivedOrdersScreen();
                }));
        break;
      case 2:
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
                  return const SellerChatWidget();
                }));
        break;
      case 3:
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
                  return const GeneralScreen();
                }));
        break;
      case 4:
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
                  return const ProfileScreen();
                }));
        break;

      case 5:
        AwesomeDialog(
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
                pageBuilder: (context, animation, animationTime) =>
                    const VLoginScreen(),
              ),
            );
          },
        ).show();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    final bool isPortrait = height > width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: height,
          width: width,
          decoration: const BoxDecoration(color: Color(0xFF469C46)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: height * 0.19,
                  width: width,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 59, right: 60, left: 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              // Wrap your Text widget in an Expanded to prevent overflow
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left:
                                          10), // Adjust left padding as needed
                                  child: Text(
                                    'Farmer \nDashboard',
                                    style: TextStyle(
                                      fontSize: 25,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: height * 0.90,
                  width: width,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isPortrait ? 2 : 3,
                            childAspectRatio: isPortrait ? 1 : 0,
                            mainAxisSpacing: isPortrait ? 16 : 30,
                            crossAxisSpacing: isPortrait ? 16 : 30),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              _navigateToPage(
                                  index); // Navigate to the corresponding page
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                  )
                                ],
                                color: Colors.white,
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    title[index], // Display title
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Image.asset(
                                    images[index],
                                    width: isPortrait ? 100 : 150,
                                    height: isPortrait ? 100 : 150,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
