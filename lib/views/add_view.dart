import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../controllers/reading_controller.dart';
import 'widgets/book_image_widget.dart';

class AddView extends StatelessWidget {
  AddView({super.key});

  final controller = Get.find<ReadingController>();
  final titleController = TextEditingController();
  final authorController = TextEditingController(); // ⬅️ Tambahan
  final notesController = TextEditingController(); // ⬅️ Tambahan
  
  final pickedTags = <String>[].obs;
  final pickedImagePath = Rx<String?>(null);
  final isLoading = false.obs; // ⬅️ Loading state

  // Fungsi untuk memilih gambar dengan pilihan kamera/galeri
  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    
    // Tampilkan dialog pilihan
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sumber Gambar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      isLoading.value = true;
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(image.path)}';
        final savedImage = await File(image.path).copy('${appDir.path}/$fileName');
        
        pickedImagePath.value = savedImage.path;
      }
      isLoading.value = false;
    }
  }

  // Fungsi untuk menghapus gambar
  void _removeImage() {
    pickedImagePath.value = null;
  }

  // Validasi form
  bool _validateForm() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Judul bacaan tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambahkan Bacaan'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header dengan gradien
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.only(top: 20, bottom: 30),
              child: Column(
                children: [
                  // Gambar Sampul
                  Stack(
                    children: [
                      Obx(() => AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: isLoading.value
                                ? Container(
                                    key: const ValueKey('loading'),
                                    height: 220,
                                    width: 160,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : Hero(
                                    tag: 'add_book_image',
                                    child: Container(
                                      height: 220,
                                      width: 160,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: BookImageWidget(
                                        imageUrl: pickedImagePath.value,
                                        height: 220,
                                        width: 160,
                                      ),
                                    ),
                                  ),
                          )),
                      // Tombol hapus gambar
                      Obx(() => pickedImagePath.value != null
                          ? Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                  onPressed: _removeImage,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tombol pilih gambar
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_photo_alternate),
                    label: Text(pickedImagePath.value == null 
                        ? 'Pilih Gambar Sampul' 
                        : 'Ganti Gambar'),
                    onPressed: () => _pickImage(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form Input
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    'Informasi Bacaan',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Judul Bacaan *',
                      hintText: 'Masukkan judul bacaan',
                      prefixIcon: const Icon(Icons.book),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Penulis
                  TextField(
                    controller: authorController,
                    decoration: InputDecoration(
                      labelText: 'Penulis (Opsional)',
                      hintText: 'Masukkan nama penulis',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Catatan
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: 'Catatan (Opsional)',
                      hintText: 'Tambahkan catatan atau deskripsi',
                      prefixIcon: const Icon(Icons.note),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Tags Section
                  Text(
                    'Kategori',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Obx(() {
                    final tags = controller.tags;
                    if (tags.isEmpty) {
                      return Card(
                        elevation: 0,
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Belum ada kategori. Buat kategori dari menu (kanan atas).',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    return Card(
                      elevation: 0,
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
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
                                    selectedColor: theme.colorScheme.primaryContainer,
                                    checkmarkColor: theme.colorScheme.onPrimaryContainer,
                                    labelStyle: TextStyle(
                                      color: pickedTags.contains(t)
                                          ? theme.colorScheme.onPrimaryContainer
                                          : theme.colorScheme.onSurfaceVariant,
                                      fontWeight: pickedTags.contains(t)
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  )))
                              .toList(),
                        ),
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 32),
                  
                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_validateForm()) {
                          controller.addItem(
                            titleController.text.trim(),
                            tags: pickedTags.toList(),
                            imageUrl: pickedImagePath.value,
                            // Jika controller Anda mendukung, tambahkan parameter ini
                            // author: authorController.text.trim(),
                            // notes: notesController.text.trim(),
                          );
                          Get.back();
                          Get.snackbar(
                            'Berhasil',
                            'Bacaan berhasil ditambahkan',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text(
                        'Simpan Bacaan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}