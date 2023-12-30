import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:msika_wathu/views/buyer/nav_screens/screens/homeProduct.dart/product_details_screen.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreenProducts extends StatefulWidget {
  const HomeScreenProducts({Key? key}) : super(key: key);

  @override
  State<HomeScreenProducts> createState() => _HomeScreenProductsState();
}

class _HomeScreenProductsState extends State<HomeScreenProducts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            // Shimmer loading while waiting for data
            return const ShimmerProductsList();
          }

          final products = snapshot.data!.docs;

          if (products.isEmpty) {
            // Display a message when there are no products available
            return const Center(
              child: Text(
                'We do not have products at the moment.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          return ListView(
            children: [
              for (int index = 0; index < products.length; index += 2)
                Row(
                  children: [
                    Expanded(
                      child: ProductCard(
                        productName: products[index]['productName'],
                        imageUrlList:
                            List<String>.from(products[index]['imageUrlList']),
                        productPrice:
                            products[index]['productPrice'].toDouble(),
                        sellerName: products[index]['businessName'],
                        sellerId: products[index]['vendorId'],
                        productId: products[index]['productId'],
                        onTap: () {
                          final productData =
                              products[index].data() as Map<String, dynamic>;
                          final productId = productData['productId'] as String?;
                          if (productId != null) {
                            // Navigate to the product details screen when tapped
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProductDetails(
                                  productId: productId,
                                  productData: productData,
                                ),
                              ),
                            );
                          } else {
                            print(
                                'productId is null or not found in productData');
                          }
                        },
                      ),
                    ),
                    if (index + 1 < products.length)
                      Expanded(
                        child: ProductCard(
                          productName: products[index + 1]['productName'],
                          imageUrlList: List<String>.from(
                              products[index + 1]['imageUrlList']),
                          productPrice:
                              products[index + 1]['productPrice'].toDouble(),
                          sellerName: products[index + 1]['businessName'],
                          sellerId: products[index + 1]['vendorId'],
                          productId: products[index + 1]['productId'],
                          onTap: () {
                            final productData = products[index + 1].data()
                                as Map<String, dynamic>;
                            final productId =
                                productData['productId'] as String?;
                            if (productId != null) {
                              // Navigate to the product details screen when tapped
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProductDetails(
                                    productId: productId,
                                    productData: productData,
                                  ),
                                ),
                              );
                            } else {
                              print(
                                  'productId is null or not found in productData');
                            }
                          },
                        ),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class ShimmerProductsList extends StatelessWidget {
  const ShimmerProductsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5, // You can adjust the number of shimmer items
      itemBuilder: (context, index) {
        return const ShimmerProductCard();
      },
    );
  }
}

class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerProductImage(), // Shimmer for product image
          SizedBox(height: 10),
          ShimmerProductName(), // Shimmer for product name
          SizedBox(height: 8),
          ShimmerSellerName(), // Shimmer for seller name
          SizedBox(height: 8),
          ShimmerProductPrice(), // Shimmer for product price
          SizedBox(height: 8),
          ShimmerAddToCartButton(), // Shimmer for "Add to Cart" button
        ],
      ),
    );
  }
}

class ShimmerProductImage extends StatelessWidget {
  const ShimmerProductImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 150, // Adjusted height for shimmer product image
        color: Colors.grey[300], // Shimmer background color
      ),
    );
  }
}

class ShimmerProductName extends StatelessWidget {
  const ShimmerProductName({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 200, // Adjusted width for shimmer product name
        height: 20,
        color: Colors.grey[300], // Shimmer background color
      ),
    );
  }
}

class ShimmerSellerName extends StatelessWidget {
  const ShimmerSellerName({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 150, // Adjusted width for shimmer seller name
        height: 14,
        color: Colors.grey[300], // Shimmer background color
      ),
    );
  }
}

class ShimmerProductPrice extends StatelessWidget {
  const ShimmerProductPrice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 80, // Adjusted width for shimmer product price
        height: 14,
        color: Colors.grey[300], // Shimmer background color
      ),
    );
  }
}

class ShimmerAddToCartButton extends StatelessWidget {
  const ShimmerAddToCartButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 100, // Adjusted width for shimmer "Add to Cart" button
        height: 30, // Adjusted height for shimmer button
        color: Colors.green.withOpacity(0.6), // Shimmer background color
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final String productName;
  final List<String>? imageUrlList;
  final VoidCallback? onTap;
  final double? productPrice;
  final String? sellerName;
  final String? sellerId;
  final String? productId;

  const ProductCard({
    Key? key,
    required this.productName,
    required this.imageUrlList,
    this.onTap,
    this.productPrice,
    this.sellerName,
    this.productId,
    this.sellerId,
  }) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _currentImageIndex = 0;
  bool addedToCart = false;

  Future<void> checkIfProductInCart() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('cart')
            .where('buyerId', isEqualTo: user.uid)
            .where('productId', isEqualTo: widget.productId)
            .get();

        setState(() {
          addedToCart = querySnapshot.docs.isNotEmpty;
        });
      }
    } catch (error) {
      print('Error checking cart: $error');
    }
  }

  Future<void> addToCart(BuildContext context) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final cartItem = {
          'vendorId': widget.sellerId,
          'buyerId': user.uid,
          'productQuantity': 1,
          'productId': widget.productId,
        };

        final querySnapshot = await FirebaseFirestore.instance
            .collection('cart')
            .where('buyerId', isEqualTo: user.uid)
            .where('productId', isEqualTo: widget.productId)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product already in the cart'),
            ),
          );
        } else {
          await FirebaseFirestore.instance.collection('cart').add(cartItem);

          // ignore: use_build_context_synchronously
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.topSlide,
            showCloseIcon: true,
            title: "Success",
            desc: "You have successfully added the product to cart",
          ).show();

          setState(() {
            addedToCart = true;
          });
        }
      } else {
        print('User is not authenticated');
      }
    } catch (error) {
      print('Error adding product to cart: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    // Check if the product is in the cart when the widget is initialized
    checkIfProductInCart();
  }

  @override
  Widget build(BuildContext context) {
    List<String> imageList = (widget.imageUrlList ?? []).cast<String>();

    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Card(
          elevation: 3,
          margin: const EdgeInsets.all(10),
          child: InkWell(
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CachedNetworkImage(
                        imageUrl: imageList.isNotEmpty
                            ? imageList[_currentImageIndex]
                            : '', // Use the correct image URL based on the _currentImageIndex
                        placeholder: (context, url) => Container(
                          width: double.infinity,
                          height: 150,
                          color: Colors.grey[300],
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        // Add borderRadius to give it rounded corners
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  // Ensure consistent height for all cards
                  height: 200, // Adjust this height as needed
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.productName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${widget.productPrice?.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF009689),
                          ),
                        ),
                        Text(
                          'Seller: ${widget.sellerName ?? "N/A"}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(), // Add Spacer to push the button to the bottom
                        ElevatedButton(
                          onPressed: () {
                            addToCart(context);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            backgroundColor: const Color(0xFF009689),
                          ),
                          child: Container(
                            width: 100,
                            height: 30,
                            alignment: Alignment.center,
                            child: Text(
                              addedToCart ? 'In Cart' : 'Add to Cart',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
