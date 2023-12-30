import 'package:flutter/material.dart';

showSnack(context, String title) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
    title,
    style: const TextStyle(fontWeight: FontWeight.bold),
  )));
}
