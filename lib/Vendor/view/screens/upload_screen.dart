import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:msika_wathu/Vendor/custom_widgets/admin_appBar.dart';
import 'package:msika_wathu/provider/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:uuid/uuid.dart';
import 'dart:io';

import 'main_vendor_screen.dart';

class GeneralScreen extends StatefulWidget {
  const GeneralScreen({super.key});

  @override
  _GeneralScreenState createState() => _GeneralScreenState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final User? user = _auth.currentUser;

class _GeneralScreenState extends State<GeneralScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<File> _images = [];
  List<String> _imageUrlList = [];
  String? imageUrl;
  List<String> _categoryList = [];
  String? _selectedCategory;
  bool uploading = false;
  bool _chargeShipping = false;
  bool canSave = false;
  final TextEditingController _shippingChargeController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _getCategories();
  }

  Future<void> _getCategories() async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore.collection('categories').get();
      setState(() {
        _categoryList = List<String>.from(
            querySnapshot.docs.map((doc) => doc['categoryName']));
      });
    } catch (e) {
      // Handle errors, e.g., no internet connection, Firestore exceptions
      print('Error fetching categories: $e');
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Set the background color to white
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Upload Successful',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.black, // Set text color to black
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'The product has been uploaded successfully',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black, // Set text color to black
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const MainVendorScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green, // Set the button color to green
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        20.0), // Add rounded corners to the button
                  ),
                ),
                child: const Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white, // Set the text color to white
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> getBusinessName() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // User not signed in
      return null;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final businessName = data['businessName'] as String?;
        return businessName;
      } else {
        // Document doesn't exist
        return null;
      }
    } catch (e) {
      // Error occurred
      print('Error retrieving business name: $e');
      return null;
    }
  }

  Future<void> _chooseImage() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Camera'),
                onTap: () async {
                  final image =
                      await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      if (_images.length < 4) {
                        _images.add(File(image.path));
                      }
                    });
                  }
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  final image =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      if (_images.length < 4) {
                        _images.add(File(image.path));
                      }
                    });
                  }
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _uploadImages(BuildContext context) async {
    try {
      setState(() {
        uploading = true;
      });

      for (var image in _images) {
        Reference ref =
            _storage.ref().child('productImage').child(const Uuid().v4());

        await ref.putFile(image).whenComplete(() async {
          await ref.getDownloadURL().then((value) {
            setState(() {
              _imageUrlList.add(value);
              if (imageUrl == null || imageUrl == '') {
                imageUrl = value;
              } else {
                imageUrl = imageUrl;
              }
            });
          });
        });
      }

      // Once all images are uploaded, you can perform any required actions.
      // For example, you can update the UI or show a completion message.
      setState(() {
        uploading = false;
      });

      // Show the success dialog when the upload is completed
      _showSuccessDialog(context);

      // Return true to indicate success
      return true;
    } catch (error) {
      // Handle any errors here
      print('Error uploading images: $error');
      // Return false to indicate failure
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProductProvider productProvider =
        Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(75.0), // Adjust the height as needed,
        child: AdminAppBar(
          title: 'Upload Products',
          imagePath: 'assets/images/upload.png',
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                // Product Name
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Product Name',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      validator: ((value) {
                        if (value!.isEmpty) {
                          return 'Enter Product name';
                        }
                        return null;
                      }),
                      onChanged: (value) {
                        productProvider.getFormData(
                          productName: value,
                        );
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter product name',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // Product Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Product Price',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      validator: ((value) {
                        if (value!.isEmpty) {
                          return 'Enter Product price';
                        }
                        return null;
                      }),
                      onChanged: (value) {
                        productProvider.getFormData(
                          productPrice: double.parse(value),
                        );
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter product price',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // Product Quantity
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Product Quantity',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      validator: ((value) {
                        if (value!.isEmpty) {
                          return 'Enter Product quantity';
                        }
                        return null;
                      }),
                      onChanged: (value) {
                        try {
                          productProvider.getFormData(
                            quantity: double.parse(value),
                          );
                        } catch (e) {
                          productProvider.getFormData(
                            quantity: 0.0,
                          );
                        }
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter product quantity',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // Select Category Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Category',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    DropdownButtonFormField<String>(
                      validator: ((value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select category';
                        }
                        return null;
                      }),
                      value: _selectedCategory,
                      items: _categoryList.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                        productProvider.getFormData(
                          category: value,
                        );
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Choose a category',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // Product Description
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Product Description',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      validator: ((value) {
                        if (value!.isEmpty) {
                          return 'Enter Product description';
                        }
                        return null;
                      }),
                      onChanged: (value) {
                        productProvider.getFormData(
                          description: value,
                        );
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter product description',
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),

                // Display selected images
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                  ),
                  itemCount: _images.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Stack(
                      alignment: Alignment.topRight,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.file(
                            _images[index],
                            width: 400.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _images.removeAt(index);
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
                if (_images.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Please add at least one image.',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),

                const SizedBox(height: 16.0),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.start, // Align to the left
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: SizedBox(
                        width: 200.0,
                        child: ElevatedButton(
                          onPressed: uploading ? null : _chooseImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Add Photos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Product Color',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.0,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      validator: ((value) {
                        if (value!.isEmpty) {
                          return 'Enter Product color';
                        }
                        return null;
                      }),
                      onChanged: (value) {
                        productProvider.getFormData(
                          productColor: value,
                        );
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter product color',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Product Size',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      validator: ((value) {
                        if (value!.isEmpty) {
                          return 'Enter Product size';
                        }
                        return null;
                      }),
                      onChanged: (value) {
                        productProvider.getFormData(
                          productSize: value,
                        );
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter product size',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                Container(
                  child: CheckboxListTile(
                    title: const Text(
                      'Charge Fixed Shipping Fee per Km',
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    contentPadding: const EdgeInsets.only(left: 0),
                    value: _chargeShipping,
                    onChanged: (value) {
                      setState(() {
                        _chargeShipping = value!;
                        productProvider.getFormData(
                          chargeShipping: _chargeShipping,
                        );
                      });
                    },
                  ),
                ),
                if (_chargeShipping)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shipping Charge',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.0,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        validator: ((value) {
                          if (value!.isEmpty) {
                            return 'Enter shipping charge';
                          }
                          return null;
                        }),
                        onChanged: (value) {
                          productProvider.getFormData(
                            shippingCharge: int.parse(value),
                          );
                        },
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter shipping charge',
                        ),
                      ),
                    ],
                  ),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: uploading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                if (await _uploadImages(context)) {
                                  productProvider.getFormData(
                                    imageUrlList: _imageUrlList,
                                  );

                                  final productId = const Uuid().v4();
                                  await _firestore
                                      .collection('products')
                                      .doc(productId)
                                      .set({
                                    'vendorId': user!.uid,
                                    'businessName': await getBusinessName(),
                                    'productId': productId,
                                    'productName': productProvider
                                        .productData['productName'],
                                    'productCategory': productProvider
                                        .productData['productCategory'],
                                    'productSize': productProvider
                                        .productData['productSize'],
                                    'productColor': productProvider
                                        .productData['productColor'],
                                    'productPrice': productProvider
                                        .productData['productPrice'],
                                    'productDescription': productProvider
                                        .productData['productDescription'],
                                    'productFixedShippingCharge':
                                        productProvider
                                            .productData['shippingCharge'],
                                    'imageUrlList': productProvider
                                        .productData['imageUrlList'],
                                    'productQuantity': productProvider
                                        .productData['productQuantity'],
                                    'imageUrl': imageUrl,
                                  });
                                  productProvider.clearProductData();
                                  _images = <File>[];
                                  imageUrl = '';
                                  _imageUrlList = <String>[];
                                  _formKey.currentState?.reset();
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: uploading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                ),
                              ),
                      ),
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
