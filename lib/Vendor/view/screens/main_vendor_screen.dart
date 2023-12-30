import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:msika_wathu/Vendor/view/screens/edit_product_screen.dart';
import 'package:msika_wathu/Vendor/view/screens/profile_screen.dart';
import 'package:msika_wathu/Vendor/view/screens/upload_screen.dart';

class MainVendorScreen extends StatefulWidget {
  const MainVendorScreen({Key? key}) : super(key: key);

  @override
  _MainVendorScreenState createState() => _MainVendorScreenState();
}

class _MainVendorScreenState extends State<MainVendorScreen> {
  late Stream<QuerySnapshot> productsStream;
  List<DocumentSnapshot> filteredProducts = [];
  Map<String, dynamic> userData = {};
  bool isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    initUserData();
    productsStream = FirebaseFirestore.instance
        .collection('products')
        .where('vendorId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    // Listen for changes in the 'products' collection
    productsStream.listen((snapshot) {
      // Handle the snapshot here (e.g., update local data)
      if (!snapshot.metadata.isFromCache) {
        // This block only executes if the data is from the server (not cached)
        // Update your local data with the new snapshot
        setState(() {
          // Clear existing data
          filteredProducts.clear();
          // Add new data from the snapshot
          filteredProducts.addAll(snapshot.docs);
        });
      }
    });
  }

  Future<void> initUserData() async {
    try {
      final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userSnapshot.exists) {
        Map<String, dynamic> user = userSnapshot.data() as Map<String, dynamic>;
        setState(() {
          userData = user;
        });
      } else {
        print('Document does not exist');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void filterProducts(QuerySnapshot snapshot, String searchQuery) {
    Future.delayed(Duration.zero, () {
      setState(() {
        // Remove all spaces except for the first character
        String cleanedSearchQuery = searchQuery.replaceAll(' ', '').isEmpty
            ? ' ' // Replace all spaces with a single space if no non-space characters are entered
            : searchQuery.replaceAll(' ', '');

        // Function to remove repeating characters
        String removeRepeatingChars(String input) {
          String result = '';
          for (int i = 0; i < input.length; i++) {
            if (i == 0 || input[i] != input[i - 1]) {
              result += input[i];
            }
          }
          return result;
        }

        cleanedSearchQuery = removeRepeatingChars(cleanedSearchQuery);

        filteredProducts = snapshot.docs.where((doc) {
          final productData = doc.data() as Map<String, dynamic>;
          final productName = removeRepeatingChars(
              productData['productName'].toString().toLowerCase());
          final productColor = removeRepeatingChars(
              productData['productColor'].toString().toLowerCase());
          final productDescription = removeRepeatingChars(
              productData['productDescription'].toString().toLowerCase());
          final productPrice = removeRepeatingChars(
              productData['productPrice'].toString().toLowerCase());
          final productSize = removeRepeatingChars(
              productData['productSize'].toString().toLowerCase());
          final productCategory = removeRepeatingChars(
              productData['productCategory'].toString().toLowerCase());

          // Define a custom matching function
          bool customMatch(String attribute) {
            for (int i = 0; i <= attribute.length - 4; i++) {
              for (int j = 4; j <= attribute.length - i; j++) {
                final substring = attribute.substring(i, i + j);
                if (substring.contains(cleanedSearchQuery.toLowerCase())) {
                  return true;
                }
              }
            }
            return false;
          }

          return customMatch(productName) ||
              customMatch(productColor) ||
              customMatch(productDescription) ||
              customMatch(productPrice) ||
              customMatch(productSize) ||
              customMatch(productCategory);
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Products',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
              });
            },
          ),
        ],
        iconTheme: const IconThemeData(
            color: Colors
                .white), // This line changes the back arrow color to white
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: productsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'You do not have any products',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blueGrey,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GeneralScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009689),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Add Some Products',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            );
          }

          if (isSearching) {
            filterProducts(snapshot.data!, _searchQuery);
          }

          return Column(
            children: [
              if (isSearching)
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 20.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: Colors.green,
                          width: 2.0,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      filterProducts(snapshot.data!, value);
                    },
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: isSearching
                      ? filteredProducts.length
                      : snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var productData = isSearching
                        ? filteredProducts[index].data() as Map<String, dynamic>
                        : snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;

                    String productName = productData['productName'];
                    String productDescription =
                        productData['productDescription'];
                    String productColor = productData['productColor'];
                    String productSize = productData['productSize'];
                    num productPrice = productData['productPrice'];
                    List<String> imageUrlList =
                        List<String>.from(productData['imageUrlList']);
                    num productQuantity = productData['productQuantity'];
                    String documentId = snapshot.data!.docs[index].id;

                    return ProductCard(
                      imageUrls: imageUrlList,
                      productName: productName,
                      productDescription: productDescription,
                      productSize: productSize,
                      productColor: productColor,
                      price: '\$$productPrice',
                      quantity: productQuantity.toString(),
                      documentId: documentId,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final List<String> imageUrls;
  final String productName;
  final String productColor;
  final String productDescription;
  final String productSize;
  final String price;
  final String quantity;
  final VoidCallback? onEditPressed;
  final String documentId;

  const ProductCard({
    super.key,
    required this.imageUrls,
    required this.productName,
    required this.price,
    required this.productDescription,
    required this.productColor,
    required this.productSize,
    required this.quantity,
    required this.documentId,
    this.onEditPressed,
  });

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int currentImageIndex = 0;
  late PageController _pageController;
  late Timer _imageRotationTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentImageIndex);
    _startImageRotation();
  }

  void _startImageRotation() {
    _imageRotationTimer =
        Timer.periodic(const Duration(seconds: 8), (Timer timer) {
      setState(() {
        currentImageIndex = (currentImageIndex + 1) % widget.imageUrls.length;
        _pageController.animateToPage(
          currentImageIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  Future<void> _confirmDeleteProduct() async {
    final bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.documentId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deleted successfully!'),
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting product: $error'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _imageRotationTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: SizedBox(
              height: 160,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.imageUrls.length,
                onPageChanged: (index) {
                  setState(() {
                    currentImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: widget.imageUrls[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.shopping_cart,
                            color: Color.fromARGB(255, 104, 101, 101),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            widget.productName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.monetization_on,
                            color: Color.fromARGB(255, 104, 101, 101),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Price: ${widget.price}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.shopping_basket,
                            color: Color.fromARGB(255, 104, 101, 101),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Quantity: ${widget.quantity}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: <Widget>[
                    SizedBox(
                      width: 125,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProductScreen(
                                documentId: widget.documentId,
                                initialProductName: widget.productName,
                                initialProductPrice:
                                    double.parse(widget.price.substring(1)),
                                initialProductDescription:
                                    widget.productDescription,
                                initialProductColor: widget.productColor,
                                initialProductQuantity:
                                    double.parse(widget.quantity.substring(1)),
                                initialProductSize: widget.productSize,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 125,
                      child: ElevatedButton.icon(
                        onPressed: () => _confirmDeleteProduct(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
