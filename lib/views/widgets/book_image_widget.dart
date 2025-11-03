// lib/views/widgets/book_image_widget.dart
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  bool isDataUri = imageUrl!.startsWith('data:');

    if (isDataUri) {
      try {
        // data:[<mediatype>][;base64],<data>
        final uri = imageUrl!;
        final comma = uri.indexOf(',');
        if (comma != -1) {
          final metadata = uri.substring(5, comma); // skip 'data:'
          final isBase64 = metadata.contains('base64');
          final dataPart = uri.substring(comma + 1);
          Uint8List bytes;
          if (isBase64) {
            bytes = base64Decode(dataPart);
          } else {
            bytes = Uint8List.fromList(Uri.decodeFull(dataPart).codeUnits);
          }

          return Image.memory(
            bytes,
            height: height,
            width: width,
            fit: fit,
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
      } catch (e) {
        // fallthrough to placeholder
      }
    }

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
      // Pada Web, Image.file tidak didukung. Jika gambar disimpan sebagai
      // data URI (Image.memory) sebelumnya, itu sudah tertangani di atas.
      // Untuk path lokal pada Web (mis. "file://...") kita tidak bisa
      // menampilkannya — berikan placeholder yang jelas.
      if (kIsWeb) {
        return Container(
          height: height,
          width: width,
          color: Colors.grey[800],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image,
                color: Colors.grey[700],
                size: (height ?? 150) / 3,
              ),
              const SizedBox(height: 8),
              Text(
                'Gambar lokal tidak didukung di Web',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        );
      }

      // Non-web: gunakan Image.file seperti sebelumnya
      try {
        // Normalisasi: hapus prefix file:// jika ada
        String localPath = imageUrl!;
        if (localPath.startsWith('file://')) localPath = localPath.replaceFirst('file://', '');
        // Import dart:io is available on non-web platforms
        final file = File(localPath);
        if (!file.existsSync()) {
          return Container(
            height: height,
            width: width,
            color: Colors.grey[800],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  color: Colors.grey[700],
                  size: (height ?? 150) / 3,
                ),
                const SizedBox(height: 8),
                Text(
                  'Gambar tidak ditemukan',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          );
        }

        return Image.file(
          file,
          height: height,
          width: width,
          fit: fit,
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
      } catch (e) {
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
      }
    }
  }
}