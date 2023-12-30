import 'package:flutter/material.dart';

class CartAttributes with ChangeNotifier {
  final String? productName;
  final String? productId;
  final String? imageUrl;
  final int? quantity;
  final double? price;
  final String? vendorId;

  CartAttributes(
      {required this.productName,
      required this.productId,
      required this.imageUrl,
      required this.quantity,
      required this.price,
      required this.vendorId});
}
