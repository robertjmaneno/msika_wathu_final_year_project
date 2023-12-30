import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategorySpecific extends StatefulWidget {
  final String categoryName;
  const CategorySpecific({
    super.key,
    required this.categoryName,
  });

  @override
  State<CategorySpecific> createState() => _CategorySpecificState();
}

class _CategorySpecificState extends State<CategorySpecific> {
  late final Stream<QuerySnapshot> _categoryStream;

  @override
  void initState() {
    super.initState();
    try {
      // Initialize the stream inside the initState method
      _categoryStream = FirebaseFirestore.instance
          .collection('products')
          .where('productCategory', isEqualTo: widget.categoryName)
          .snapshots();
      print('Firestore Query Initiated for Category: ${widget.categoryName}');
    } catch (error) {
      print('Firestore Query Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _categoryStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print('Firestore Stream Error: ${snapshot.error}');
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final product = snapshot.data!.docs;

          if (product.isEmpty) {
            print('No Products Found for Category: ${widget.categoryName}');
            return Center(
              child: Text(
                'No Products Found for ${widget.categoryName}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(13.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: product.length,
              itemBuilder: (context, index) {
                final productData =
                    product[index].data() as Map<String, dynamic>;
                final productName = productData['productName'];
                final productPrice = productData['productPrice'];

                return ProductWidget(
                  productName: productName,
                  imageUrl: productData['imageUrl'],
                  productPrice: productPrice,
                  onTap: () {},
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ProductWidget extends StatelessWidget {
  final String productName;
  final double productPrice; // Assuming productPrice is a double
  final String imageUrl;
  final VoidCallback onTap;

  const ProductWidget({
    Key? key,
    required this.productName,
    required this.productPrice,
    required this.imageUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.black.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: SizedBox(
                  height: 125,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'K$productPrice',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    child: IconButton(
                      icon: const Icon(
                        Icons
                            .shopping_cart, // You can replace this with your cart icon
                        color:
                            Colors.green, // Customize the icon color as needed
                      ),
                      onPressed: () {
                        // Add to cart functionality here
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
