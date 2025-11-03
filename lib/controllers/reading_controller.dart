// lib/controllers/reading_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/reading_item.dart';
// Hapus import 'dart:async' dan 'firebase_service'

class ReadingController extends GetxController {
  final storage = GetStorage();
  final list = <ReadingItem>[].obs;
  final tags = <String>[].obs;

  // Hapus semua referensi StreamSubscription dan FirebaseService

  // Search + Filter
  final searchQuery = ''.obs;
  final filterStatus = 'all'.obs; // all, read, unread
  final sortOrder = 'newest'.obs; // newest or oldest
  final selectedTags = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    
    // Load dari local storage
    List? stored = storage.read('reading_list');
    if (stored != null) {
      list.assignAll(stored.map((e) => ReadingItem.fromJson(e)));
    }
    List? storedTags = storage.read('reading_tags');
    if (storedTags != null) {
      try {
        tags.assignAll(List<String>.from(storedTags));
      } catch (_) {
        tags.assignAll(storedTags.map((e) => e.toString()).toList());
      }
    }
    
    // Hapus _setupFirebaseSync()
    
    // Backup ke local storage saat ada perubahan
    ever(list,
        (_) => storage.write('reading_list', list.map((e) => e.toJson()).toList()));
    ever(tags, (_) => storage.write('reading_tags', tags.toList()));
  }
  
  // Hapus _setupFirebaseSync()
  // Hapus onClose()

  List<ReadingItem> get filteredList {
    var filtered = list.where(
        (e) => e.title.toLowerCase().contains(searchQuery.value.toLowerCase()));

    if (filterStatus.value == 'read') {
      filtered = filtered.where((e) => e.isRead);
    } else if (filterStatus.value == 'unread') {
      filtered = filtered.where((e) => !e.isRead);
    }

    var result = filtered.toList();
    // sort by createdAt or title based on sortOrder
    if (sortOrder.value == 'newest') {
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (sortOrder.value == 'oldest') {
      result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else if (sortOrder.value == 'a-z') {
      result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    } else if (sortOrder.value == 'z-a') {
      result.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
    }

    // filter by selected tags
    if (selectedTags.isNotEmpty) {
      result = result
          .where((e) => e.tags.any((t) => selectedTags.contains(t)))
          .toList();
    }

    return result;
  }

  // MODIFIKASI: Tambahkan parameter imageUrl
  void addItem(String title, {List<String>? tags, String? imageUrl}) {
    final validTags = (tags ?? []).where((t) => this.tags.contains(t)).toList();
    final item = ReadingItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // ID unik lokal
        title: title,
        createdAt: DateTime.now(),
        tags: validTags,
        imageUrl: imageUrl); // Simpan imageUrl
    
    list.add(item);
    // 'ever' akan otomatis menyimpan ke storage
  }

  void toggleStatus(String id) {
    int index = list.indexWhere((e) => e.id == id);
    if (index != -1) {
      list[index].isRead = !list[index].isRead;
      
      // Refresh local dan simpan
      list.refresh();
      storage.write('reading_list', list.map((e) => e.toJson()).toList());
    }
  }

  /// Set read status explicitly. Useful for undo operations.
  void setStatus(String id, bool read) {
    int index = list.indexWhere((e) => e.id == id);
    if (index != -1) {
      list[index].isRead = read;
      list.refresh();
      storage.write('reading_list', list.map((e) => e.toJson()).toList());
    }
  }

  void deleteItem(String id) {
    list.removeWhere((e) => e.id == id);
    // 'ever' akan otomatis menyimpan ke storage
  }

  // MODIFIKASI: Tambahkan parameter imageUrl
  void updateItem(String id, String title, {List<String>? tags, String? imageUrl}) {
    int index = list.indexWhere((e) => e.id == id);
    if (index != -1) { // Perbaikan: Pastikan index ditemukan
      list[index].title = title;
      if (tags != null) {
        list[index].tags = tags.where((t) => this.tags.contains(t)).toList();
      }
      // Tambahkan update imageUrl
      if (imageUrl != null) {
        list[index].imageUrl = imageUrl;
      }
      
      list.refresh();
      // 'ever' akan otomatis menyimpan ke storage
    }
  }

  List<String> get availableTags {
    return tags.toList();
  }

  void toggleSelectedTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  void addTag(String tag) {
    final t = tag.trim();
    if (t.isEmpty) return;
    if (!tags.contains(t)) {
      tags.add(t);
      // 'ever' akan otomatis menyimpan ke storage
    }
  }

  void removeTag(String tag) {
    tags.remove(tag);
    for (var item in list) {
      if (item.tags.contains(tag)) {
        item.tags.remove(tag);
      }
    }
    list.refresh(); // Refresh list untuk memicu penyimpanan 'ever'
  }

  void removeTags(List<String> removed) {
    for (var tag in removed) {
      if (tags.contains(tag)) tags.remove(tag);
    }
    for (var item in list) {
      item.tags.removeWhere((t) => removed.contains(t));
    }
    list.refresh(); // Refresh list untuk memicu penyimpanan 'ever'
  }

  Color get selectedColor => Colors.white; 
}