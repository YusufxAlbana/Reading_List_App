import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/reading_item.dart';

class ReadingController extends GetxController {
  final storage = GetStorage();
  final list = <ReadingItem>[].obs;
  final tags = <String>[].obs;

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
    // Logic untuk storedColor dihapus
    // final storedColor = storage.read('app_bg_color');
    // if (storedColor != null && colorOptions.containsKey(storedColor)) {
    //   selectedColorKey.value = storedColor;
    // }
    ever(list,
        (_) => storage.write('reading_list', list.map((e) => e.toJson()).toList()));
    ever(tags, (_) => storage.write('reading_tags', tags.toList()));
    // ever(selectedColorKey, (_) => storage.write('app_bg_color', selectedColorKey.value)); // Dihapus
    super.onInit();
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

  void addItem(String title, {List<String>? tags}) {
    final validTags = (tags ?? []).where((t) => this.tags.contains(t)).toList();
    list.add(ReadingItem(
        id: DateTime.now().toString(),
        title: title,
        createdAt: DateTime.now(),
        tags: validTags));
  }

  void toggleStatus(String id) {
    int index = list.indexWhere((e) => e.id == id);
    if (index != -1) {
      list[index].isRead = !list[index].isRead;
      list.refresh();
      // Force storage write to ensure persistence
      storage.write('reading_list', list.map((e) => e.toJson()).toList());
    }
  }

  void deleteItem(String id) {
    list.removeWhere((e) => e.id == id);
  }

  void updateItem(String id, String title, {List<String>? tags}) {
    int index = list.indexWhere((e) => e.id == id);
    list[index].title = title;
    if (tags != null) {
      list[index].tags = tags.where((t) => this.tags.contains(t)).toList();
    }
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

  // Color helpers dihapus
  // void setSelectedColor(String key) { ... }
  // Color get selectedColor => ... ; // Ini sekarang getter dummy
  Color get selectedColor => Colors.white; // Mengembalikan putih secara default

  // 'selectedTextColor' tidak lagi diperlukan
}