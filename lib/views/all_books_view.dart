import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reading_controller.dart';
import '../models/reading_item.dart';

class AllBooksView extends StatelessWidget {
  AllBooksView({super.key});

  final controller = Get.find<ReadingController>();
  final RxMap<String, ReadingItem> deletedItems = <String, ReadingItem>{}.obs;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E45),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E45),
        elevation: 0,
        title: const Text(
          'All Books',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFFE8C547)),
            onPressed: _showFilterSheet,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
            controller.list.refresh();
          },
          color: const Color(0xFFE8C547),
          backgroundColor: const Color(0xFF3D5159),
          child: Column(
            children: [
              // Statistics Card
              Padding(
                padding: const EdgeInsets.all(16),
                child: Obx(() {
                  final total = controller.list.length;
                  final read = controller.list.where((e) => e.isRead).length;
                  final unread = total - read;
                  final filtered = controller.filteredList.length;
                  final isFiltered = controller.filterStatus.value != 'all' ||
                      controller.searchQuery.value.isNotEmpty ||
                      controller.selectedTags.isNotEmpty;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3D5159), Color(0xFF2C3E45)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8C547).withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(Icons.library_books, 'Total', total.toString()),
                            _buildStatItem(Icons.check_circle, 'Read', read.toString()),
                            _buildStatItem(Icons.pending, 'Unread', unread.toString()),
                          ],
                        ),
                        if (isFiltered) ...[
                          const SizedBox(height: 8),
                          const Divider(color: Colors.white24, height: 1),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Showing $filtered ${filtered == 1 ? 'book' : 'books'}',
                                style: const TextStyle(color: Color(0xFFE8C547), fontSize: 12),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  controller.searchQuery.value = '';
                                  controller.filterStatus.value = 'all';
                                  controller.selectedTags.clear();
                                },
                                icon: const Icon(Icons.clear_all, size: 16, color: Color(0xFFE8C547)),
                                label: const Text(
                                  'Clear Filters',
                                  style: TextStyle(color: Color(0xFFE8C547), fontSize: 12),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ),
              
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D5159),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search books...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                      suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white38, size: 20),
                              onPressed: () => controller.searchQuery.value = '',
                            )
                          : const SizedBox.shrink()),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (v) => controller.searchQuery.value = v,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Books Grid
              Expanded(
                child: Obx(() {
                  final books = controller.filteredList;
                  
                  if (books.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3D5159).withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.menu_book, color: Colors.white38, size: 60),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'No books found',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              controller.searchQuery.value.isNotEmpty 
                                ? 'Try adjusting your search or filters'
                                : 'Start adding books to your library',
                              style: const TextStyle(color: Colors.white54, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            if (controller.list.isEmpty) ...[
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => Get.toNamed('/add'),
                                icon: const Icon(Icons.add, color: Colors.black),
                                label: const Text('Add Your First Book'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE8C547),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 2 : (screenWidth < 1000 ? 3 : 4),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: books.length,
                    itemBuilder: (ctx, i) => _buildDismissibleCard(books[i], i),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add'),
        backgroundColor: const Color(0xFFE8C547),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFE8C547), size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDismissibleCard(item, int index) {
    return Dismissible(
      key: Key(item.id),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('Delete', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        // Store the deleted item for undo
        deletedItems[item.id] = item;
        
        // Show snackbar with undo option
        Get.snackbar(
          'Book Deleted',
          '"${item.title}" has been removed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF3D5159),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          icon: const Icon(Icons.delete_outline, color: Color(0xFFE8C547)),
          mainButton: TextButton(
            onPressed: () {
              // Undo delete
              if (deletedItems.containsKey(item.id)) {
                controller.list.add(deletedItems[item.id]!);
                deletedItems.remove(item.id);
                Get.back();
              }
            },
            child: const Text(
              'UNDO',
              style: TextStyle(color: Color(0xFFE8C547), fontWeight: FontWeight.bold),
            ),
          ),
        );
        
        // Actually delete after snackbar duration
        Future.delayed(const Duration(seconds: 3), () {
          if (deletedItems.containsKey(item.id)) {
            deletedItems.remove(item.id);
          }
        });
        
        return true;
      },
      onDismissed: (direction) {
        controller.deleteItem(item.id);
      },
      child: _bookCard(item, index),
    );
  }

  Widget _bookCard(item, int index) {
    final colors = [
      const Color(0xFF8B4513),
      const Color(0xFF2F4F4F),
      const Color(0xFF556B2F),
      const Color(0xFFCC7722),
      const Color(0xFF4B0082),
      const Color(0xFFDC143C),
    ];
    
    return GestureDetector(
      onTap: () => Get.toNamed('/edit', arguments: item),
      onLongPress: () => _showBookDetails(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: const Color(0xFF3D5159),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                padding: const EdgeInsets.all(12),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Read status badge
                    if (item.isRead)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8C547),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Read',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Book Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.timeAgo(),
                      style: const TextStyle(color: Colors.white54, fontSize: 10),
                    ),
                    if (item.tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        children: item.tags.take(2).map<Widget>((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C3E45),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              color: Color(0xFFE8C547),
                              fontSize: 9,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF2C3E45),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort & Filter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text('Sort Order', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              Obx(() => Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Newest'),
                    selected: controller.sortOrder.value == 'newest',
                    onSelected: (_) => controller.sortOrder.value = 'newest',
                    selectedColor: const Color(0xFFE8C547),
                    backgroundColor: const Color(0xFF3D5159),
                    labelStyle: TextStyle(
                      color: controller.sortOrder.value == 'newest'
                          ? Colors.black
                          : Colors.white70,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('Oldest'),
                    selected: controller.sortOrder.value == 'oldest',
                    onSelected: (_) => controller.sortOrder.value = 'oldest',
                    selectedColor: const Color(0xFFE8C547),
                    backgroundColor: const Color(0xFF3D5159),
                    labelStyle: TextStyle(
                      color: controller.sortOrder.value == 'oldest'
                          ? Colors.black
                          : Colors.white70,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('A-Z'),
                    selected: controller.sortOrder.value == 'a-z',
                    onSelected: (_) => controller.sortOrder.value = 'a-z',
                    selectedColor: const Color(0xFFE8C547),
                    backgroundColor: const Color(0xFF3D5159),
                    labelStyle: TextStyle(
                      color: controller.sortOrder.value == 'a-z'
                          ? Colors.black
                          : Colors.white70,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('Z-A'),
                    selected: controller.sortOrder.value == 'z-a',
                    onSelected: (_) => controller.sortOrder.value = 'z-a',
                    selectedColor: const Color(0xFFE8C547),
                    backgroundColor: const Color(0xFF3D5159),
                    labelStyle: TextStyle(
                      color: controller.sortOrder.value == 'z-a'
                          ? Colors.black
                          : Colors.white70,
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 24),
              const Text('Status', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              Obx(() => Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: controller.filterStatus.value == 'all',
                    onSelected: (_) => controller.filterStatus.value = 'all',
                    selectedColor: const Color(0xFFE8C547),
                    backgroundColor: const Color(0xFF3D5159),
                    labelStyle: TextStyle(
                      color: controller.filterStatus.value == 'all'
                          ? Colors.black
                          : Colors.white70,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('Unread'),
                    selected: controller.filterStatus.value == 'unread',
                    onSelected: (_) => controller.filterStatus.value = 'unread',
                    selectedColor: const Color(0xFFE8C547),
                    backgroundColor: const Color(0xFF3D5159),
                    labelStyle: TextStyle(
                      color: controller.filterStatus.value == 'unread'
                          ? Colors.black
                          : Colors.white70,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('Read'),
                    selected: controller.filterStatus.value == 'read',
                    onSelected: (_) => controller.filterStatus.value = 'read',
                    selectedColor: const Color(0xFFE8C547),
                    backgroundColor: const Color(0xFF3D5159),
                    labelStyle: TextStyle(
                      color: controller.filterStatus.value == 'read'
                          ? Colors.black
                          : Colors.white70,
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.filterStatus.value = 'all';
                        controller.sortOrder.value = 'newest';
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE8C547),
                        side: const BorderSide(color: Color(0xFFE8C547)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8C547),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookDetails(item) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF2C3E45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.event, 'Added', item.timeAgo()),
              const SizedBox(height: 12),
              _buildDetailRow(
                item.isRead ? Icons.check_circle : Icons.pending,
                'Status',
                item.isRead ? 'Read' : 'Unread',
              ),
              if (item.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow(Icons.label, 'Tags', item.tags.join(', ')),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        controller.toggleStatus(item.id);
                        Get.back();
                      },
                      icon: Icon(
                        item.isRead ? Icons.remove_done : Icons.check,
                        color: const Color(0xFFE8C547),
                      ),
                      label: Text(item.isRead ? 'Mark Unread' : 'Mark Read'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE8C547),
                        side: const BorderSide(color: Color(0xFFE8C547)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        Get.toNamed('/edit', arguments: item);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8C547),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE8C547), size: 20),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
