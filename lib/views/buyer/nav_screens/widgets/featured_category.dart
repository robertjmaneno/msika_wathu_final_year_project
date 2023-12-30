import 'package:flutter/material.dart';

class FeaturedCategory extends StatefulWidget {
  const FeaturedCategory({super.key});

  @override
  State<FeaturedCategory> createState() => _FeaturedCategoryState();
}

class _FeaturedCategoryState extends State<FeaturedCategory> {
  final List<String> agriculturalCategories = [
    'Crops',
    'Fruits',
    'Vegetables',
    'Nuts',
    'Oilseeds',
    'Roots and Tubers',
    'Cereals',
    'Spices',
    'Beverages',
    'Livestock',
    'Fisheries',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Featured Categories',
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(
            height: 6,
          ),
          SizedBox(
            height: 40,
            child: Row(children: [
              Expanded(
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: agriculturalCategories.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(0.3),
                          child: ActionChip(
                              label: Text(agriculturalCategories[index])),
                        );
                      })),
            ]),
          )
        ],
      ),
    );
  }
}
