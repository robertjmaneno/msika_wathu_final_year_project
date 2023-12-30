import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:msika_wathu/Vendor/custom_widgets/admin_appBar.dart';

class EditProductScreen extends StatefulWidget {
  final String documentId;
  final String initialProductName;
  final double initialProductPrice;
  final String initialProductDescription;
  final String initialProductColor;
  final String initialProductSize;
  final double initialProductQuantity;

  const EditProductScreen({
    super.key,
    required this.documentId,
    required this.initialProductName,
    required this.initialProductPrice,
    required this.initialProductDescription,
    required this.initialProductColor,
    required this.initialProductSize,
    required this.initialProductQuantity,
  });

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productDescriptionController =
      TextEditingController();
  final TextEditingController _productColorController = TextEditingController();
  final TextEditingController _productSizeController = TextEditingController();
  final TextEditingController _productQuantityController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _productNameController.text = widget.initialProductName;
    _productPriceController.text = widget.initialProductPrice.toString();
    _productDescriptionController.text = widget.initialProductDescription;
    _productColorController.text = widget.initialProductColor;
    _productSizeController.text = widget.initialProductSize;
    _productQuantityController.text = widget.initialProductQuantity.toString();
  }

  void _updateProduct() async {
    try {
      final updatedProductName = _productNameController.text;
      final updatedProductPrice = double.parse(_productPriceController.text);
      final updatedProductDescription = _productDescriptionController.text;
      final updatedProductColor = _productColorController.text;
      final updatedProductSize = _productSizeController.text;
      final updatedProductQuantity =
          double.parse(_productQuantityController.text);

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.documentId)
          .update({
        'productName': updatedProductName,
        'productPrice': updatedProductPrice,
        'productDescription': updatedProductDescription,
        'productColor': updatedProductColor,
        'productSize': updatedProductSize,
        'productQuantity': updatedProductQuantity,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product updated successfully!'),
        ),
      );

      Navigator.of(context).pop(); // Return to the previous screen.
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating product: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(75.0), // Adjust the height as needed,
        child: AdminAppBar(
          title: 'Edit Product',
          imagePath: 'assets/images/edit.png',
        ),
      ),
      body: SingleChildScrollView(
        // Wrap your content with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Name',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _productNameController,
                    onChanged: (value) {
                      // Handle onChanged as needed.
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter product name',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 12.0),
                    ),
                    style:
                        const TextStyle(fontSize: 16.0), // Customize text style
                  ),
                ],
              ),
              const SizedBox(height: 16.0), // Add spacing between fields
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Price',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _productPriceController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      // Handle onChanged as needed.
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter product price',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 12.0),
                    ),
                    style:
                        const TextStyle(fontSize: 16.0), // Customize text style
                  ),
                ],
              ),
              const SizedBox(height: 16.0), // Add spacing between fields
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Description',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _productDescriptionController,
                    onChanged: (value) {
                      // Handle onChanged as needed.
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter product description',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 12.0),
                    ),
                    style:
                        const TextStyle(fontSize: 16.0), // Customize text style
                  ),
                ],
              ),
              const SizedBox(height: 16.0), // Add spacing between fields
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Color',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _productColorController,
                    onChanged: (value) {
                      // Handle onChanged as needed.
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter product color',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 12.0),
                    ),
                    style:
                        const TextStyle(fontSize: 16.0), // Customize text style
                  ),
                ],
              ),
              const SizedBox(height: 16.0), // Add spacing between fields
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Size',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _productSizeController,
                    onChanged: (value) {
                      // Handle onChanged as needed.
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter product size',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 12.0),
                    ),
                    style:
                        const TextStyle(fontSize: 16.0), // Customize text style
                  ),
                ],
              ),
              const SizedBox(height: 16.0), // Add spacing between fields
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Quantity',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _productQuantityController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      // Handle onChanged as needed.
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter product quantity',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 12.0),
                    ),
                    style:
                        const TextStyle(fontSize: 16.0), // Customize text style
                  ),
                ],
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _updateProduct();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green, // Text color
                  minimumSize:
                      const Size(double.infinity, 50), // Make the button longer
                  padding: const EdgeInsets.symmetric(
                      vertical: 16), // Vertical padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
