import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReceivedOrdersScreen extends StatefulWidget {
  const ReceivedOrdersScreen({Key? key}) : super(key: key);

  @override
  _ReceivedOrdersScreenState createState() => _ReceivedOrdersScreenState();
}

class _ReceivedOrdersScreenState extends State<ReceivedOrdersScreen>
    with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length:
          4, // Three tabs: Waiting for Confirmation, Confirmed Orders, In Transit Orders
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(75.0),
        child: AppBar(
          backgroundColor: Colors.green,
          title: const Center(
            child: Text(
              'Received Orders',
              style: TextStyle(color: Colors.white),
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Waiting for Confirmation'),
              Tab(text: 'Confirmed'),
              Tab(text: 'In Transit'),
              Tab(text: 'Delivered'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Content for Tab 1 (Waiting for Confirmation)
          buildOrdersTab('orders', false),
          // Content for Tab 2 (Confirmed Orders)
          buildOrdersTab('pdorders', true),
          // Content for Tab 3 (In Transit Orders)
          buildOrdersTab('intrasitorders', true),
          // Content for Tab 4 (In Transit Orders)
          buildOrdersTab('DeliveredOrders', true),
        ],
      ),
    );
  }

  Widget buildOrdersTab(String collectionName, bool confirmed) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection(collectionName)
          .where('vendorId', isEqualTo: _auth.currentUser?.uid)
          .snapshots(),
      builder: (context, ordersSnapshot) {
        if (ordersSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!ordersSnapshot.hasData || ordersSnapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/empty products.png'),
                Text(confirmed
                    ? 'No confirmed orders available.'
                    : 'No waiting orders available.'),
              ],
            ),
          );
        }

        final orders = ordersSnapshot.data!.docs;

        Map<String, List<QueryDocumentSnapshot>> groupedOrders = {};

        for (final order in orders) {
          final orderData = order.data() as Map<String, dynamic>;
          final collectionId = orderData['collectionId'];

          if (!groupedOrders.containsKey(collectionId)) {
            groupedOrders[collectionId] = [];
          }

          groupedOrders[collectionId]!.add(order);
        }

        return ListView.builder(
          itemCount: groupedOrders.length,
          itemBuilder: (context, index) {
            final collectionId = groupedOrders.keys.elementAt(index);
            final ordersForCollection = groupedOrders[collectionId]!;

            // Fetch the 'intransit' value from the first order in the collection
            bool intransit = ordersForCollection.isNotEmpty
                ? ordersForCollection[0]['intransit'] ?? false
                : false;

            return ReceivedOrderCard(
              collectionId: collectionId,
              orders: ordersForCollection,
              intransit: ordersForCollection.isNotEmpty
                  ? ordersForCollection[0]['intransit'] ?? false
                  : false,
              firestore: _firestore,
              auth: _auth,
              confirmed: confirmed,
              deliverd: confirmed,
            );
          },
        );
      },
    );
  }
}

class ReceivedOrderCard extends StatelessWidget {
  final String collectionId;
  final List<QueryDocumentSnapshot> orders;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final bool confirmed;
  final bool intransit;
  final bool deliverd;

  const ReceivedOrderCard({
    required this.collectionId,
    required this.orders,
    required this.firestore,
    required this.auth,
    required this.confirmed,
    required this.intransit,
    required this.deliverd,
    Key? key,
  }) : super(key: key);

  double calculateTotalOrderPrice() {
    double totalOrderPrice = 0;

    for (final orderData in orders) {
      final Map<String, dynamic> orderMap =
          orderData.data() as Map<String, dynamic>;
      final double productPrice = orderMap['productPrice'] ?? 0.0;
      final int productQuantity = orderMap['productQuantity'] ?? 0;
      final bool deliverd = orderMap['deliverd'];
      totalOrderPrice += productPrice * productQuantity;
    }

    return totalOrderPrice;
  }

  Future<void> moveOrderToInTransit() async {
    final batch = firestore.batch();

    for (final orderData in orders) {
      final Map<String, dynamic> orderMap =
          orderData.data() as Map<String, dynamic>;
      orderMap['intransit'] = true;

      // Add the order to 'intrasitorders'
      final intrasitOrderRef = firestore.collection('intrasitorders').doc();
      batch.set(intrasitOrderRef, orderMap);

      // Delete the order from 'pdorders'
      final pdOrderRef = firestore.collection('pdorders').doc(orderData.id);
      batch.delete(pdOrderRef);
    }

    // Commit the batch operation
    await batch.commit();

    // Update the UI as needed
    // Add your UI update code here
  }

  Future<void> moveToPdOrdersAndRemove() async {
    final batch = firestore.batch();

    for (final orderData in orders) {
      final Map<String, dynamic> orderMap =
          orderData.data() as Map<String, dynamic>;
      final String productId = orderMap['productId'];
      final String buyerId = orderMap['buyerId'];

      // Check if the productId and buyerId are not null
      if (productId != null && buyerId != null) {
        // Update the 'confirmed' field to true
        orderMap['confirmed'] = true;

        // Delete the order using the productId and buyerId
        final querySnapshot = await firestore
            .collection('orders')
            .where('productId', isEqualTo: productId)
            .where('buyerId', isEqualTo: buyerId)
            .get();

        for (final doc in querySnapshot.docs) {
          batch.delete(doc.reference);
        }

        // Move the order to the 'pdorders' collection with confirmation status
        final pdOrdersCollection = firestore.collection('pdorders');
        batch.set(pdOrdersCollection.doc(), orderMap);

        // Update the confirmation status in 'pdorders'
        final QuerySnapshot confirmationDocs = await firestore
            .collection('pdorders')
            .where('productId', isEqualTo: productId)
            .where('buyerId', isEqualTo: buyerId)
            .get();

        for (final confirmationDoc in confirmationDocs.docs) {
          batch.update(confirmationDoc.reference, {'confirmed': true});
        }
      }
    }

    // Commit the batch operation
    await batch.commit();

    // Update the UI as needed
    // Add your UI update code here
  }

  // Future<void> updateOrderConfirmation(bool isConfirmed) async {
  //   for (final orderData in orders) {
  //     final Map<String, dynamic> productData =
  //         orderData.data() as Map<String, dynamic>;
  //     final String productId = productData['productId'];
  //     final String buyerId = productData['buyerId'];

  //     // Check if productId and buyerId are not null
  //     if (productId != null && buyerId != null) {
  //       // Update the confirmation status using productId and buyerId
  //       final QuerySnapshot confirmationDocs = await firestore
  //           .collection('pdorders')
  //           .where('productId', isEqualTo: productId)
  //           .where('buyerId', isEqualTo: buyerId)
  //           .get();

  //       for (final confirmationDoc in confirmationDocs.docs) {
  //         await firestore
  //             .collection('pdorders')
  //             .doc(confirmationDoc.id)
  //             .update({'confirmed': isConfirmed});
  //       }
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double totalOrderPrice = calculateTotalOrderPrice();

    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: FutureBuilder<DocumentSnapshot>(
              future:
                  firestore.collection('users').doc(orders[0]['buyerId']).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const Text('Buyer not found');
                }

                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                final String buyerName = userData['fullName'] ?? 'N/A';

                return Text('Buyer: $buyerName');
              },
            ),
          ),
          ListTile(
            title: Text('Order ID: $collectionId'),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                for (final orderData in orders)
                  ProductCard(
                    productId: orderData['productId'],
                    orderData: orderData.data() as Map<String, dynamic>,
                    firestore: firestore,
                    // onConfirmation: (bool isConfirmed) {
                    //updateOrderConfirmation(isConfirmed);
                    // },
                  ),
              ],
            ),
          ),
          Divider(),
          ListTile(
            title: Text('Total Price: \$${totalOrderPrice.toStringAsFixed(2)}'),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!confirmed)
                  Padding(
                    padding: EdgeInsets.only(left: 0),
                    child: ElevatedButton(
                      onPressed: () async {
                        //await updateOrderConfirmation(true);
                        await moveToPdOrdersAndRemove();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                if (!confirmed)
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: ElevatedButton(
                      onPressed: () async {
                        //await updateOrderConfirmation(false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Decline',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                if (confirmed && !intransit)
                  ElevatedButton(
                    onPressed: () async {
                      await moveOrderToInTransit();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Deliver Now',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                if ((confirmed && intransit == true) && (deliverd == false))
                  Text(
                    'Waiting for Confirmation from Buyer',
                    style: TextStyle(color: Colors.orange),
                  ),
                const SizedBox(width: 10),
                if (intransit && deliverd == true)
                  Text(
                    'Order Successfully Delivered',
                    style: TextStyle(color: Colors.green),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String productId;
  final Map<String, dynamic> orderData;
  final FirebaseFirestore firestore;
  // final Function(bool) onConfirmation;

  const ProductCard({
    required this.productId,
    required this.orderData,
    required this.firestore,
    //required this.onConfirmation,
    Key? key,
  }) : super(key: key);

  double calculateProductTotalPrice(Map<String, dynamic> productData) {
    double productPrice = productData['productPrice'] ?? 0.0;
    int productQuantity = orderData['productQuantity'] ?? 0;
    return productPrice * productQuantity;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: firestore.collection('products').doc(productId).get(),
      builder: (context, productSnapshot) {
        if (productSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!productSnapshot.hasData || !productSnapshot.data!.exists) {
          return const Text('Product not found');
        }

        final productData =
            productSnapshot.data!.data() as Map<String, dynamic>;

        final double productTotalPrice =
            calculateProductTotalPrice(productData);

        final List<dynamic> imageUrlList = productData['imageUrlList'] ?? [];
        final List<String> imageUrls = imageUrlList.map((dynamic item) {
          return item.toString();
        }).toList();

        final String productImage = imageUrls.isNotEmpty ? imageUrls[0] : '';

        return ListTile(
          leading: CachedNetworkImage(
            imageUrl: productImage,
            width: 50,
            height: 50,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(productData['productName']),
              Text(
                'Quantity: ${orderData['productQuantity']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 8),
              Text(
                'Price: \$${productTotalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
