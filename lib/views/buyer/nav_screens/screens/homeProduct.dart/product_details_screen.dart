import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:msika_wathu/views/buyer/nav_screens/screens/buyer_chart.dart';
// Import the intl package for currency formatting

class ProductDetails extends StatefulWidget {
  final Map<String, dynamic> productData;
  const ProductDetails(
      {Key? key, required this.productData, required String productId})
      : super(key: key);

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int quantity = 1; // Start quantity at 1
  double price = 0;
  late Map<String, dynamic> productData;
  bool addedToCart = false;

  @override
  void initState() {
    super.initState();
    // Initialize the productData map
    productData = widget.productData;

    // Fetch seller information from Users collection
    final vendorID = widget.productData['vendorId'];
    FirebaseFirestore.instance
        .collection('users')
        .doc(vendorID)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          // Update seller information in the productData map
          productData['sellerName'] = documentSnapshot['fullName'];
          productData['sellerLocation'] = documentSnapshot['country'];
        });
      } else {
        print('Document does not exist on the Users collection');
      }
    }).catchError((error) {
      print('Error fetching seller information: $error');
    });

    // Calculate the initial price
    updatePrice();
  }

  void incrementQuantity() {
    setState(() {
      quantity++;
      updatePrice();
    });
  }

  void decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
        updatePrice();
      });
    }
  }

  void updatePrice() {
    price = (widget.productData['productPrice'] * quantity) +
        widget.productData['productFixedShippingCharge'];
  }

  void addToCart(BuildContext context) async {
    try {
      // Get the current user (assuming you're using Firebase Authentication)
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final cartItem = {
          'vendorId': widget.productData['vendorId'],
          'buyerId': user.uid,
          'productQuantity': quantity,
          'productId': widget.productData['productId'],
        };

        // Check if the product already exists in the cart
        final querySnapshot = await FirebaseFirestore.instance
            .collection('cart')
            .where('buyerId', isEqualTo: user.uid)
            .where('productId', isEqualTo: widget.productData['productId'])
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Product already exists in the cart, show a SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product already in the cart'),
            ),
          );
        } else {
          // Product doesn't exist in the cart, add it
          await FirebaseFirestore.instance.collection('cart').add(cartItem);

          // Show a success message using a SnackBar
          // ignore: use_build_context_synchronously
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.topSlide,
            showCloseIcon: true,
            title: "Success",
            desc: "You have successfully added the product to cart",
          ).show();
        }
      } else {
        // Handle the case where the user is not authenticated.
        print('User is not authenticated');
      }
    } catch (error) {
      // Handle any errors that occur during the process.
      print('Error adding product to cart: $error');
    }

    setState(() {
      addedToCart = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Format the shipping fee as currency
    final shippingFee = NumberFormat.currency(locale: 'en_US', symbol: '\$')
        .format(productData['productFixedShippingCharge']);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: Text(
          productData['productName'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              margin: const EdgeInsets.all(15),
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: NetworkImage(productData['imageUrl']),
                  fit: BoxFit.cover,
                ),
              ),
              alignment: Alignment.topLeft,
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 152, 151, 151),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          productData['productName'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: IconButton(
                                onPressed: decrementQuantity,
                                icon: const Icon(
                                  Icons.remove,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Text(
                              '$quantity',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: IconButton(
                                onPressed: incrementQuantity,
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      productData['productDescription'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Shipping Fee per Km:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          shippingFee, // Display formatted shipping fee
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Seller:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                productData['sellerName'] ?? 'N/A',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                productData['sellerLocation'] ?? 'N/A',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Total', // Display the updated total price
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'K$price', // Display the updated total price
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Chat',
                        style: TextStyle(color: Colors.green),
                      ),
                      IconButton(
                        onPressed: () {
                          // Handle chat button click

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                chatUser: ChatUser(
                                  userId: widget.productData['vendorId'],
                                  username: widget.productData['sellerName'],
                                  profileImageUrl:
                                      '', // Set the seller's profile image URL here
                                  isSeller:
                                      true, // Assuming sellers are treated as sellers in the chat
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.chat,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      addToCart(context);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                    ),
                    child: Text(addedToCart ? 'In Cart' : 'Add to Cart'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
