import 'dart:io'; // ⬅️ Tambahkan
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // ⬅️ Tambahkan
import 'package:path_provider/path_provider.dart'; // ⬅️ Tambahkan
import 'package:path/path.dart' as p; // ⬅️ Tambahkan

import '../controllers/reading_controller.dart';
import '../models/reading_item.dart';
import 'widgets/book_image_widget.dart'; // ⬅️ Tambahkan

class EditView extends StatelessWidget {
  EditView({super.key});

  final controller = Get.find<ReadingController>();
  final ReadingItem item = Get.arguments;

  final textController = TextEditingController();
  // Hapus imageUrlController
  
  final pickedTags = <String>[].obs;
  // Variabel untuk menyimpan path gambar
  final imagePath = Rx<String?>(null); // ⬅️ Tambahkan

  // Fungsi untuk memilih gambar
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Salin file ke direktori aplikasi yang aman
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = p.basename(image.path);
      final savedImage = await File(image.path).copy('${appDir.path}/$fileName');
      
      imagePath.value = savedImage.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    textController.text = item.title;
    pickedTags.value = item.tags;
    imagePath.value = item.imageUrl; // ⬅️ Ambil path/url gambar yang ada

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Bacaan'),
      ),
      body: SingleChildScrollView( // ⬅️ Bungkus dengan SingleChildScrollView
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- BAGIAN INPUT GAMBAR ---
            Obx(() => BookImageWidget(
                  imageUrl: imagePath.value, // ⬅️ Gunakan widget pintar
                  height: 200,
                  width: 150,
                )),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Ganti Gambar Sampul'),
              onPressed: _pickImage, // ⬅️ Panggil fungsi pilih gambar
            ),
            // --- AKHIR BAGIAN GAMBAR ---

            const SizedBox(height: 16),
            TextField(
              controller: textController,
              decoration: InputDecoration(labelText: 'Judul Bacaan'),
            ),
            
            // Hapus TextField untuk Image URL
            
            const SizedBox(height: 12),
            Obx(() {
              final tags = controller.tags;
              return Wrap(
                spacing: 8,
                runSpacing: 4,
                children: tags
                    .map((t) => Obx(() => FilterChip(
                          label: Text(t),
                          selected: pickedTags.contains(t),
                          onSelected: (_) {
                            if (pickedTags.contains(t)) {
                              pickedTags.remove(t);
                            } else {
                              pickedTags.add(t);
                            }
                          },
                        )))
                    .toList(),
              );
            }),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  controller.updateItem(
                    item.id,
                    textController.text,
                    tags: pickedTags.toList(),
                    imageUrl: imagePath.value, // ⬅️ Kirim path gambar
                  );
                  Get.back();
                }
              },
              child: Text('Update'),
            )
          ],
        ),
      ),
    );
  }
}