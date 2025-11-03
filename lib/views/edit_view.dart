import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../controllers/reading_controller.dart';
import '../models/reading_item.dart';
import 'widgets/book_image_widget.dart';

class EditView extends StatelessWidget {
  EditView({super.key});

  final controller = Get.find<ReadingController>();
  final ReadingItem item = Get.arguments;

  final titleController = TextEditingController();
  final authorController = TextEditingController(); // ⬅️ Tambahan
  final notesController = TextEditingController(); // ⬅️ Tambahan
  
  final pickedTags = <String>[].obs;
  final imagePath = Rx<String?>(null);
  final isLoading = false.obs;
  final hasChanges = false.obs; // ⬅️ Track perubahan

  // Fungsi untuk memilih gambar dengan pilihan kamera/galeri
  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    
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
        
        imagePath.value = savedImage.path;
        hasChanges.value = true;
      }
      isLoading.value = false;
    }
  }

  // Fungsi untuk menghapus gambar
  void _removeImage() {
    imagePath.value = null;
    hasChanges.value = true;
  }

  // Fungsi untuk reset ke data awal
  void _resetForm() {
    titleController.text = item.title;
    pickedTags.value = List.from(item.tags);
    imagePath.value = item.imageUrl;
    // authorController.text = item.author ?? '';
    // notesController.text = item.notes ?? '';
    hasChanges.value = false;
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

  // Konfirmasi sebelum keluar jika ada perubahan
  Future<bool> _onWillPop() async {
    if (!hasChanges.value) return true;

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Buang Perubahan?'),
        content: const Text('Anda memiliki perubahan yang belum disimpan. Yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Initialize data
    titleController.text = item.title;
    pickedTags.value = List.from(item.tags);
    imagePath.value = item.imageUrl;
    // authorController.text = item.author ?? '';
    // notesController.text = item.notes ?? '';

    // Track changes
    titleController.addListener(() => hasChanges.value = true);
    authorController.addListener(() => hasChanges.value = true);
    notesController.addListener(() => hasChanges.value = true);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Bacaan'),
          elevation: 0,
          actions: [
            // Tombol reset
            Obx(() => hasChanges.value
                ? IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Reset ke data awal',
                    onPressed: _resetForm,
                  )
                : const SizedBox()),
            // Tombol delete
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Hapus bacaan',
              onPressed: () async {
                final confirm = await Get.dialog<bool>(
                  AlertDialog(
                    title: const Text('Hapus Bacaan?'),
                    content: Text('Apakah Anda yakin ingin menghapus "${item.title}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  controller.deleteItem(item.id);
                  Get.back();
                  Get.snackbar(
                    'Berhasil',
                    'Bacaan berhasil dihapus',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.orange,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                }
              },
            ),
          ],
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
                    // Info terakhir diubah
                    if (item.createdAt != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Dibuat: ${_formatDate(item.createdAt!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    
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
                                      tag: 'edit_book_${item.id}',
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
                                          imageUrl: imagePath.value,
                                          height: 220,
                                          width: 160,
                                        ),
                                      ),
                                    ),
                            )),
                        // Tombol hapus gambar
                        Obx(() => imagePath.value != null
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
                    // Tombol ganti gambar
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(imagePath.value == null 
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
                    // Judul Section
                    Text(
                      'Informasi Bacaan',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Judul
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kategori',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Obx(() => pickedTags.isNotEmpty
                            ? Text(
                                '${pickedTags.length} dipilih',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : const SizedBox()),
                      ],
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
                                .map((t) => Obx(() {
                                      final isSelected = pickedTags.contains(t);
                                      return FilterChip(
                                        label: Text(t),
                                        selected: isSelected,
                                        onSelected: (_) {
                                          if (isSelected) {
                                            pickedTags.remove(t);
                                          } else {
                                            pickedTags.add(t);
                                          }
                                          hasChanges.value = true;
                                        },
                                        selectedColor: theme.colorScheme.primaryContainer,
                                        checkmarkColor: theme.colorScheme.onPrimaryContainer,
                                        labelStyle: TextStyle(
                                          color: isSelected
                                              ? theme.colorScheme.onPrimaryContainer
                                              : theme.colorScheme.onSurfaceVariant,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      );
                                    }))
                                .toList(),
                          ),
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 32),
                    
                    // Tombol Update
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_validateForm()) {
                            controller.updateItem(
                              item.id,
                              titleController.text.trim(),
                              tags: pickedTags.toList(),
                              imageUrl: imagePath.value,
                              // Jika controller Anda mendukung, tambahkan parameter ini
                              // author: authorController.text.trim(),
                              // notes: notesController.text.trim(),
                            );
                            Get.back();
                            Get.snackbar(
                              'Berhasil',
                              'Bacaan berhasil diperbarui',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                            );
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: const Text(
                          'Simpan Perubahan',
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
      ),
    );
  }

  // Helper untuk format tanggal
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}