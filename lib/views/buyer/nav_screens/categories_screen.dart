import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:msika_wathu/views/buyer/nav_screens/screens/categorySpecific_widget.dart';

class FirebaseService {
  final CollectionReference categoriesCollection =
      FirebaseFirestore.instance.collection('categories');

  Future<List<Category>> getCategories() async {
    QuerySnapshot querySnapshot = await categoriesCollection.get();
    List<Category> categories = [];

    for (var doc in querySnapshot.docs) {
      categories
          .add(Category.fromMap(doc.data() as Map<String, dynamic>, doc.id));
    }

    return categories;
  }
}

class Category {
  final String id;
  final String categoryName;
  final String image;

  Category({
    required this.id,
    required this.categoryName,
    required this.image,
  });

  factory Category.fromMap(Map<String, dynamic> map, String id) {
    return Category(
      id: id,
      categoryName: map['categoryName'] ?? '',
      image: map['image'] ?? '',
    );
  }
}

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    categories = await _firebaseService.getCategories();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 2;
    const childAspectRatio = 240 / 250;
    const spacing = 10.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Categories',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
      body: categories.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(6),
              child: GridView.count(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                children: categories.map((category) {
                  return CategoriesWidget(
                    catText: category.categoryName,
                    imgPath: category.image,
                  );
                }).toList(),
              ),
            ),
    );
  }
}

class CategoriesWidget extends StatelessWidget {
  final String catText;
  final String imgPath;

  const CategoriesWidget({
    Key? key,
    required this.catText,
    required this.imgPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    TextStyle textStyle = const TextStyle(
      color: Colors.black,
      fontSize: 10,
    );

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CategorySpecific(
                    categoryName: catText,
                  )),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            SizedBox(
              height: screenWidth * 0.3,
              width: screenWidth * 0.3,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imgPath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(catText, style: textStyle),
          ],
        ),
      ),
    );
  }
}
