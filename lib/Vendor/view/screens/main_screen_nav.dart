import 'package:flutter/material.dart';
import 'package:msika_wathu/Vendor/view/screens/chat_screen.dart';
import 'package:msika_wathu/Vendor/view/screens/logout.dart';
import 'package:msika_wathu/Vendor/view/screens/main_vendor_screen.dart';
import 'package:msika_wathu/Vendor/view/screens/profile_screen.dart';
import 'package:msika_wathu/Vendor/view/screens/received_order.dart';
import 'package:msika_wathu/Vendor/view/screens/upload_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MainVendorScreen(),
    const ReceivedOrdersScreen(),
    const SellerChatWidget(),
    const GeneralScreen(),
    const ProfileScreen(),
    const LogoutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          return FractionallySizedBox(
            widthFactor: 1.0,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.grey[100],
              currentIndex: _selectedIndex,
              onTap: (value) {
                setState(() {
                  _selectedIndex = value;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shop),
                  label: 'Orders',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.money),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.upload_file),
                  label: 'Upload',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_2),
                  label: 'Profile',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.logout),
                  label: 'Logout',
                ),
              ],
              selectedItemColor: Colors.green[600],
              unselectedItemColor: Colors.grey[700],
            ),
          );
        },
      ),
    );
  }
}
