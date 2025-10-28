import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reading_controller.dart';
import '../models/reading_item.dart';

class EditView extends StatelessWidget {
  EditView({super.key}) {
    item = Get.arguments;
  }

  final controller = Get.find<ReadingController>();
  late final ReadingItem item;
  final textController = TextEditingController();
  final pickedTags = <String>[].obs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    textController.text = item.title;
    // initialize picked tags
    if (pickedTags.isEmpty) {
      pickedTags.assignAll(
          item.tags.where((t) => controller.tags.contains(t)).toList());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Bacaan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: textController,
              decoration: InputDecoration(labelText: 'Judul Bacaan'),
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
              // Ini memperbaiki bug "2 kotak"
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
                controller.updateItem(item.id, textController.text,
                    tags: pickedTags.toList());
                Get.back();
              },
              child: Text('Update'),
            )
          ],
        ),
      ),
    );
  }
}