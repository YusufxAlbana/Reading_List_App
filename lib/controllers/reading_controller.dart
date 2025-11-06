// lib/controllers/reading_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/reading_item.dart';

class ReadingController extends GetxController {
  final storage = GetStorage();
  final list = <ReadingItem>[].obs;
  final tags = <String>[].obs;

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
    
    // Backup ke local storage saat ada perubahan
    ever(list,
        (_) => storage.write('reading_list', list.map((e) => e.toJson()).toList()));
    ever(tags, (_) => storage.write('reading_tags', tags.toList()));
  }
  

  List<ReadingItem> get filteredList {
    var filtered = list.where(
        (e) => e.title.toLowerCase().contains(searchQuery.value.toLowerCase()));

    if (filterStatus.value == 'read') {
      filtered = filtered.where((e) => e.isRead);
    } else if (filterStatus.value == 'unread') {
      filtered = filtered.where((e) => !e.isRead);
    }

    var result = filtered.toList();
    // Sort
    if (sortOrder.value == 'newest') {
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (sortOrder.value == 'oldest') {
      result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else if (sortOrder.value == 'a-z') {
      result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    } else if (sortOrder.value == 'z-a') {
      result.sort((a, b) => b.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }

    // Filter by selected tags
    if (selectedTags.isNotEmpty) {
      result = result
          .where((e) => e.tags.any((t) => selectedTags.contains(t)))
          .toList();
    }

    return result;
  }

  // ✅ MEMPERBAIKI UNDEFINED NAMED PARAMETER DI addItem
  void addItem(
    String title, {
    String? author, // ⬅️ DITAMBAHKAN
    String? notes, // ⬅️ DITAMBAHKAN
    List<String>? tags, 
    String? imageUrl
  }) {
    final validTags = (tags ?? []).where((t) => this.tags.contains(t)).toList();
    final item = ReadingItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        author: author, // ⬅️ Digunakan
        notes: notes,  // ⬅️ Digunakan
        createdAt: DateTime.now(),
        tags: validTags,
        imageUrl: imageUrl); 
    
    list.add(item);
  }

  void toggleStatus(String id) {
    int index = list.indexWhere((e) => e.id == id);
    if (index != -1) {
      list[index].isRead = !list[index].isRead;
      
      list.refresh();
    }
  }

  /// Set read status explicitly. Useful for undo operations.
  void setStatus(String id, bool read) {
    int index = list.indexWhere((e) => e.id == id);
    if (index != -1) {
      list[index].isRead = read;
      list.refresh();
    }
  }

  void deleteItem(String id) {
    list.removeWhere((e) => e.id == id);
  }

  // ✅ MEMPERBAIKI UNDEFINED NAMED PARAMETER DI updateItem
  void updateItem(
    String id, 
    String title, {
    String? author, // ⬅️ DITAMBAHKAN
    String? notes, // ⬅️ DITAMBAHKAN
    List<String>? tags, 
    String? imageUrl
  }) {
    int index = list.indexWhere((e) => e.id == id);
    if (index != -1) {
      list[index].title = title;
      
      // ✅ MEMPERBAIKI UNDEFINED SETTER: 
      // Mengubah nilai properti 'author' dan 'notes'. 
      // Ini membutuhkan properti tersebut di 'ReadingItem' agar TIDAK 'final'.
      list[index].author = author; // ⬅️ Setter dipanggil
      list[index].notes = notes;   // ⬅️ Setter dipanggil

      if (tags != null) {
        list[index].tags = tags.where((t) => this.tags.contains(t)).toList();
      }
      if (imageUrl != null) {
        list[index].imageUrl = imageUrl;
      }
      
      list.refresh();
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
    }
  }

  void removeTag(String tag) {
    tags.remove(tag);
    for (var item in list) {
      if (item.tags.contains(tag)) {
        item.tags.remove(tag);
      }
    }
    list.refresh();
  }

  void removeTags(List<String> removed) {
    for (var tag in removed) {
      if (tags.contains(tag)) tags.remove(tag);
    }
    for (var item in list) {
      item.tags.removeWhere((t) => removed.contains(t));
    }
    list.refresh();
  }

  Color get selectedColor => Colors.white; 
}