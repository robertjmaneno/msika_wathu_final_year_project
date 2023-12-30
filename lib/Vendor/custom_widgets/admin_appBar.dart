import 'package:flutter/material.dart';

class AdminAppBar extends StatelessWidget {
  final String title;
  final String imagePath; // Image path for the picture

  const AdminAppBar({
    required this.title,
    required this.imagePath,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.15,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: const Color(0xFF009689),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.04,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // This will navigate back when the back arrow is pressed.
              },
              icon: const Icon(
                Icons.arrow_back, // Replace with the back arrow icon
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: responsiveTextSize(context, 18),
                      color: Colors.white,
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                        50.0), // Adjust the value to change the amount of rounding
                    child: Image.asset(
                      imagePath,
                      width: responsiveTextSize(context, 40),
                      height: responsiveTextSize(context, 40),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 48.0), // Adjust as needed
          ],
        ),
      ),
    );
  }

  double responsiveTextSize(BuildContext context, double size) {
    const double baseScreenWidth = 375.0;
    return (MediaQuery.of(context).size.width / baseScreenWidth) * size;
  }
}
