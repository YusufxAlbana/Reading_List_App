import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/reading_item.dart';
import '../services/firebase_service.dart';
import 'dart:async';

class ReadingController extends GetxController {
  final storage = GetStorage();
  final firebaseService = FirebaseService();
  final list = <ReadingItem>[].obs;
  final tags = <String>[].obs;
  
  StreamSubscription<List<ReadingItem>>? _booksSubscription;
  StreamSubscription<List<String>>? _tagsSubscription;

  // Opsi warna dihapus karena sudah fixed ke putih
  // final Map<String, Color> colorOptions = { ... };
  // selectedColorKey dihapus
  // final selectedColorKey = 'Grey'.obs;

  // Search + Filter
  final searchQuery = ''.obs;
  final filterStatus = 'all'.obs; // all, read, unread
  final sortOrder = 'newest'.obs; // newest or oldest
  final selectedTags = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    
    // Load dari local storage dulu (untuk offline support)
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
    
    // Setup Firebase real-time sync
    _setupFirebaseSync();
    
    // Backup ke local storage saat ada perubahan
    ever(list,
        (_) => storage.write('reading_list', list.map((e) => e.toJson()).toList()));
    ever(tags, (_) => storage.write('reading_tags', tags.toList()));
  }
  
  void _setupFirebaseSync() {
    // Subscribe ke books stream
    _booksSubscription = firebaseService.getBooksStream().listen((books) {
      list.assignAll(books);
    });
    
    // Subscribe ke tags stream
    _tagsSubscription = firebaseService.getTagsStream().listen((tagsList) {
      tags.assignAll(tagsList);
    });
  }
  
  @override
  void onClose() {
    _booksSubscription?.cancel();
    _tagsSubscription?.cancel();
    super.onClose();
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

  void addItem(String title, {List<String>? tags, String? imageUrl}) async {
    final validTags = (tags ?? []).where((t) => this.tags.contains(t)).toList();
    final item = ReadingItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        createdAt: DateTime.now(),
        tags: validTags,
        imageUrl: imageUrl);
    
    // Add ke Firebase (akan otomatis update list via stream)
    await firebaseService.addBook(item);
  }

  void toggleStatus(String id) async {
    int index = list.indexWhere((e) => e.id == id);
    if (index != -1) {
      list[index].isRead = !list[index].isRead;
      
      // Update di Firebase
      await firebaseService.updateBook(list[index]);
      
      // Refresh local
      list.refresh();
      storage.write('reading_list', list.map((e) => e.toJson()).toList());
    }
  }

  void deleteItem(String id) async {
    // Delete dari Firebase
    await firebaseService.deleteBook(id);
  }

  void updateItem(String id, String title, {List<String>? tags, String? imageUrl}) async {
    int index = list.indexWhere((e) => e.id == id);
    list[index].title = title;
    if (tags != null) {
      list[index].tags = tags.where((t) => this.tags.contains(t)).toList();
    }
    if (imageUrl != null) {
      list[index].imageUrl = imageUrl;
    }
    
    // Update di Firebase
    await firebaseService.updateBook(list[index]);
    
    list.refresh();
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

  void addTag(String tag) async {
    final t = tag.trim();
    if (t.isEmpty) return;
    if (!tags.contains(t)) {
      // Add ke Firebase
      await firebaseService.addTag(t);
    }
  }

  void removeTag(String tag) async {
    // Delete dari Firebase
    await firebaseService.deleteTag(tag);
    
    // Update semua buku yang punya tag ini
    for (var item in list) {
      if (item.tags.contains(tag)) {
        item.tags.remove(tag);
        await firebaseService.updateBook(item);
      }
    }
  }

  void removeTags(List<String> removed) async {
    // Delete dari Firebase
    await firebaseService.deleteTags(removed);
    
    // Update semua buku yang punya tags ini
    for (var item in list) {
      if (item.tags.any((t) => removed.contains(t))) {
        item.tags.removeWhere((t) => removed.contains(t));
        await firebaseService.updateBook(item);
      }
    }
  }

  // Color helpers dihapus
  // void setSelectedColor(String key) { ... }
  // Color get selectedColor => ... ; // Ini sekarang getter dummy
  Color get selectedColor => Colors.white; // Mengembalikan putih secara default

  // 'selectedTextColor' tidak lagi diperlukan
}