// lib/views/widgets/book_image_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';

class BookImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;

  const BookImageWidget({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      // Tampilan placeholder jika tidak ada gambar
      return Container(
        height: height,
        width: width,
        color: Colors.grey[800],
        child: Icon(
          Icons.book,
          color: Colors.grey[700],
          size: (height ?? 150) / 2,
        ),
      );
    }

    bool isNetworkImage = imageUrl!.startsWith('http');

    if (isNetworkImage) {
      // Ini adalah URL web
      return Image.network(
        imageUrl!,
        height: height,
        width: width,
        fit: fit,
        // Error builder untuk jika link URL rusak
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: width,
            color: Colors.grey[800],
            child: Icon(
              Icons.broken_image,
              color: Colors.grey[700],
              size: (height ?? 150) / 3,
            ),
          );
        },
      );
    } else {
      // Ini adalah File Path lokal
      final file = File(imageUrl!);
      return Image.file(
        file,
        height: height,
        width: width,
        fit: fit,
        // Error builder untuk jika file lokal tidak ditemukan
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: width,
            color: Colors.grey[800],
            child: Icon(
              Icons.broken_image,
              color: Colors.grey[700],
              size: (height ?? 150) / 3,
            ),
          );
        },
      );
    }
  }
}