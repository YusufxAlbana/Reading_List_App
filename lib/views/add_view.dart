import 'dart:io'; // ⬅️ Tambahkan
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // ⬅️ Tambahkan
import 'package:path_provider/path_provider.dart'; // ⬅️ Tambahkan
import 'package:path/path.dart' as p; // ⬅️ Tambahkan

import '../controllers/reading_controller.dart';
import 'widgets/book_image_widget.dart'; // ⬅️ Tambahkan

class AddView extends StatelessWidget {
  AddView({super.key});

  final controller = Get.find<ReadingController>();
  final textController = TextEditingController();
  
  // Hapus imageUrlController
  // final imageUrlController = TextEditingController(); 
  
  final pickedTags = <String>[].obs;
  
  // Variabel untuk menyimpan path gambar yang dipilih
  final pickedImagePath = Rx<String?>(null); // ⬅️ Tambahkan

  // Fungsi untuk memilih gambar
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Salin file ke direktori aplikasi yang aman
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = p.basename(image.path);
      final savedImage = await File(image.path).copy('${appDir.path}/$fileName');
      
      pickedImagePath.value = savedImage.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tambahkan Bacaan'),
      ),
      body: SingleChildScrollView( // ⬅️ Bungkus dengan SingleChildScrollView
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- BAGIAN INPUT GAMBAR ---
            Obx(() => BookImageWidget(
                  imageUrl: pickedImagePath.value,
                  height: 200,
                  width: 150,
                )),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Pilih Gambar Sampul'),
              onPressed: _pickImage, // ⬅️ Panggil fungsi pilih gambar
            ),
            // --- AKHIR BAGIAN GAMBAR ---

            const SizedBox(height: 16),
            TextField(
              controller: textController,
              decoration: InputDecoration(labelText: 'Judul Bacaan'),
            ),
            
            // Hapus TextField untuk Image URL
            // const SizedBox(height: 16),
            // TextField( ... ),

            const SizedBox(height: 12),
            Obx(() {
              final tags = controller.tags;
              if (tags.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No tags available. Create tags from the menu (top-right).',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              }
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
                  controller.addItem(
                    textController.text,
                    tags: pickedTags.toList(),
                    // Kirim path gambar, bukan URL
                    imageUrl: pickedImagePath.value, 
                  );
                  Get.back();
                }
              },
              child: Text('Simpan'),
            )
          ],
        ),
      ),
    );
  }
}