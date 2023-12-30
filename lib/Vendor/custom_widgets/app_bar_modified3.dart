import 'package:flutter/material.dart';

class AppBarModified3 extends StatelessWidget {
  final String title;
  final ImageProvider trailingImage;  // Change type to ImageProvider

  const AppBarModified3({
    required this.title,
    required this.trailingImage,  // Update the parameter name
    Key? key,
  }) : super(key: key);

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 13,),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: responsiveTextSize(context, 18),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5.0),
                Image(  // Use the Image widget
                  image: trailingImage,
                  width: responsiveTextSize(context, 24),  // Adjust width based on your requirements
                  height: responsiveTextSize(context, 24), // Adjust height based on your requirements
                ),
              ],
            ),
            SizedBox(
                width: responsiveWidth(context, 0.2)),
          ],
        ),
      ),
    );
  }

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


