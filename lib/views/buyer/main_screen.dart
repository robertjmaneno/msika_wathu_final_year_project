import 'package:flutter/material.dart';
import 'package:msika_wathu/views/buyer/auth/loging_screan.dart';
import 'package:msika_wathu/views/buyer/nav_screens/cart_screen.dart';
import 'package:msika_wathu/views/buyer/nav_screens/home_screen.dart';
import 'package:msika_wathu/views/buyer/nav_screens/logout_screen.dart';
import 'package:msika_wathu/views/buyer/nav_screens/profile_screen.dart';
import 'package:msika_wathu/views/buyer/nav_screens/screens/buyer_chart.dart';
import 'package:msika_wathu/views/buyer/nav_screens/screens/homeProduct.dart/load_orders.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    LoadOrders(),
    const CartScreen(),
    const ProfileScreen(),
    const BuyerChatWidget(),
    const LogoutScreen(),
  ];

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const BLoginScreen()),
      (route) => false, // Remove all existing routes from the stack
    );
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text('Exit App?')),
        content: const Text('Are you sure you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'No',
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Yes',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: LayoutBuilder(
          builder: (context, constraints) {
            return FractionallySizedBox(
              widthFactor: 1.0,
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
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
                    icon: Icon(Icons.category_rounded),
                    label: 'My Orders',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_basket),
                    label: 'Cart',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_3_rounded),
                    label: 'Profile',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.message),
                    label: 'Chat',
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
      ),
    );
  }
}
