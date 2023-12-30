import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:msika_wathu/views/buyer/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyOrdersScreen extends StatefulWidget {
  final List<Map<String, dynamic>> productsData;
  final List<Map<String, dynamic>> productsData1;
  final List<Map<String, dynamic>> productsData3;
  final List<Map<String, dynamic>> productsData4;

  const MyOrdersScreen({
    required this.productsData,
    required this.productsData1,
    required this.productsData3,
    required this.productsData4,
  });

  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

// Function to move items to the DeliveredOrders collection
Future<void> moveItemsToDeliveredOrders(
    List<Map<String, dynamic>> orderItems) async {
  final batch = FirebaseFirestore.instance.batch();

  for (final product in orderItems) {
    final productId = product['productId'] as String;
    final buyerId = product['buyerId'] as String;

    if (productId != null && buyerId != null) {
      // Update the 'confirmed' field to true
      product['deliverd'] = true;

      // Delete the order from the current collection (intrasitorders)
      final currentCollection =
          FirebaseFirestore.instance.collection('intrasitorders');
      final querySnapshot = await currentCollection
          .where('productId', isEqualTo: productId)
          .where('buyerId', isEqualTo: buyerId)
          .get();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Add the order to the DeliveredOrders collection
      final deliveredOrdersCollection =
          FirebaseFirestore.instance.collection('DeliveredOrders');
      batch.set(deliveredOrdersCollection.doc(), product);
    }
  }

  // Commit the batch operation
  await batch.commit();

  // Add your UI update code here if needed
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    Future<bool> _onBackPressed() {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Center(child: Text('Exit App?')),
          content: const Text('Are you sure you want to exit the app?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'No',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ).then((value) => value ?? false);
    }

    return DefaultTabController(
      length: 4,
      child: WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.green,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'My Orders',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(seconds: 1),
                    transitionsBuilder:
                        (context, animation, animationTime, child) {
                      animation = CurvedAnimation(
                          parent: animation, curve: Curves.ease);
                      return ScaleTransition(
                        alignment: Alignment.center,
                        scale: animation,
                        child: child,
                      );
                    },
                    pageBuilder: (context, animation, animationTime) =>
                        const MainScreen(),
                  ),
                );
              },
            ),
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(48),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(
                      text: 'Unconfirmed',
                    ),
                    Tab(
                      text: 'Confirmed',
                    ),
                    Tab(
                      text: 'Intransit',
                    ),
                    Tab(
                      text: 'Delivered',
                    ),
                  ],
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  indicatorColor: Colors.white,
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              buildOrderListView(widget.productsData),
              buildOrderListView(widget.productsData1),
              buildOrderListView(widget.productsData3),
              buildOrderListView(widget.productsData4),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOrderListView(List<Map<String, dynamic>> orderData) {
    final groupedOrders = <String, List<Map<String, dynamic>>>{};

    for (final product in orderData) {
      final collectionId = product['collectionId'] as String;
      if (!groupedOrders.containsKey(collectionId)) {
        groupedOrders[collectionId] = [];
      }
      groupedOrders[collectionId]!.add(product);
    }

    return ListView.builder(
      itemCount: groupedOrders.length,
      itemBuilder: (context, index) {
        final collectionId = groupedOrders.keys.elementAt(index);
        final orderItems = groupedOrders[collectionId]!;
        final order = orderItems.first;

        double orderTotalPrice = 0.0;
        DateTime? orderDate;
        bool isConfirmed = true;
        bool deliverd = true;
        bool intransit = false;

        for (final product in orderItems) {
          final productQuantity = product['productQuantity'] as int;
          final productPrice = product['productPrice'] as double;
          orderTotalPrice += (productPrice * productQuantity);

          if (product['confirmed'] != null && product['confirmed'] == false) {
            isConfirmed = false;
          }

          if (product['deliverd'] != null && product['deliverd'] == false) {
            isConfirmed = false;
          }

          if (product['intransit'] != null && product['intransit'] == true) {
            intransit = true;
          }

          if (product['time'] != null) {
            orderDate = product['time'].toDate() as DateTime?;
          }
        }

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                title: Text('Order ID: $collectionId'),
                subtitle: orderDate != null
                    ? Text('Order Date: ${orderDate.toLocal()}')
                    : null,
              ),
              Divider(),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: orderItems.length,
                itemBuilder: (context, itemIndex) {
                  final product = orderItems[itemIndex];
                  final productName = product['productName'] as String;
                  final productQuantity = product['productQuantity'] as int;
                  final imageUrl = product['imageUrl'] as String;
                  final productPrice = product['productPrice'] as double;

                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(productName),
                        ),
                        Text(
                          '\$${(productPrice * productQuantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text('Quantity: $productQuantity'),
                  );
                },
              ),
              Divider(),
              ListTile(
                title: const Text(
                  'Total Price:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                trailing: Text(
                  '\$${orderTotalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: isConfirmed
                    ? intransit
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Order Received?',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ElevatedButton(
                                onPressed: () {
                                  // Handle confirm delivery
                                  moveItemsToDeliveredOrders(
                                      orderItems); // Call the function to move items
                                  // You can add your logic here
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: const Text(
                                  'Confirm Delivery',
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            'Pending Delivery',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pending Confirmation',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Order Date: ${orderDate?.toLocal()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
