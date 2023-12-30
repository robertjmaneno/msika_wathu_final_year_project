import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:msika_wathu/Vendor/view/auth/vloging_screan.dart';
import 'package:msika_wathu/Vendor/view/screens/chat_screen.dart';
import 'package:msika_wathu/Vendor/view/screens/main_vendor_screen.dart';
import 'package:msika_wathu/Vendor/view/screens/profile_screen.dart';
import 'package:msika_wathu/Vendor/view/screens/received_order.dart';
import 'package:msika_wathu/Vendor/view/screens/upload_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  // Define icons for each tab
  static const List<IconData> _tabIcons = [
    Icons.home, // Home
    Icons.attach_money, // Earnings
    Icons.person, // Profile (formerly Edit)
    Icons.cloud_upload, // Upload
    Icons.shopping_cart, // Orders
    Icons.logout, // Logout
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        _buildNavItem(0, 'Home'),
        _buildNavItem(1, 'Earnings'),
        _buildNavItem(2, 'Profile'), // Changed "Edit" to "Profile"
        _buildNavItem(3, 'Upload'),
        _buildNavItem(4, 'Orders'),
        _buildNavItem(5, 'Logout'),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: const Color(0xFF009689), // Active tab color
      unselectedItemColor:
          const Color.fromARGB(255, 130, 121, 121), // Inactive tab color
      type: BottomNavigationBarType.fixed, // To show all labels
      backgroundColor: Colors.white, // Background color
      onTap: _onNavItemTapped,
    );
  }

  BottomNavigationBarItem _buildNavItem(int index, String label) {
    return BottomNavigationBarItem(
      icon: Icon(
        _tabIcons[index],
        color: _selectedIndex == index
            ? const Color(0xFF009689)
            : const Color.fromARGB(255, 130, 121, 121),
      ),
      label: label,
    );
  }

  void _onNavItemTapped(int index) {
    if (_selectedIndex == 1 && index == 1) {
      // If "Earnings" tab is already selected, do nothing
      return;
    }

    setState(() {
      _selectedIndex = index; // Set the selected index for all cases

      if (index == 5) {
        // If "Logout" tab is tapped, sign out and navigate to VLoginScreen
        FirebaseAuth.instance.signOut().then((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const VLoginScreen(),
            ),
          );
        });
      }
      if (index == 0) {
        // If "Home" tab is tapped, navigate to your home screen
        // You can replace `YourHomeScreen()` with your actual home screen widget.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainVendorScreen(),
          ),
        );
      }
      if (index == 4) {
        // If "Home" tab is tapped, navigate to your home screen
        // You can replace `YourHomeScreen()` with your actual home screen widget.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ReceivedOrdersScreen(),
          ),
        );
      }
      if (index == 1) {
        // If "Earnings" tab is tapped, navigate to EarningsPage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SellerChatWidget(),
          ),
        );
      }
      if (index == 2) {
        // If "Earnings" tab is tapped, navigate to EarningsPage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        );
      }
      if (index == 3) {
        // If "Upload" tab is tapped, navigate to UploadScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const GeneralScreen(),
          ),
        );
      }
    });
  }
}
