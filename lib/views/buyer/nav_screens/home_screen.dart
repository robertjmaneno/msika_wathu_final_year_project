import 'package:flutter/material.dart';
import 'package:msika_wathu/views/buyer/nav_screens/screens/home_products.dart';
import 'package:msika_wathu/views/buyer/nav_screens/widgets/banner_widget.dart';
import 'package:msika_wathu/views/buyer/nav_screens/widgets/search_input_widget.dart';
import 'package:msika_wathu/views/buyer/nav_screens/widgets/welcome_text_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Get the device screen width
            double screenWidth = constraints.maxWidth;

            // Determine the font size based on the device screen width
            double fontSize = screenWidth < 600 ? 18 : 20;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Start of welcome text
                  WelcomeText(fontSize: fontSize),

                  // Start of search field
                  const SizedBox(height: 15),
                  const SearchInputWidget(),

                  // Start of Banner screen
                  const SizedBox(height: 2),
                  const BannerWidget(),

                  const SizedBox(
                    height: 400, // Adjust the height as needed
                    child: HomeScreenProducts(),
                  ),
                  //featured category
                  const SizedBox(
                    height: 6,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
