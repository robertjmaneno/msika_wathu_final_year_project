import 'package:flutter/material.dart';



class ProductProvider with ChangeNotifier {
  Map<String, dynamic> productData = {
    'productName': '',
    'productPrice': 0.0,
    'productQuantity': 0.0,
    'productSize': '',
    'productColor': '',
    'productCategory': '',
    'productDescription': '',
    'imageUrlList': <String>[],
    'attributes': <String>[],
    'chargeShipping': false,
    'shippingCharge': 0,
  };

  void getFormData({
    String? productName,
    double? productPrice,
    double? quantity,
    String? description,
    String? productSize,
    String? productColor,
    String? category,
    List<String>? imageUrlList,
    List<String>? productAttributes,
    bool? chargeShipping,
    int? shippingCharge,
  }) {
    if (productSize != null) {
      productData['productSize'] = productSize;
    }
    if (productColor != null) {
      productData['productColor'] = productColor;
    }
    if (productName != null) {
      productData['productName'] = productName;
    }
    if (productPrice != null) {
      productData['productPrice'] = productPrice;
    }
    if (productAttributes != null) {
      productData['productAttributes'] = productAttributes;
    }
    if (quantity != null) {
      productData['productQuantity'] = quantity;
    }
    if (category != null) {
      productData['productCategory'] = category;
    }
    if (description != null) {
      productData['productDescription'] = description;
    }
    if (imageUrlList != null) {
      productData['imageUrlList'] = imageUrlList;
    }
    if (chargeShipping != null) {
      productData['chargeShipping'] = chargeShipping;
    }
    if (shippingCharge != null) {
      productData['shippingCharge'] = shippingCharge;
    }

    notifyListeners(); // Notify listeners of changes in productData
  }

  // Function to clear the productData
  void clearProductData() {
    productData = {
      'productName': '',
      'productPrice': 0.0,
      'productQuantity': 0.0,
      'productSize': '',
      'productColor': '',
      'productCategory': '',
      'productDescription': '',
      'imageUrlList': <String>[],
      'attributes': <String>[],
      'chargeShipping': false,
      'shippingCharge': 0,
    };
    notifyListeners(); // Notify listeners of changes in productData
  }
}
