import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/reading_item.dart';

class ReadingController extends GetxController {
  final storage = GetStorage();
  final list = <ReadingItem>[].obs;

  // Search + Filter
  final searchQuery = ''.obs;
  final filterStatus = 'all'.obs; // all, read, unread
  final sortOrder = 'newest'.obs; // newest or oldest

  @override
  void onInit() {
    List? stored = storage.read('reading_list');
    if (stored != null) {
      list.assignAll(stored.map((e) => ReadingItem.fromJson(e)));
    }
    ever(list, (_) => storage.write('reading_list', list.map((e) => e.toJson()).toList()));
    super.onInit();
  }

  List<ReadingItem> get filteredList {
    var filtered = list.where((e) => e.title.toLowerCase().contains(searchQuery.value.toLowerCase()));

    if (filterStatus.value == 'read') {
      filtered = filtered.where((e) => e.isRead);
    } else if (filterStatus.value == 'unread') {
      filtered = filtered.where((e) => !e.isRead);
    }

    var result = filtered.toList();
    // sort by createdAt based on sortOrder
    if (sortOrder.value == 'newest') {
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    return result;
  }

  void addItem(String title) {
    list.add(ReadingItem(id: DateTime.now().toString(), title: title, createdAt: DateTime.now()));
  }

  void toggleStatus(String id) {
    int index = list.indexWhere((e) => e.id == id);
    list[index].isRead = !list[index].isRead;
    list.refresh();
  }

  void deleteItem(String id) {
    list.removeWhere((e) => e.id == id);
  }

  void updateItem(String id, String title) {
    int index = list.indexWhere((e) => e.id == id);
    list[index].title = title;
    list.refresh();
  }
}
