import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductImageWidget extends StatelessWidget {
  final String imageUrl;

  const ProductImageWidget({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) =>
          const CircularProgressIndicator(), // Placeholder while loading
      errorWidget: (context, url, error) =>
          const Icon(Icons.error), // Error widget
      fit: BoxFit.cover, // You can adjust the BoxFit as needed
    );
  }
}
