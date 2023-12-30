import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({Key? key}) : super(key: key);

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List _bannerImage = [];

  Future<void> getBanners() async {
    final querySnapshot = await _firestore.collection('banner').get();
    for (var doc in querySnapshot.docs) {
      setState(() {
        _bannerImage.add(
          doc['image'],
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getBanners();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _bannerImage.isEmpty
          ? const CircularProgressIndicator() // Show a loading indicator if the list is empty
          : Container(
              height: 160,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: CarouselSlider.builder(
                itemCount: _bannerImage.length,
                itemBuilder: (context, index, realIndex) {
                  final imageUrl = _bannerImage[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit
                          .cover, // Use BoxFit.cover to cover the entire container
                      width: double.infinity,
                      height: 160.0,
                      placeholder: (context, url) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              color: Colors
                                  .white, // Color during shimmer animation
                              width: double.infinity, // Full width
                              height: 160.0, // Full height
                            ),
                          ),
                        );
                      },
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  );
                },
                options: CarouselOptions(
                  height: 160.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: MediaQuery.of(context).size.width / 160.0,
                  viewportFraction:
                      1.0, // Set to 1.0 to cover the entire container
                ),
              ),
            ),
    );
  }
}
