import 'package:flutter/material.dart';
import 'package:msika_wathu/views/buyer/models/cart_attributes.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartAttributes> _cartItems = {};
  Map<String, CartAttributes> get getCartItems {
    return _cartItems;
  }

// final String? productName;
//   final String? productId;
//   final String? imageUrl;
//   final int? quantity;
//   final double? price;
//   final String? vendorId;
//   Timestamp deliveryTime;

  void addProductToCart(
    String productName,
    String productId,
    String imageUrl,
    int quantity,
    double price,
    String vendorId,
  ) {
    if (_cartItems.containsKey(productId)) {
      _cartItems.update(
          productId,
          (existingCart) => CartAttributes(
              productName: existingCart.productName,
              productId: existingCart.productId,
              imageUrl: existingCart.imageUrl,
              quantity: existingCart.quantity! + 1,
              price: existingCart.price,
              vendorId: existingCart.vendorId));

      notifyListeners();
    } else {
      _cartItems.putIfAbsent(
          productId,
          () => CartAttributes(
              productName: productName,
              productId: productId,
              imageUrl: imageUrl,
              quantity: quantity,
              price: price,
              vendorId: vendorId));

      notifyListeners();
    }
  }
}
