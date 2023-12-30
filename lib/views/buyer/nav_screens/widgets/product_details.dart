import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:msika_wathu/views/buyer/custom_widhets/heart_btn.dart';
import 'package:msika_wathu/views/buyer/custom_widhets/text_widget.dart';
import 'package:msika_wathu/views/buyer/services/utils.dart';

class ProductDetailsScreen extends StatefulWidget {
  static const routeName = '/product-details';

  final String productId;
  final Map<String, dynamic> productData; // Define a parameter for product data

  const ProductDetailsScreen(
      {Key? key, required this.productId, required this.productData})
      : super(key: key);

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetailsScreen> {
  Product? _product;
  final _quantityTextController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    // Fetch the product details when the widget is initialized
    getProductDetails(widget.productId).then((product) {
      setState(() {
        _product = product;
      });
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _quantityTextController.dispose();
    super.dispose();
  }

  Future<Product> getProductDetails(String productId) async {
    try {
      final DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (productSnapshot.exists) {
        final Map<String, dynamic> productData =
            productSnapshot.data() as Map<String, dynamic>;

        // Extract the product details
        final String productName = productData['productName'];
        final String productDescription = productData['productDescription'];
        final String sellerName = productData['sellerName'];
        final String imageUrl = productData['imageUrl'];
        final String sellerId = productData['sellerId']; // Add this line

        // Add more fields as needed

        return Product(
          productName: productName,
          productDescription: productDescription,
          sellerName: sellerName,
          imageUrl: imageUrl,
          sellerId: sellerId,

          // Add more fields as needed
        );
      } else {
        throw Exception('Product not found');
      }
    } catch (error) {
      // Handle errors here, e.g., show an error message or log the error
      print('Error fetching product details: $error');
      rethrow; // Rethrow the error to handle it higher up in the widget tree
    }
  }

  Future<void> addToCart(BuildContext context, String sellerId) async {
    try {
      // Get the current user (assuming you're using Firebase Authentication)
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final cartItem = {
          'vendorId': sellerId, // Use the passed sellerId
          'buyerId': user.uid,
          'productQuantity': 1,
          'productId': widget.productId, // Replace with the actual product ID
        };

        // Check if the product already exists in the cart
        final querySnapshot = await FirebaseFirestore.instance
            .collection('cart')
            .where('buyerId', isEqualTo: user.uid)
            .where('productId', isEqualTo: widget.productId)
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product added to cart successfully'),
            ),
          );
        }
      } else {
        // Handle the case where the user is not authenticated.
        print('User is not authenticated');
      }
    } catch (error) {
      // Handle any errors that occur during the process.
      print('Error adding product to cart: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = Utils(context).getScreenSize;
    return Scaffold(
      appBar: AppBar(
        title: Text(_product?.productName ?? 'Product Details'),
      ),
      body: Column(
        children: [
          Flexible(
            flex: 2,
            child: FancyShimmerImage(
              imageUrl: _product?.imageUrl ?? '',
              boxFit: BoxFit.scaleDown,
              width: size.width,
            ),
          ),
          Flexible(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 30, right: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: TextWidget(
                            text: _product?.productName ?? 'Product Name',
                            color: Colors.black,
                            textSize: 25,
                            isTitle: true,
                          ),
                        ),
                        const HeartBTN(),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 30, right: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextWidget(
                          text:
                              '\$${_product!.productPrice?.toStringAsFixed(2) ?? '0.00'}',
                          color: Colors.green,
                          textSize: 22,
                          isTitle: true,
                        ),
                        TextWidget(
                          text: '/Kg',
                          color: Colors.black,
                          textSize: 12,
                          isTitle: false,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Visibility(
                          visible: true,
                          child: Text(
                            '\$3.9',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                decoration: TextDecoration.lineThrough),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                              color: const Color.fromRGBO(63, 200, 101, 1),
                              borderRadius: BorderRadius.circular(5)),
                          child: TextWidget(
                            text: 'Shipping fee per km',
                            color: Colors.white,
                            textSize: 20,
                            isTitle: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      quantityControl(
                        fct: () {
                          if (_quantityTextController.text == '1') {
                            return;
                          } else {
                            setState(() {
                              _quantityTextController.text =
                                  (int.parse(_quantityTextController.text) - 1)
                                      .toString();
                            });
                          }
                        },
                        icon: CupertinoIcons.minus,
                        color: Colors.red,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Flexible(
                        flex: 1,
                        child: TextField(
                          controller: _quantityTextController,
                          key: const ValueKey('quantity'),
                          keyboardType: TextInputType.number,
                          maxLines: 1,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                          ),
                          textAlign: TextAlign.center,
                          cursorColor: Colors.green,
                          enabled: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              if (value.isEmpty) {
                                _quantityTextController.text = '1';
                              } else {}
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      quantityControl(
                        fct: () {
                          setState(() {
                            _quantityTextController.text =
                                (int.parse(_quantityTextController.text) + 1)
                                    .toString();
                          });
                        },
                        icon: CupertinoIcons.plus,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 30),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: 'Total',
                                color: Colors.red.shade300,
                                textSize: 20,
                                isTitle: true,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              FittedBox(
                                child: Row(
                                  children: [
                                    TextWidget(
                                      text:
                                          '\$${_product!.productPrice?.toStringAsFixed(2) ?? '0.00'}/',
                                      color: Colors.black,
                                      textSize: 20,
                                      isTitle: true,
                                    ),
                                    TextWidget(
                                      text: '${_quantityTextController.text}Kg',
                                      color: Colors.black,
                                      textSize: 16,
                                      isTitle: false,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Flexible(
                          child: Material(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: () =>
                                  addToCart(context, _product?.sellerId ?? ''),
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: TextWidget(
                                      text: 'Add to cart',
                                      color: Colors.white,
                                      textSize: 18)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget quantityControl(
      {required Function fct, required IconData icon, required Color color}) {
    return Flexible(
      flex: 2,
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: color,
        child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              fct();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                icon,
                color: Colors.white,
                size: 25,
              ),
            )),
      ),
    );
  }
}

class Product {
  final String productName;
  final String productDescription;
  final double? productPrice;
  final String sellerName;
  final String imageUrl;
  final String? sellerId;

  Product({
    required this.productName,
    required this.productDescription,
    required this.sellerId,
    required this.sellerName,
    this.productPrice,
    required this.imageUrl,
  });
}
