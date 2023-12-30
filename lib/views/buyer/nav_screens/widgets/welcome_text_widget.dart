import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WelcomeText extends StatelessWidget {
  const WelcomeText({
    super.key,
    required this.fontSize,
  });

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: fontSize, left: 25, right: 15),
      child: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top, left: 2, right: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                'Hello, What are you \nlooking for?',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            GestureDetector(
              child: SvgPicture.asset(
                'assets/icons/cart.svg',
                width: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
