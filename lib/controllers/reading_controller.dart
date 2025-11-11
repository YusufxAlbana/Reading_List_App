// lib/controllers/reading_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reading_item.dart';

class ReadingController extends GetxController {
  final storage = GetStorage();
  final firestore = FirebaseFirestore.instance;
  final list = <ReadingItem>[].obs;
  final tags = <String>[].obs;
  final isLoading = false.obs;

  // Search + Filter
  final searchQuery = ''.obs;
  final filterStatus = 'all'.obs; // all, read, unread
  final sortOrder = 'newest'.obs; // newest or oldest
  final selectedTags = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFromFirestore();
    
    // Backup ke local storage saat ada perubahan
    ever(list,
        (_) => storage.write('reading_list', list.map((e) => e.toJson()).toList()));
    ever(tags, (_) => storage.write('reading_tags', tags.toList()));
  }
  
  // Load data dari Firestore
  Future<void> loadFromFirestore() async {
    try {
      isLoading.value = true;
      
      // Load books
      final booksSnapshot = await firestore.collection('books').get();
      final books = booksSnapshot.docs
          .map((doc) => ReadingItem.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      list.assignAll(books);
      
      // Load tags
      final tagsSnapshot = await firestore.collection('tags').get();
      final loadedTags = tagsSnapshot.docs
          .map((doc) => doc.data()['name'] as String)
          .toList();
      tags.assignAll(loadedTags);
      
      print('✅ Data berhasil dimuat dari Firestore: ${books.length} buku');
    } catch (e) {
      print('❌ Error loading from Firestore: $e');
      // Fallback ke local storage jika Firestore gagal
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
    } finally {
      isLoading.value = false;
    }
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
  Future<void> addItem(
    String title, {
    String? author, // ⬅️ DITAMBAHKAN
    String? notes, // ⬅️ DITAMBAHKAN
    List<String>? tags, 
    String? imageUrl
  }) async {
    final validTags = (tags ?? []).where((t) => this.tags.contains(t)).toList();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = ReadingItem(
        id: id,
        title: title,
        author: author, // ⬅️ Digunakan
        notes: notes,  // ⬅️ Digunakan
        createdAt: DateTime.now(),
        tags: validTags,
        imageUrl: imageUrl); 
    
    list.add(item);
    
    // Simpan ke Firestore
    try {
      await firestore.collection('books').doc(id).set(item.toJson());
      print('✅ Buku disimpan ke Firestore: $title');
    } catch (e) {
      print('❌ Error saving to Firestore: $e');
    }
  }

  Future<void> toggleStatus(String id) async {
    int index = list.indexWhere((e) => e.id == id);
    if (index != -1) {
      list[index].isRead = !list[index].isRead;
      
      list.refresh();
      
      // Update status di Firestore
      try {
        await firestore.collection('books').doc(id).update({
          'isRead': list[index].isRead
        });
        print('✅ Status buku diupdate di Firestore');
      } catch (e) {
        print('❌ Error updating status in Firestore: $e');
      }
    }
  }

  /// Set read status explicitly. Useful for undo operations.
  Future<void> setStatus(String id, bool read) async {
    int index = list.indexWhere((e) => e.id == id);
    if (index != -1) {
      list[index].isRead = read;
      list.refresh();
      
      // Update status di Firestore
      try {
        await firestore.collection('books').doc(id).update({
          'isRead': read
        });
      } catch (e) {
        print('❌ Error updating status in Firestore: $e');
      }
    }
  }

  Future<void> deleteItem(String id) async {
    list.removeWhere((e) => e.id == id);
    
    // Hapus dari Firestore
    try {
      await firestore.collection('books').doc(id).delete();
      print('✅ Buku dihapus dari Firestore');
    } catch (e) {
      print('❌ Error deleting from Firestore: $e');
    }
  }

  // ✅ MEMPERBAIKI UNDEFINED NAMED PARAMETER DI updateItem
  Future<void> updateItem(
    String id, 
    String title, {
    String? author, // ⬅️ DITAMBAHKAN
    String? notes, // ⬅️ DITAMBAHKAN
    List<String>? tags, 
    String? imageUrl
  }) async {
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
      
      // Update di Firestore
      try {
        await firestore.collection('books').doc(id).update(list[index].toJson());
        print('✅ Buku diupdate di Firestore: $title');
      } catch (e) {
        print('❌ Error updating Firestore: $e');
      }
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

  Future<void> addTag(String tag) async {
    final t = tag.trim();
    if (t.isEmpty) return;
    if (!tags.contains(t)) {
      tags.add(t);
      
      // Simpan tag ke Firestore
      try {
        await firestore.collection('tags').doc(t).set({'name': t});
        print('✅ Tag disimpan ke Firestore: $t');
      } catch (e) {
        print('❌ Error saving tag to Firestore: $e');
      }
    }
  }

  Future<void> removeTag(String tag) async {
    tags.remove(tag);
    for (var item in list) {
      if (item.tags.contains(tag)) {
        item.tags.remove(tag);
      }
    }
    list.refresh();
    
    // Hapus tag dari Firestore
    try {
      await firestore.collection('tags').doc(tag).delete();
      print('✅ Tag dihapus dari Firestore: $tag');
    } catch (e) {
      print('❌ Error deleting tag from Firestore: $e');
    }
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