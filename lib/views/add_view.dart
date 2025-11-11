import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../controllers/reading_controller.dart';
import 'widgets/book_image_widget.dart';

// Asumsi: Anda sudah memiliki BookImageWidget di path 'widgets/book_image_widget.dart'
// Asumsi: Anda sudah memiliki ReadingController di path '../controllers/reading_controller.dart'

class AddView extends StatelessWidget {
  AddView({super.key});

  // Deklarasi Controller dan State
  final controller = Get.find<ReadingController>();
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final notesController = TextEditingController();
  
  final pickedTags = <String>[].obs;
  final pickedImagePath = Rx<String?>(null);
  final isLoading = false.obs;
  final currentStep = 0.obs; // ⬅️ Multi-step form

  // --- Fungsi Utama ---

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
          // On web we can't copy into a local file system. Convert to Data URI
          final bytes = await image.readAsBytes();
          final b64 = base64Encode(bytes);
          // Try to infer mime type from extension, fallback to png
          final ext = p.extension(image.name).toLowerCase();
          String mime = 'image/png';
          if (ext == '.jpg' || ext == '.jpeg') mime = 'image/jpeg';
          if (ext == '.gif') mime = 'image/gif';
          pickedImagePath.value = 'data:$mime;base64,$b64';
        } else {
          // Simpan ke direktori aplikasi pada platform mobile
          final appDir = await getApplicationDocumentsDirectory();
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(image.path)}';
          final savedImage = await File(image.path).copy('${appDir.path}/$fileName');
          pickedImagePath.value = savedImage.path;
        }
      }
      isLoading.value = false;
    }
  }

  void _removeImage() {
    pickedImagePath.value = null;
  }

  bool _validateStep() {
    if (currentStep.value == 0) {
      // Step 1: Validasi judul
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

  void _saveBook() {
    if (_validateStep()) {
      // Menambahkan author dan notes ke dalam model (asumsi controller mendukung ini)
      controller.addItem(
        titleController.text.trim(),
        author: authorController.text.trim(), // Tambahan
        notes: notesController.text.trim(), // Tambahan
        tags: pickedTags.toList(),
        imageUrl: pickedImagePath.value,
      );
      Get.back();
      Get.snackbar(
        'Berhasil! 🎉',
        'Bacaan "${titleController.text.trim()}" berhasil ditambahkan',
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

  // --- Build Method Utama ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    // Ambil initial data dari arguments jika ada
    final initialData = Get.arguments as Map<String, dynamic>?;
    if (initialData != null) {
      titleController.text = initialData['title'] ?? '';
      authorController.text = initialData['author'] ?? '';
      notesController.text = initialData['description'] ?? '';
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Tambah Bacaan Baru'),
        elevation: 0,
        backgroundColor: Colors.transparent,
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
            child: Align(
              alignment: Alignment.topCenter,
              child: Obx(() => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      // Menggunakan key untuk membedakan widget
                      final isStep1 = child.key == const ValueKey('step1');
                      // Atur arah slide berdasarkan transisi maju/mundur
                      final beginOffset = currentStep.value == 1 && isStep1 ? const Offset(-0.1, 0) : const Offset(0.1, 0);

                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: beginOffset,
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: currentStep.value == 0
                        ? _buildStep1(context, theme, size)
                        : _buildStep2(context, theme),
                  )),
            ),
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
                          onPressed: currentStep.value == 0 ? _nextStep : _saveBook,
                          icon: Icon(currentStep.value == 0 
                              ? Icons.arrow_forward 
                              : Icons.check_rounded),
                          label: Text(
                            currentStep.value == 0 ? 'Lanjutkan' : 'Simpan Bacaan',
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
    );
  }

  // --- Konten Step 1 ---

  Widget _buildStep1(BuildContext context, ThemeData theme, Size size) {
    return SingleChildScrollView(
      key: const ValueKey('step1'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Bacaan',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan informasi dasar tentang bacaan Anda',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // Image Section with Beautiful Card
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
                                      child: BookImageWidget(
                                        imageUrl: pickedImagePath.value,
                                        height: 240,
                                        width: 170,
                                      ),
                                    ),
                                  ),
                          ),
                          if (pickedImagePath.value != null)
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
                    icon: Icon(pickedImagePath.value == null
                        ? Icons.add_photo_alternate_outlined
                        : Icons.edit_outlined),
                    label: Text(pickedImagePath.value == null
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

          // Title Field
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

          // Author Field
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

          // Notes Field
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

  // --- Konten Step 2 (MODIFIKASI IKON DI SINI) ---

  Widget _buildStep2(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      key: const ValueKey('step2'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
            final tags = controller.tags; // Asumsi controller.tags adalah RxList<String> atau List<String>
            if (tags.isEmpty) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 40),
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withAlpha((0.4 * 255).round()),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.colorScheme.outline.withAlpha((0.2 * 255).round()),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withAlpha((0.3 * 255).round()),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.label_outline_rounded,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Belum Ada Kategori',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Buat kategori terlebih dahulu\ndari menu utama',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          height: 1.5,
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
                Obx(() => AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: pickedTags.isNotEmpty
                          ? Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerHighest.withAlpha((0.5 * 255).round()),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: theme.colorScheme.primary.withAlpha((0.3 * 255).round()),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withAlpha((0.1 * 255).round()),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.label_rounded,
                                          color: theme.colorScheme.primary,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${pickedTags.length} Kategori Terpilih',
                                              style: theme.textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                letterSpacing: -0.2,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              pickedTags.join(' • '),
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.onSurfaceVariant,
                                                fontSize: 13,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            )
                          : const SizedBox.shrink(),
                    )),
                Obx(() => Text(
                      pickedTags.isEmpty ? 'Pilih Kategori' : 'Kategori Tersedia',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    )),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((tag) {
                    return Obx(() {
                      final isSelected = pickedTags.contains(tag);
                      return TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.elasticOut,
                        tween: Tween<double>(
                          begin: 0.0,
                          end: isSelected ? 1.0 : 0.0,
                        ),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 1.0 + (value * 0.1),
                            child: GestureDetector(
                              onTap: () {
                                if (isSelected) {
                                  pickedTags.remove(tag);
                                } else {
                                  pickedTags.add(tag);
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white.withAlpha((0.4 * 255).round())
                                  : theme.colorScheme.outline.withAlpha((0.3 * 255).round()),
                              width: 2.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withAlpha((0.2 * 255).round()),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              Text(
                                tag,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                                ),
                              ),
                            );
                          },
                        );
                      });
                    }).toList(),
                  ),
              ],
            );
          }),
        ],
        ),
      ),
    );
  }
}

// --- Helper Widgets ---

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