import 'package:flutter/material.dart';

class AppBarModified2 extends StatelessWidget {
  final String title;

  const AppBarModified2({
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      height: responsiveHeight(context, 0.15),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF469C46),
      ),
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: responsiveWidth(context, 0.04)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Update this line
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: responsiveTextSize(context, 18),
                color: Colors.white,
              ),
            ),
            SizedBox(
                width: responsiveWidth(
                    context, 0.2)), // Empty space to keep the symmetry
          ],
        ),
      ),
    );
  }

  // Utility functions

  double responsiveWidth(BuildContext context, double fraction) {
    return MediaQuery.of(context).size.width * fraction;
  }

  double responsiveHeight(BuildContext context, double fraction) {
    return MediaQuery.of(context).size.height * fraction;
  }

  double responsiveTextSize(BuildContext context, double size) {
    const double baseScreenWidth = 375.0; // Reference screen width
    return (MediaQuery.of(context).size.width / baseScreenWidth) * size;
  }
}
