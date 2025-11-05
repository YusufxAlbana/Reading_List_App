import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../controllers/reading_controller.dart';
import '../models/reading_item.dart';
// Note: BookImageWidget not used directly in this file

class EditView extends StatelessWidget {
  EditView({super.key});

  final controller = Get.find<ReadingController>();
  final ReadingItem item = Get.arguments;

  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final notesController = TextEditingController();
  
  final pickedTags = <String>[].obs;
  final imagePath = Rx<String?>(null);
  final isLoading = false.obs;
  final hasChanges = false.obs;
  final isRead = false.obs;
  final currentStep = 0.obs;

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Pilih Sumber Gambar',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _ImageSourceCard(
                    icon: Icons.photo_library_rounded,
                    label: 'Galeri',
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ImageSourceCard(
                    icon: Icons.camera_alt_rounded,
                    label: 'Kamera',
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
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
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          final b64 = base64Encode(bytes);
          final ext = p.extension(image.name).toLowerCase();
          String mime = 'image/png';
          if (ext == '.jpg' || ext == '.jpeg') mime = 'image/jpeg';
          if (ext == '.gif') mime = 'image/gif';
          imagePath.value = 'data:$mime;base64,$b64';
        } else {
          final appDir = await getApplicationDocumentsDirectory();
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(image.path)}';
          final savedImage = await File(image.path).copy('${appDir.path}/$fileName');
          imagePath.value = savedImage.path;
        }

        hasChanges.value = true;
      }
      isLoading.value = false;
    }
  }

  void _removeImage() {
    imagePath.value = null;
    hasChanges.value = true;
  }

  void _resetForm() {
    titleController.text = item.title;
    pickedTags.value = List.from(item.tags);
    imagePath.value = item.imageUrl;
    hasChanges.value = false;
  }

  bool _validateStep() {
    if (currentStep.value == 0) {
      if (titleController.text.trim().isEmpty) {
        Get.snackbar(
          'Oops!',
          'Judul bacaan tidak boleh kosong',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[700],
          colorText: Colors.white,
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        return false;
      }
    }
    return true;
  }

  void _nextStep() {
    if (_validateStep()) {
      if (currentStep.value < 1) {
        currentStep.value++;
      }
    }
  }

  void _previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  Future<bool> _onWillPop() async {
    if (!hasChanges.value) return true;

    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
            const SizedBox(width: 12),
            const Text('Buang Perubahan?'),
          ],
        ),
        content: const Text(
          'Anda memiliki perubahan yang belum disimpan. Yakin ingin keluar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red[600],
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _deleteBook() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: Colors.red[600]),
            const SizedBox(width: 12),
            const Text('Hapus Bacaan?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda yakin ingin menghapus:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.book_rounded, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tindakan ini tidak dapat dibatalkan.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red[600],
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      controller.deleteItem(item.id);
      Get.back();
      Get.snackbar(
        'Dihapus! 🗑️',
        '"${item.title}" berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
        icon: const Icon(Icons.delete_rounded, color: Colors.white),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  void _saveChanges() {
    if (_validateStep()) {
      controller.updateItem(
        item.id,
        titleController.text.trim(),
        tags: pickedTags.toList(),
        imageUrl: imagePath.value,
      );
      Get.back();
      Get.snackbar(
        'Tersimpan! ✨',
        '"${titleController.text.trim()}" berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[600],
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Initialize data
    titleController.text = item.title;
    pickedTags.value = List.from(item.tags);
    imagePath.value = item.imageUrl;
  isRead.value = item.isRead;

    // Track changes
    titleController.addListener(() => hasChanges.value = true);
    authorController.addListener(() => hasChanges.value = true);
    notesController.addListener(() => hasChanges.value = true);

    // Temporarily keep WillPopScope (deprecated) to preserve predictive back behavior.
    // Suppress the deprecation analyzer until a careful PopScope migration is performed.
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: const Text('Edit Bacaan'),
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            Obx(() => IconButton(
                  tooltip: isRead.value ? 'Tandai Belum Selesai' : 'Tandai Selesai dibaca',
                  icon: Icon(
                    isRead.value ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                    color: isRead.value ? Colors.greenAccent : null,
                  ),
                  onPressed: () {
                    final prev = isRead.value;
                    controller.setStatus(item.id, !prev);
                    isRead.value = !prev;
                    Get.snackbar(
                      isRead.value ? 'Selesai' : 'Dibatalkan',
                      isRead.value
                          ? '"${item.title}" ditandai sebagai selesai dibaca'
                          : 'Status selesai dibaca dibatalkan',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: isRead.value ? Colors.green[600] : Colors.orange[700],
                      colorText: Colors.white,
                      duration: const Duration(seconds: 4),
                      mainButton: TextButton(
                        onPressed: () {
                          controller.setStatus(item.id, prev);
                          isRead.value = prev;
                          Get.back();
                        },
                        child: const Text('UNDO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                )),
            Obx(() => hasChanges.value
                ? IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Reset perubahan',
                    onPressed: _resetForm,
                  )
                : const SizedBox()),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert_rounded),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, 
                          color: Colors.red[600], size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Hapus Bacaan',
                        style: TextStyle(color: Colors.red[600]),
                      ),
                    ],
                  ),
                  onTap: () {
                    Future.delayed(const Duration(milliseconds: 100), () => _deleteBook());
                  },
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress Indicator
            Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      _StepIndicator(
                        isActive: currentStep.value >= 0,
                        isCompleted: currentStep.value > 0,
                        label: '1',
                      ),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: currentStep.value > 0
                              ? theme.colorScheme.primary
                              : Colors.grey[300],
                        ),
                      ),
                      _StepIndicator(
                        isActive: currentStep.value >= 1,
                        isCompleted: false,
                        label: '2',
                      ),
                    ],
                  ),
                )),

            // Step Content
            Expanded(
              child: Obx(() => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: currentStep.value == 0
                        ? _buildStep1(context, theme)
                        : _buildStep2(context, theme),
                  )),
            ),

            // Bottom Navigation
            Obx(() => Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.05 * 255).round()),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        if (currentStep.value > 0)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _previousStep,
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Kembali'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        if (currentStep.value > 0) const SizedBox(width: 12),
                        Expanded(
                          flex: currentStep.value == 0 ? 1 : 2,
                          child: ElevatedButton.icon(
                            onPressed: currentStep.value == 0 ? _nextStep : _saveChanges,
                            icon: Icon(currentStep.value == 0 
                                ? Icons.arrow_forward 
                                : Icons.check_rounded),
                            label: Text(
                              currentStep.value == 0 ? 'Lanjutkan' : 'Simpan Perubahan',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      key: const ValueKey('step1'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with metadata
          Container(
            padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.tertiaryContainer.withAlpha((0.3 * 255).round()),
                    theme.colorScheme.secondaryContainer.withAlpha((0.3 * 255).round()),
                  ],
                ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, 
                    color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mengedit Bacaan',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Dibuat: ${_formatDate(item.createdAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Detail Bacaan',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Perbarui informasi bacaan Anda',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Image Section
          Center(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primaryContainer.withAlpha((0.3 * 255).round()),
                    theme.colorScheme.secondaryContainer.withAlpha((0.3 * 255).round()),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha((0.1 * 255).round()),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Obx(() => Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: isLoading.value
                                ? Container(
                                    key: const ValueKey('loading'),
                                    height: 240,
                                    width: 170,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : Container(
                                    key: ValueKey(imagePath.value ?? 'empty'),
                                    height: 240,
                                    width: 170,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha((0.3 * 255).round()),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: imagePath.value != null
                                          ? (imagePath.value!.startsWith('http')
                                              ? Image.network(
                                                  imagePath.value!,
                                                  height: 240,
                                                  width: 170,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      color: Colors.grey[300],
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(
                                                            Icons.broken_image_rounded,
                                                            size: 64,
                                                            color: Colors.grey[400],
                                                          ),
                                                          const SizedBox(height: 12),
                                                          Text(
                                                            'Gagal memuat',
                                                            style: TextStyle(
                                                              color: Colors.grey[600],
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                )
                                              : (imagePath.value!.startsWith('data:')
                                                  ? Image.memory(
                                                      base64Decode(imagePath.value!.split(',').last),
                                                      height: 240,
                                                      width: 170,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Container(
                                                          color: Colors.grey[300],
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Icon(
                                                                Icons.broken_image_rounded,
                                                                size: 64,
                                                                color: Colors.grey[400],
                                                              ),
                                                              const SizedBox(height: 12),
                                                              Text(
                                                                'Gagal memuat',
                                                                style: TextStyle(
                                                                  color: Colors.grey[600],
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  : (kIsWeb
                                                      ? Container(
                                                          color: Colors.grey[300],
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Icon(
                                                                Icons.broken_image_rounded,
                                                                size: 64,
                                                                color: Colors.grey[400],
                                                              ),
                                                              const SizedBox(height: 12),
                                                              Text(
                                                                'Gambar lokal tidak didukung di Web',
                                                                style: TextStyle(
                                                                  color: Colors.grey[600],
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Image.file(
                                                          File(imagePath.value!),
                                                          height: 240,
                                                          width: 170,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context, error, stackTrace) {
                                                            return Container(
                                                              color: Colors.grey[300],
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Icon(
                                                                    Icons.broken_image_rounded,
                                                                    size: 64,
                                                                    color: Colors.grey[400],
                                                                  ),
                                                                  const SizedBox(height: 12),
                                                                  Text(
                                                                    'File tidak ditemukan',
                                                                    style: TextStyle(
                                                                      color: Colors.grey[600],
                                                                      fontSize: 12,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ))))
                                          : Container(
                                              color: Colors.grey[300],
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.auto_stories_rounded,
                                                    size: 64,
                                                    color: Colors.grey[400],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    'Belum ada cover',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ),
                                  ),
                          ),
                          if (imagePath.value != null)
                            Positioned(
                              top: -8,
                              right: -8,
                              child: Material(
                                color: Colors.red[600],
                                shape: const CircleBorder(),
                                elevation: 4,
                                child: InkWell(
                                  onTap: _removeImage,
                                  customBorder: const CircleBorder(),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )),
                  const SizedBox(height: 20),
                  FilledButton.tonalIcon(
                    onPressed: () => _pickImage(context),
                    icon: Icon(imagePath.value == null
                        ? Icons.add_photo_alternate_outlined
                        : Icons.edit_outlined),
                    label: Text(imagePath.value == null
                        ? 'Pilih Cover'
                        : 'Ganti Cover'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Form fields
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha((0.3 * 255).round()),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Judul Bacaan',
                hintText: 'Masukkan judul bacaan...',
                prefixIcon: Icon(
                  Icons.auto_stories_rounded,
                  color: theme.colorScheme.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.all(20),
              ),
              style: theme.textTheme.titleMedium,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha((0.3 * 255).round()),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: authorController,
              decoration: InputDecoration(
                labelText: 'Penulis (Opsional)',
                hintText: 'Siapa penulisnya?',
                prefixIcon: Icon(
                  Icons.person_rounded,
                  color: theme.colorScheme.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.all(20),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha((0.3 * 255).round()),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Catatan (Opsional)',
                hintText: 'Tambahkan catatan pribadi...',
                prefixIcon: Icon(
                  Icons.edit_note_rounded,
                  color: theme.colorScheme.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.all(20),
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      key: const ValueKey('step2'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategorikan Bacaan',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih kategori yang sesuai untuk bacaan Anda',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          Obx(() {
            final tags = controller.tags;
            if (tags.isEmpty) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withAlpha((0.3 * 255).round()),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant.withAlpha((0.5 * 255).round()),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum Ada Kategori',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Buat kategori terlebih dahulu dari menu utama',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primaryContainer,
                            theme.colorScheme.secondaryContainer,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.checklist_rounded,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${pickedTags.length} Kategori Dipilih',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                if (pickedTags.isNotEmpty)
                                  Text(
                                    pickedTags.join(', '),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onPrimaryContainer
                                          .withAlpha((0.8 * 255).round()),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: tags.map((tag) {
                    return Obx(() {
                      final isSelected = pickedTags.contains(tag);
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: FilterChip(
                          label: Text(tag),
                          selected: isSelected,
                          onSelected: (_) {
                            if (isSelected) {
                              pickedTags.remove(tag);
                            } else {
                              pickedTags.add(tag);
                            }
                            hasChanges.value = true;
                          },
                          selectedColor: theme.colorScheme.primaryContainer,
                          checkmarkColor: theme.colorScheme.primary,
                          backgroundColor: theme.colorScheme.surface,
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline.withAlpha((0.3 * 255).round()),
                            width: isSelected ? 2 : 1,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurface,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 15,
                          ),
                          elevation: isSelected ? 2 : 0,
                          pressElevation: 4,
                        ),
                      );
                    });
                  }).toList(),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// Helper Widgets
class _StepIndicator extends StatelessWidget {
  final bool isActive;
  final bool isCompleted;
  final String label;

  const _StepIndicator({
    required this.isActive,
    required this.isCompleted,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isCompleted || isActive
            ? theme.colorScheme.primary
            : Colors.grey[300],
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withAlpha((0.4 * 255).round()),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
            : Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}

class _ImageSourceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withAlpha((0.3 * 255).round()),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withAlpha((0.2 * 255).round()),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha((0.1 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}