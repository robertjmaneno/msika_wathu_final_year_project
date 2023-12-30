import 'package:cloud_firestore/cloud_firestore.dart';


// PROVIDERS

class OrdersProvider {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Fetch a single order by its ID
  Future<Orders> getOrder(String orderId) async {
    try {
      final DocumentSnapshot orderSnapshot =
          await firestore.collection('orders').doc(orderId).get();

      if (orderSnapshot.exists) {
        final orderData = orderSnapshot.data() as Map<String, dynamic>;
        return Orders.fromMap(orderData);
      } else {
        throw Exception('Order not found');
      }
    } catch (e) {
      print('Error fetching order: $e');
      rethrow;
    }
  }

  // Update an order
  Future<void> updateOrder(Orders order) async {
    try {
      await firestore.collection('orders').doc(order.collectionId).update(
        {
          'collectionId': order.collectionId,
          'productQuantity': order.productQuantity,
          'productId': order.productId,
          'vendorId': order.vendorId,
          'confirmed': order.confirmed,
        },
      );
    } catch (e) {
      print('Error updating order: $e');
      rethrow;
    }
  }

  // Stream of orders by a seller ID
  Stream<List<Orders>> getOrdersByBuyerId(String sellerId) {
    final Stream<QuerySnapshot> queryStream = firestore
        .collection('orders')
        .where('buyerId', isEqualTo: sellerId)
        .snapshots();

    return queryStream.map((querySnapshot) {
      final ordersList = querySnapshot.docs.map((orderDoc) {
        final orderData = orderDoc.data() as Map<String, dynamic>;
        return Orders.fromMap(orderData);
      }).toList();
      return ordersList;
    });
  } // Stream of orders by a buyer's ID

  Stream<List<Orders>> getOrdersBySellerId(String buyerId) {
    final Stream<QuerySnapshot> queryStream = firestore
        .collection('orders')
        .where('buyerId', isEqualTo: buyerId)
        .snapshots();

    return queryStream.map((querySnapshot) {
      final ordersList = querySnapshot.docs.map((orderDoc) {
        final orderData = orderDoc.data() as Map<String, dynamic>;
        return Orders.fromMap(orderData);
      }).toList();
      return ordersList;
    });
  }
}

class CartProvider {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Cart> getCart(
      String buyerId, String productId, String vendorId) async {
    try {
      final DocumentSnapshot cartSnapshot = await firestore
          .collection('cart')
          .doc('$buyerId-$productId-$vendorId')
          .get();

      if (cartSnapshot.exists) {
        final cartData = cartSnapshot.data() as Map<String, dynamic>;
        return Cart.fromMap(cartData);
      } else {
        throw Exception('Cart not found');
      }
    } catch (e) {
      // Handle any errors that may occur during the data fetching process
      print('Error fetching cart: $e');
      rethrow;
    }
  }

 Future<void> updateCart(String buyerId, String productId, int productQuantity,
      String vendorId) async {
    try {
      await firestore
          .collection('cart')
          .doc('$buyerId-$productId-$vendorId')
          .set({
        'buyerId': buyerId,
        'productId': productId,
        'productQuantity': productQuantity,
        'vendorId': vendorId,
      });
    } catch (e) {
      print('Error updating cart: $e');
      rethrow;
    }
  }

}


class SellerProvider {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Seller> getSeller(String vendorId) async {
    try {
      final DocumentSnapshot sellerSnapshot =
          await firestore.collection('users').doc(vendorId).get();

      if (sellerSnapshot.exists) {
        final sellerData = sellerSnapshot.data() as Map<String, dynamic>;
        return Seller.fromMap(sellerData);
      } else {
        throw Exception('Seller not found');
      }
    } catch (e) {
      print('Error fetching seller: $e');
      rethrow;
    }
  }

  Future<void> updateSeller(Seller seller) async {
    try {
      await firestore.collection('users').doc(seller.vendorId).update(
        {
          'address': seller.address,
          'approved': seller.approved,
          'businessName': seller.businessName,
          'city': seller.city,
          'country': seller.country,
          'email': seller.email,
          'fullName': seller.fullName,
          'isSeller': seller.isSeller,
          'phoneNumber': seller.phoneNumber,
          'profileImageUrl': seller.profileImageUrl,
        },
      );
    } catch (e) {
      print('Error updating seller: $e');
      rethrow;
    }
  }
}


class BuyerProvider {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Buyer> getBuyer(String userId) async {
    try {
      final DocumentSnapshot buyerSnapshot =
          await firestore.collection('users').doc(userId).get();

      if (buyerSnapshot.exists) {
        final buyerData = buyerSnapshot.data() as Map<String, dynamic>;
        return Buyer.fromMap(buyerData);
      } else {
        throw Exception('Buyer not found');
      }
    } catch (e) {
      // Handle any errors that may occur during the data fetching process
      print('Error fetching buyer: $e');
      rethrow;
    }
  }

  Future<void> updateBuyer(Buyer buyer) async {
    try {
      await firestore.collection('users').doc(buyer.userId).update(
        {
          'address': buyer.address,
          'email': buyer.email,
          'fullName': buyer.fullName,
          'isSeller': buyer.isSeller,
          'phoneNumber': buyer.phoneNumber,
          'profileImage': buyer.profileImage,
        },
      );
    } catch (e) {
      print('Error updating buyer: $e');
      rethrow;
    }
  }

}


class ProductProvider {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Product> getProduct(String productId) async {
    try {
      final DocumentSnapshot productSnapshot =
          await firestore.collection('products').doc(productId).get();

      if (productSnapshot.exists) {
        final productData = productSnapshot.data() as Map<String, dynamic>;
        return Product.fromMap(productData, productId);
      } else {
        throw Exception('Product not found');
      }
    } catch (e) {
      // Handle any errors that may occur during the data fetching process
      print('Error fetching product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await firestore.collection('products').doc(product.productId).update(
        {
          'productName': product.productName,
          'productPrice': product.productPrice,
          'productQuantity': product.productQuantity,
          'imageUrlList': product.imageUrls,
        },
      );
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

}






// MODELS
class Product {
  final String productId;
  final String productName;
  final double productPrice;
  final num productQuantity;
  final List<String> imageUrls;

  Product({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productQuantity,
    required this.imageUrls,
  });

  factory Product.fromMap(Map<String, dynamic> map, String productId) {
    return Product(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productPrice: (map['productPrice'] ?? 0.0).toDouble(),
      productQuantity: map['productQuantity'] ?? 0,
      imageUrls: (map['imageUrlList'] as List<dynamic>)
          .map((item) => item.toString())
          .toList(),
    );

   

  }
  
  void notifyListeners() {}
}


class Orders {
  final String collectionId;
  final int productQuantity; // Change data type to int
  final String vendorId;
  final String productId;
  final bool confirmed;

  Orders({
    required this.collectionId,
    required this.productQuantity,
    required this.productId,
    required this.vendorId,
    required this.confirmed,
  });

  factory Orders.fromMap(Map<String, dynamic> map) {
    return Orders(
      collectionId: map['collectionId'] ?? '',
      productQuantity:
          map['productQuantity'] ?? 0, // Default value for quantity
      productId: map['productId'] ?? '',
      vendorId: map['vendorId'] ?? '',
      confirmed: map['confirmed'] ?? false,
    );
  }

  void notifyListeners() {}
}




class Buyer {
  final String address;
  final String email;
  final String fullName;
  final bool isSeller;
  final String phoneNumber;
  final String profileImage;
  final String userId;

  Buyer({
    required this.address,
    required this.email,
    required this.fullName,
    required this.isSeller,
    required this.phoneNumber,
    required this.profileImage,
    required this.userId,
  });

  factory Buyer.fromMap(Map<String, dynamic> map) {
    return Buyer(
      address: map['address'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      isSeller: map['isSeller'] ?? false,
      phoneNumber: map['phoneNumber'] ?? '',
      profileImage: map['profileImage'] ?? '',
      userId: map['userId'] ?? '',
    );
  }
  void notifyListeners() {}
}


class Seller {
  final String TA;
  final String address;
  final bool approved;
  final String businessName;
  final String city;
  final String country;
  final String email;
  final String fullName;
  final bool isSeller;
  final String phoneNumber;
  final String profileImageUrl;
  final String vendorId;

  Seller({
    required this.TA,
    required this.address,
    required this.approved,
    required this.businessName,
    required this.city,
    required this.country,
    required this.email,
    required this.fullName,
    required this.isSeller,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.vendorId,
  });

  factory Seller.fromMap(Map<String, dynamic> map) {
    return Seller(
      TA: map['TA'] ?? '',
      address: map['address'] ?? '',
      approved: map['approved'] ?? false,
      businessName: map['businessName'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      isSeller: map['isSeller'] ?? false,
      phoneNumber: map['phoneNumber'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      vendorId: map['vendorId'] ?? '',
    );
  }
  void notifyListeners() {}
}


class Cart {
  final String buyerId;
  final String productId;
  final int productQuantity;
  final String vendorId;

  Cart({
    required this.buyerId,
    required this.productId,
    required this.productQuantity,
    required this.vendorId,
  });

  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      buyerId: map['buyerId'] ?? '',
      productId: map['productId'] ?? '',
      productQuantity: map['productQuantity'] ?? 0,
      vendorId: map['vendorId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'productId': productId,
      'productQuantity': productQuantity,
      'vendorId': vendorId,
    };
  }
  void notifyListeners() {}
}
