import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reading_controller.dart';

class AddView extends StatelessWidget {
  AddView({super.key});

  final controller = Get.find<ReadingController>();
  final textController = TextEditingController();
  final imageUrlController = TextEditingController();
  final pickedTags = <String>[].obs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tambahkan Bacaan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: textController,
              decoration: InputDecoration(labelText: 'Judul Bacaan'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: imageUrlController,
              decoration: InputDecoration(
                labelText: 'URL Gambar Cover (opsional)',
                hintText: 'https://example.com/book-cover.jpg',
              ),
            ),
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

              // --- PERUBAHAN: Hapus widget Card dan Padding ---
              return Wrap(
                spacing: 8,
                runSpacing: 4, // Tambahkan run spacing agar rapi
                children: tags
                    .map((t) => Obx(() => FilterChip(
                          label: Text(t),
                          selected: pickedTags.contains(t),
                          // selectedColor tidak perlu di-set, sudah di-handle ChipTheme
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
              // --- AKHIR PERUBAHAN ---
            }),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  controller.addItem(
                    textController.text,
                    tags: pickedTags.toList(),
                    imageUrl: imageUrlController.text.trim().isEmpty 
                      ? null 
                      : imageUrlController.text.trim(),
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