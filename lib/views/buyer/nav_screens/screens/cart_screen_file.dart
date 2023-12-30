import 'package:flutter/material.dart';
import 'package:msika_wathu/views/buyer/nav_screens/widgets/payment_screen.dart';
import 'package:msika_wathu/views/buyer/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // Track selected products
  List<String> selectedProductIds = [];
  // To store selected product quantities
  Map<String, int> selectedProductQuantities = {};

  String address = '';

  Future<void> _increaseQuantity(String productId, int currentQuantity) async {
    final updatedQuantity = currentQuantity + 1;
    final currentUser = _auth.currentUser;

    if (currentUser != null) {
      final cartRef = _firestore.collection('cart');
      final cartItemQuery = await cartRef
          .where('buyerId', isEqualTo: currentUser.uid)
          .where('productId', isEqualTo: productId)
          .get();

      if (cartItemQuery.docs.isNotEmpty) {
        final cartItemId = cartItemQuery.docs.first.id;

        // Fetch the product's available quantity
        final productRef = _firestore.collection('products').doc(productId);
        final productSnapshot = await productRef.get();
        final productData = productSnapshot.data() as Map<String, dynamic>;
        final availableQuantity = productData['productQuantity'] ?? 0;

        // Check if the buyer's quantity exceeds the available quantity
        if (updatedQuantity > availableQuantity) {
          const snackBar = SnackBar(
            content: Text('You cannot order more than the available quantity'),
          );
          _scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
          return; // Do not perform the update
        }

        // Update the cart item's quantity
        await cartRef
            .doc(cartItemId)
            .update({'productQuantity': updatedQuantity});
      }
    }
  }

  Future<void> _decreaseQuantity(String productId, int currentQuantity) async {
    if (currentQuantity <= 1) {
      // Show a snackbar to alert the user
      const snackBar = SnackBar(
        content: Text('Minimum quantity is 1'),
      );
      _scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
      return; // Do not perform subtraction
    }

    final updatedQuantity = currentQuantity - 1;
    final currentUser = _auth.currentUser;

    if (currentUser != null) {
      final cartRef = _firestore.collection('cart');
      final cartItemQuery = await cartRef
          .where('buyerId', isEqualTo: currentUser.uid)
          .where('productId', isEqualTo: productId)
          .get();

      if (cartItemQuery.docs.isNotEmpty) {
        final cartItemId = cartItemQuery.docs.first.id;
        await cartRef
            .doc(cartItemId)
            .update({'productQuantity': updatedQuantity});
      }
    }
  }

  Future<void> _deleteCartItem(String cartItemId) async {
    final currentUser = _auth.currentUser;

    if (currentUser != null) {
      final cartRef = _firestore.collection('cart');
      await cartRef.doc(cartItemId).delete();
    }
  }

  Future<void> moveToOrders(List<DocumentSnapshot> cartItems) async {
    final currentUser = _auth.currentUser;

    if (currentUser != null) {
      final cartRef = _firestore.collection('cart');
      final batch = _firestore.batch();
      final uuid = Uuid();

      final ordersCollectionId = uuid.v4();

      for (final cartItem in cartItems) {
        final cartData = cartItem.data() as Map<String, dynamic>;
        final orderData = {
          'productId': cartData['productId'],
          'productQuantity': cartData['productQuantity'],
          'vendorId': cartData['vendorId'],
          'buyerId': currentUser.uid,
          'confirmed': false,
          'intransit': false,
          'collectionId': ordersCollectionId,
          'time': DateTime.now(),
        };

        final orderDocRef = _firestore.collection('orders').doc();
        batch.set(orderDocRef, orderData);

        batch.delete(cartItem.reference);
      }

      await batch.commit();
    }
  }

  Future<void> checkoutSelectedProducts(List<String> selectedProductIds) async {
    final currentUser = _auth.currentUser;

    if (currentUser != null) {
      final cartRef = _firestore.collection('cart');
      final productsRef = _firestore.collection('products');
      double totalPayment = 0.0;

      // Fetch user's address
      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      address = userDoc.data()?['address'] ?? '';

      if (address.isEmpty) {
        await _showAddressInputDialog();
        // if (address.isEmpty) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text('Please add your address first.')),
        //   );
        //   return;
        // }
      }

      final batch = _firestore.batch();

      for (final productId in selectedProductIds) {
        final cartItemQuery = await cartRef
            .where('buyerId', isEqualTo: currentUser.uid)
            .where('productId', isEqualTo: productId)
            .get();

        if (cartItemQuery.docs.isNotEmpty) {
          final cartItem = cartItemQuery.docs.first.data();
          final productSnapshot = await productsRef.doc(productId).get();

          if (productSnapshot.exists) {
            final productData = productSnapshot.data() as Map<String, dynamic>;

            final num currentStock = productData['productQuantity'] ?? 0;
            final num quantityToCheckout = cartItem['productQuantity'] ?? 0;

            if (quantityToCheckout <= currentStock) {
              final double productPrice = productData['productPrice'] ?? 0.0;
              final double subtotal = productPrice * quantityToCheckout;
              totalPayment += subtotal;

              batch.update(cartRef.doc(cartItemQuery.docs.first.id), {
                'checkoutDate': DateTime.now(),
                'address': address,
                'intransit': false,
              });
            } else {
              final snackBar = SnackBar(
                content: Text('Product $productId is out of stock.'),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              return;
            }
          }
        }
      }

      await batch.commit();

      final paymentSuccessful = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(totalPrice: totalPayment),
        ),
      );

      if (paymentSuccessful) {
        final cartItemsQuery = await cartRef
            .where('buyerId', isEqualTo: currentUser.uid)
            .where('productId', whereIn: selectedProductIds)
            .get();

        await moveToOrders(cartItemsQuery.docs);

        selectedProductIds.clear();

        final snackBar = SnackBar(
          content: Text('Checkout completed successfully.'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        final snackBar = SnackBar(
          content: Text('Payment was not successful.'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Future<void> checkoutAllProducts(List<DocumentSnapshot> cartItems) async {
    final currentUser = _auth.currentUser;

    if (currentUser != null) {
      final cartRef = _firestore.collection('cart');
      final productsRef = _firestore.collection('products');
      double totalAmount = 0.0;

      // Fetch user's address
      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      address = userDoc.data()?['address'] ?? '';

      if (address.isEmpty) {
        await _showAddressInputDialog();
        // if (address.isEmpty) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text('Please add your address first.')),
        //   );
        //   return;
        // }
      }

      for (final cartItem in cartItems) {
        final cartData = cartItem.data() as Map<String, dynamic>;
        final productId = cartData['productId'];
        final productSnapshot = await productsRef.doc(productId).get();

        if (productSnapshot.exists) {
          final productData = productSnapshot.data() as Map<String, dynamic>;

          final num currentStock = productData['productQuantity'] ?? 0;
          final num quantityToCheckout = cartData['productQuantity'] ?? 0;

          if (quantityToCheckout <= currentStock) {
            final double productPrice = productData['productPrice'] ?? 0.0;
            final double subtotal = productPrice * quantityToCheckout;
            totalAmount += subtotal;

            await cartRef.doc(cartItem.id).update({
              'checkoutDate': DateTime.now(),
              'intransit': false,
              'address': address,
            });
          } else {
            final snackBar = SnackBar(
              content: Text('This Product is out of stock.'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            return;
          }
        }
      }

      final paymentSuccessful = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(totalPrice: totalAmount),
        ),
      );

      if (paymentSuccessful) {
        await moveToOrders(cartItems);

        final snackBar = SnackBar(
          content: Text('Checkout completed successfully.'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        final snackBar = const SnackBar(
          content: Text(
              'Payment was not successful. Items were not removed from the cart.'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Future<void> _showAddressInputDialog() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;

    if (user == null) {
      // Handle the case where the user is not authenticated.
      return;
    }

    final String buyerId =
        user.uid; // Assuming `buyerId` is the UID of the user

    String address = ''; // Initialize address

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Address'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                address = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Enter your address',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final CollectionReference<Map<String, dynamic>>
                      usersCollection =
                      FirebaseFirestore.instance.collection('users');

                  await usersCollection
                      .doc(buyerId)
                      .update({'address': address});

                  Navigator.of(context).pop(); // Close the dialog
                } catch (e) {
                  print('Error updating address: $e');
                  // Handle any errors here.
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final CartProvider cartProvider = Provider.of<CartProvider>(context);
    final User? currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Cart',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('cart')
                  .where('buyerId', isEqualTo: currentUser?.uid)
                  .snapshots(),
              builder: (context, cartSnapshot) {
                if (cartSnapshot.connectionState == ConnectionState.waiting) {
                  return const ShimmerCartList();
                }

                if (!cartSnapshot.hasData || cartSnapshot.data!.docs.isEmpty) {
                  return const Text('No items in the cart');
                }

                final cartItems = cartSnapshot.data!.docs.toList();

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final cartData =
                        cartItems[index].data() as Map<String, dynamic>;
                    final productId = cartData['productId'];
                    return FutureBuilder<DocumentSnapshot>(
                      future: _firestore
                          .collection('products')
                          .doc(productId)
                          .get(),
                      builder: (context, productSnapshot) {
                        if (productSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const ShimmerProductCard();
                        }

                        if (productSnapshot.hasData) {
                          final productData = productSnapshot.data!.data()
                              as Map<String, dynamic>;

                          return Stack(
                            children: [
                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: const BorderSide(
                                      color: Color.fromARGB(0, 158, 158, 158),
                                      width: 1.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  0, 255, 255, 255),
                                              width: 0.0,
                                            ),
                                          ),
                                          child: Image.network(
                                            productData['imageUrl'],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              productData['productName'],
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'K${(productData['productPrice'] != null && cartData['productQuantity'] != null) ? (productData['productPrice'] * cartData['productQuantity']).toStringAsFixed(2) : 'N/A'}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              productData['businessName'],
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove),
                                            onPressed: () {
                                              _decreaseQuantity(productId,
                                                  cartData['productQuantity']);
                                            },
                                          ),
                                          Text(
                                            cartData['productQuantity']
                                                .toString(),
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: () {
                                              _increaseQuantity(productId,
                                                  cartData['productQuantity']);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              final cartItemId =
                                                  cartItems[index].id;
                                              _deleteCartItem(cartItemId);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                bottom: 0,
                                child: Checkbox(
                                  value: selectedProductIds.contains(productId),
                                  onChanged: (isChecked) {
                                    setState(() {
                                      if (isChecked != null) {
                                        if (isChecked) {
                                          selectedProductIds.add(productId);
                                        } else {
                                          selectedProductIds.remove(productId);
                                        }
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const Text('Product not found');
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (selectedProductIds.isEmpty) {
                      const snackBar = SnackBar(
                        content: Text('No products selected for checkout.'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else {
                      checkoutSelectedProducts(selectedProductIds);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Checkout Selected'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final cartSnapshot = await _firestore
                        .collection('cart')
                        .where('buyerId', isEqualTo: currentUser?.uid)
                        .get();

                    final cartItems = cartSnapshot.docs;

                    if (cartItems.isEmpty) {
                      const snackBar = SnackBar(
                        content: Text('Cart is empty.'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else {
                      checkoutAllProducts(cartItems);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Checkout All'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerCartList extends StatelessWidget {
  const ShimmerCartList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  color: Colors.white,
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 20,
                        width: 100,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 20,
                        width: 150,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: const BorderSide(
              color: Color.fromARGB(0, 158, 158, 158), width: 1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                width: 100,
                color: Colors.white,
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 20,
                      width: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 20,
                      width: 150,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
