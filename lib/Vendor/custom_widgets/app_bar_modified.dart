import 'package:flutter/material.dart';

class AppBarModified extends StatelessWidget {
  final String title;

  const AppBarModified({
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.15, // Adjusted the height
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF469C46),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width *
                0.04), // Adjusted the padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width *
                  0.2, // Adjusted the spacing
            ),
            Center(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize:
                      responsiveTextSize(context, 18), // Adjusted the font size
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Utility function for responsive text size
  double responsiveTextSize(BuildContext context, double size) {
    const double baseScreenWidth = 375.0; // Reference screen width
    return (MediaQuery.of(context).size.width / baseScreenWidth) * size;
  }
}
