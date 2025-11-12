// lib/views/tags_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async'; // Diperlukan untuk StreamSubscription
import '../controllers/reading_controller.dart';
import '../constants/theme_constants.dart';

class TagsView extends StatefulWidget {
  const TagsView({super.key});

  @override
  State<TagsView> createState() => _TagsViewState();
}

class _TagsViewState extends State<TagsView> {
  final controller = Get.find<ReadingController>();
  final TextEditingController _tagController = TextEditingController();

  final _listKey = GlobalKey<AnimatedListState>();
  late List<String> _tags;
  late StreamSubscription<List<String>> _tagsSubscription;

  // --- State Baru untuk Mode Seleksi ---
  bool _isSelectionMode = false;
  final Set<String> _selectedTags = {};
  // -------------------------------------

  @override
  void initState() {
    super.initState();
    _tags = List.from(controller.tags);
    _tagsSubscription = controller.tags.listen(_onTagsChanged);
  }

  @override
  void dispose() {
    _tagsSubscription.cancel();
    _tagController.dispose();
    super.dispose();
  }

  void _onTagsChanged(List<String> newTags) {
    // Deteksi item yang dihapus (dari belakang ke depan)
    for (int i = _tags.length - 1; i >= 0; i--) {
      if (!newTags.contains(_tags[i])) {
        final removedTag = _tags.removeAt(i);
        if (_listKey.currentState != null) {
          _listKey.currentState!.removeItem(
            i,
            (context, animation) =>
                _buildAnimatedItem(context, removedTag, animation, true),
            duration: const Duration(milliseconds: 300),
          );
        }
      }
    }

    // Deteksi item yang ditambahkan
    for (int i = 0; i < newTags.length; i++) {
      if (!_tags.contains(newTags[i])) {
        _tags.insert(i, newTags[i]);
        if (_listKey.currentState != null) {
          _listKey.currentState!.insertItem(
            i,
            duration: const Duration(milliseconds: 400),
          );
        }
      }
    }

    setState(() {}); // Panggil setState untuk update UI (penting untuk empty state)
  }

  // --- LOGIKA BARU UNTUK MODE SELEKSI ---

  /// Masuk atau keluar dari mode seleksi
  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedTags.clear(); // Selalu bersihkan seleksi saat ganti mode
    });
  }

  /// Memilih atau batal memilih satu tag
  void _toggleTagSelection(String tag) {
    // Hanya bisa memilih jika dalam mode seleksi
    if (!_isSelectionMode) return;

    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  /// Tampilkan dialog konfirmasi untuk menghapus tag yang dipilih
  void _confirmDeleteSelected() {
    if (_selectedTags.isEmpty) {
      Get.snackbar(
        'No Tags Selected',
        'Please select one or more tags to delete.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surface,
        colorText: Colors.white70,
      );
      return;
    }

    Get.defaultDialog(
      title: 'Delete Selected Tags?',
      titleStyle: const TextStyle(color: Colors.white),
      middleText:
          'Are you sure you want to delete ${_selectedTags.length} tag(s)? This will remove them from all associated books.',
      middleTextStyle: const TextStyle(color: Colors.white70),
      backgroundColor: AppColors.surface,
      confirm: TextButton(
        onPressed: () {
          final tagsToRemove = _selectedTags.toList();
          Get.back(); // Tutup dialog

          // Keluar dari mode seleksi
          // Controller akan otomatis memicu _onTagsChanged
          setState(() {
            _isSelectionMode = false;
            _selectedTags.clear();
          });

          // Hapus tag dari controller
          controller.removeTags(tagsToRemove);
        },
        style: TextButton.styleFrom(backgroundColor: Colors.red.shade800),
        child: const Text('Delete', style: TextStyle(color: Colors.white)),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
      ),
    );
  }

  // --- (Logic Dialog Add Tag & Submit tidak berubah) ---

  void _showAddTagDialog(BuildContext context) {
    _tagController.clear();
    Get.defaultDialog(
      title: 'Add New Tag',
      titleStyle: const TextStyle(color: Colors.white, fontSize: 18),
      backgroundColor: AppColors.surface,
      content: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tagController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Tag Name',
                labelStyle: const TextStyle(color: AppColors.primary),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _submitTag(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _submitTag,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Add'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _submitTag() {
    if (_tagController.text.isNotEmpty) {
      final newTag = _tagController.text.trim();
      if (!controller.tags.contains(newTag)) {
        controller.addTag(newTag);
        Get.back();
      } else {
        Get.snackbar(
          'Tag Already Exists',
          '"$newTag" is already in your tag list.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        // Tombol leading diubah
        leading: IconButton(
          icon: Icon(
            _isSelectionMode ? Icons.close : Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            if (_isSelectionMode) {
              _toggleSelectionMode(); // Jika mode seleksi, tombol ini jadi "Batal"
            } else {
              Get.back(); // Jika mode normal, tombol ini "Kembali"
            }
          },
        ),
        // Judul diubah
        title: Text(
          _isSelectionMode ? 'Select Tags' : 'Manage Tags',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Tombol aksi diubah
        actions: [
          // Hanya tampilkan tombol jika list tidak kosong, ATAU jika sedang mode seleksi
          if (_tags.isNotEmpty || _isSelectionMode)
            IconButton(
              icon: Icon(
                _isSelectionMode
                    ? Icons.close // Tampilkan 'X' jika sudah di mode seleksi
                    : Icons.delete_outline, // Tampilkan 'Trash' jika mode normal
                color: _isSelectionMode ? Colors.white : Colors.red.shade400,
              ),
              onPressed: _toggleSelectionMode,
              tooltip:
                  _isSelectionMode ? 'Cancel Selection' : 'Select tags to delete',
            ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8)
                .copyWith(bottom: 80), // Padding untuk FAB
            child: AnimatedList(
              key: _listKey,
              initialItemCount: _tags.length,
              itemBuilder: (context, index, animation) {
                if (index >= _tags.length) return const SizedBox.shrink();
                final tag = _tags[index];
                return _buildAnimatedItem(context, tag, animation, false);
              },
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _tags.isEmpty ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: _tags.isNotEmpty,
              child: _buildEmptyState(),
            ),
          ),
        ],
      ),
      // FAB diubah menjadi dinamis
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: _isSelectionMode
            ? _buildDeleteFab(context) // Tampilkan FAB Hapus
            : _buildAddFab(context), // Tampilkan FAB Tambah
      ),
    );
  }

  // FAB untuk mode "Add" (default)
  Widget _buildAddFab(BuildContext context) {
    return FloatingActionButton.extended(
      key: const ValueKey('add_fab'), // Key untuk AnimatedSwitcher
      onPressed: () => _showAddTagDialog(context),
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.add, color: Colors.black),
      label: const Text('Add Tag',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
    );
  }

  // FAB baru untuk mode "Delete"
  Widget _buildDeleteFab(BuildContext context) {
    final count = _selectedTags.length;
    final bool hasSelection = count > 0;

    return FloatingActionButton.extended(
      key: const ValueKey('delete_fab'), // Key untuk AnimatedSwitcher
      onPressed:
          _confirmDeleteSelected, // Panggil konfirmasi hapus
      backgroundColor: hasSelection ? Colors.red.shade800 : Colors.grey.shade700,
      icon: Icon(Icons.delete_forever,
          color: hasSelection ? Colors.white : Colors.grey.shade400),
      label: Text(
        hasSelection ? 'Delete ($count)' : 'Select Tags',
        style: TextStyle(
          color: hasSelection ? Colors.white : Colors.grey.shade400,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAnimatedItem(
    BuildContext context,
    String tag,
    Animation<double> animation,
    bool isRemoving,
  ) {
    // ... (logika animasi tidak berubah)
    if (isRemoving) {
      return SizeTransition(
        sizeFactor: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        ),
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeIn,
          ),
          child: _buildTagItem(context, tag),
        ),
      );
    }
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeIn,
          ),
          child: _buildTagItem(context, tag),
        ),
      ),
    );
  }

  // --- Widget Item Diperbarui ---
  Widget _buildTagItem(BuildContext context, String tag) {
    // Perbaikan bug null-check
    final count = controller.list.where((b) {
      return (b.tags).contains(tag);
    }).length;
    
    // Cek apakah item ini terseleksi
    final isSelected = _selectedTags.contains(tag);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Card(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // Beri border jika terseleksi
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: ListTile(
          // ================== PERUBAHAN DI SINI ==================
          onTap: () {
            if (_isSelectionMode) {
              // Jika mode seleksi, toggle pilihan
              _toggleTagSelection(tag);
            } else {
              // Jika mode normal, navigasi ke halaman buku yang difilter
              
              // 1. Bersihkan filter lain
              controller.searchQuery.value = '';
              controller.filterStatus.value = 'all';
              controller.sortOrder.value = 'newest';

              // 2. Atur filter tag
              controller.selectedTags.clear();
              controller.selectedTags.add(tag);

              // 3. Navigasi ke halaman semua buku
              Get.toNamed('/all-books');
            }
          },
          // ================== AKHIR PERUBAHAN ==================

          // Aksi Long Press:
          // - Selalu masuk ke mode seleksi & langsung pilih item
          onLongPress: () {
            if (!_isSelectionMode) {
              _toggleSelectionMode();
            }
            _toggleTagSelection(tag);
          },
          // Leading Icon diubah
          leading: Icon(
            _isSelectionMode
                ? (isSelected
                    ? Icons.check_circle_rounded // Terseleksi
                    : Icons.circle_outlined) // Mode seleksi, tapi tdk terseleksi
                : Icons.label, // Mode normal
            color: isSelected || !_isSelectionMode
                ? AppColors.primary
                : Colors.white54,
          ),
          title: Text(
            tag,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '$count book${count == 1 ? '' : 's'}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          // Trailing icon dihapus (diganti sistem seleksi)
          trailing: null,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    // ... (logika empty state tidak berubah)
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.label_off_outlined,
              color: Colors.white.withOpacity(0.3), size: 80),
          const SizedBox(height: 24),
          Text(
            'No Tags Yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Click the "Add Tag" button to create your first tag.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}