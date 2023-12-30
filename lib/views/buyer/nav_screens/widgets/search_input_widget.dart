import 'package:flutter/material.dart';

class SearchInputWidget extends StatelessWidget {
  const SearchInputWidget({
    Key? key, // Add the 'Key?' parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, left: 14, right: 14, bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 244, 241, 241),
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(13),
        ),
        child: const Padding(
          padding: EdgeInsets.only(left: 20.0),
          child: TextField(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Search',
              hintStyle: TextStyle(fontFamily: 'Poppins'),
              prefixIcon: Icon(
                Icons.search,
                size: 25,
              ),
            ),
            cursorWidth: 2,
            cursorHeight: 28,
          ),
        ),
      ),
    );
  }
}
