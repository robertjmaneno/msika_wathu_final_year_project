import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class HeartBTN extends StatelessWidget {
  const HeartBTN({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('print heart button is pressed');
      },
      child: const Icon(
        IconlyLight.heart,
        size: 22,
        color: Colors.green,
      ),
    );
  }
}
