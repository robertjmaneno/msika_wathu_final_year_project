import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:msika_wathu/views/buyer/nav_screens/my_orders_screen.dart';

class LoadOrders extends StatefulWidget {
  @override
  _LoadOrdersState createState() => _LoadOrdersState();
}

class _LoadOrdersState extends State<LoadOrders> {
  Future<List<List<Map<String, dynamic>>>> loadOrderData() async {
    final CollectionReference ordersCollection =
        FirebaseFirestore.instance.collection('orders');
    final CollectionReference pdOrdersCollection =
        FirebaseFirestore.instance.collection('pdorders');
    final CollectionReference intrasitOrdersCollection =
        FirebaseFirestore.instance.collection('intrasitorders');
    final CollectionReference deliveredOrdersCollection =
        FirebaseFirestore.instance.collection('DeliveredOrders');
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final currentUserId = user.uid;

      final ordersQuery =
          ordersCollection.where('buyerId', isEqualTo: currentUserId).get();
      final pdOrdersQuery =
          pdOrdersCollection.where('buyerId', isEqualTo: currentUserId).get();
      final intrasitOrdersQuery = intrasitOrdersCollection
          .where('buyerId', isEqualTo: currentUserId)
          .get();
      final deliveredOrdersQuery = deliveredOrdersCollection
          .where('buyerId', isEqualTo: currentUserId)
          .get();

      final queryResults = await Future.wait([
        ordersQuery,
        pdOrdersQuery,
        intrasitOrdersQuery,
        deliveredOrdersQuery,
      ]);

      final List<Map<String, dynamic>> ordersData = [];
      final List<Map<String, dynamic>> ordersData1 = [];
      final List<Map<String, dynamic>> ordersData3 = [];
      final List<Map<String, dynamic>> ordersData4 = [];

      // Create a set to store unique product IDs for each order type
      final Set<String> productIds = Set<String>();

      for (final querySnapshot in queryResults) {
        querySnapshot.docs.forEach((document) {
          final orderData = document.data() as Map<String, dynamic>;
          final productId = orderData['productId'] as String?;

          if (productId != null) {
            // Add productId to the set
            productIds.add(productId);

            if (querySnapshot == queryResults[0]) {
              ordersData.add(orderData);
            } else if (querySnapshot == queryResults[1]) {
              ordersData1.add(orderData);
            } else if (querySnapshot == queryResults[2]) {
              ordersData3.add(orderData);
            } else if (querySnapshot == queryResults[3]) {
              ordersData4.add(orderData);
            }
          }
        });
      }

      // Fetch product details for unique product IDs
      final Map<String, Map<String, dynamic>> productDetails = {};

      for (final productId in productIds) {
        final productDocument = await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();

        if (productDocument.exists) {
          final productData = productDocument.data() as Map<String, dynamic>;
          productDetails[productId] = {
            'productName': productData['productName'],
            'imageUrl': productData['imageUrl'],
            'productPrice': productData['productPrice'],
          };
        }
      }

      // Add product details to ordersData for each order type
      for (final orderData in [
        ordersData,
        ordersData1,
        ordersData3,
        ordersData4
      ]) {
        for (final orderItem in orderData) {
          final productId = orderItem['productId'] as String?;
          if (productId != null && productDetails.containsKey(productId)) {
            final productDetail = productDetails[productId]!;
            orderItem['productName'] = productDetail['productName'];
            orderItem['imageUrl'] = productDetail['imageUrl'];
            orderItem['productPrice'] = productDetail['productPrice'];
          }
        }
      }

      return [ordersData, ordersData1, ordersData3, ordersData4];
    } else {
      // Handle the case where the user is not authenticated
      return [
        [],
        [],
        [],
        []
      ]; // Return empty lists or throw an exception as needed.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder(
        future: loadOrderData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final List<List<Map<String, dynamic>>>? allOrdersData =
                snapshot.data;
            final productsData = allOrdersData?[0] ?? [];
            final productsData1 = allOrdersData?[1] ?? [];
            final productsData3 = allOrdersData?[2] ?? [];
            final productsData4 = allOrdersData?[3] ?? [];

            if (productsData.isEmpty &&
                productsData1.isEmpty &&
                productsData3.isEmpty &&
                productsData4.isEmpty) {
              return const Center(
                child: Text('No orders available.'),
              );
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => MyOrdersScreen(
                      productsData: productsData,
                      productsData1: productsData1,
                      productsData3: productsData3,
                      productsData4: productsData4,
                    ),
                  ),
                );
              });
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }
        },
      ),
    );
  }
}
