import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reading_controller.dart';
import '../models/reading_item.dart';

class EditView extends StatefulWidget {
  const EditView({super.key});

  @override
  State<EditView> createState() => _EditViewState();
}

class _EditViewState extends State<EditView> {
  final controller = Get.find<ReadingController>();
  late final ReadingItem item;
  late final TextEditingController textController;
  late final TextEditingController imageUrlController;
  final pickedTags = <String>[].obs;

  @override
  void initState() {
    super.initState();
    item = Get.arguments as ReadingItem;
    textController = TextEditingController(text: item.title);
    imageUrlController = TextEditingController(text: item.imageUrl ?? '');
    pickedTags.assignAll(
      item.tags.where((t) => controller.tags.contains(t)).toList(),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF2C3E45),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E45),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Edit Book',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _showDeleteConfirmation(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Title Section
              _buildSection(
                'Book Title',
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D5159),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: textController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Enter book title...',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    maxLines: null,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Book Cover URL Section
              _buildSection(
                'Book Cover Image',
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D5159),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: imageUrlController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'https://example.com/book-cover.jpg',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Reading Status Section
              _buildSection(
                'Reading Status',
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D5159),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile(
                    title: const Text(
                      'Mark as Read',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    subtitle: Text(
                      item.isRead ? 'Completed' : 'Not yet finished',
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                    value: item.isRead,
                    activeTrackColor: const Color(0xFFE8C547),
                    activeThumbColor: Colors.black,
                    onChanged: (bool value) {
                      setState(() {
                        controller.toggleStatus(item.id);
                      });
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Tags Section
              _buildSection(
                'Categories',
                Obx(() {
                  final tags = controller.tags;
                  
                  if (tags.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D5159),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.label_outline, 
                            color: Colors.white38, size: 40),
                          const SizedBox(height: 12),
                          const Text(
                            'No tags available',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => Get.toNamed('/tags'),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Create Tags'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFE8C547),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((tag) {
                      return Obx(() => FilterChip(
                        label: Text(tag),
                        selected: pickedTags.contains(tag),
                        selectedColor: const Color(0xFFE8C547),
                        backgroundColor: const Color(0xFF3D5159),
                        labelStyle: TextStyle(
                          color: pickedTags.contains(tag) 
                            ? Colors.black 
                            : Colors.white70,
                          fontSize: 13,
                        ),
                        checkmarkColor: Colors.black,
                        onSelected: (_) {
                          if (pickedTags.contains(tag)) {
                            pickedTags.remove(tag);
                          } else {
                            pickedTags.add(tag);
                          }
                        },
                      ));
                    }).toList(),
                  );
                }),
              ),
              
              const SizedBox(height: 24),
              
              // Book Info
              _buildSection(
                'Book Information',
                Obx(() => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D5159),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _infoRow('Added', item.timeAgo()),
                      const Divider(color: Colors.white24, height: 24),
                      _infoRow('Status', item.isRead ? 'Completed' : 'Reading'),
                      const Divider(color: Colors.white24, height: 24),
                      _infoRow('Tags', 
                        pickedTags.isEmpty ? 'No tags' : '${pickedTags.length} tags'),
                    ],
                  ),
                )),
              ),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white38),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8C547),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: isMobile ? 80 : 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFE8C547),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _saveChanges() {
    final newTitle = textController.text.trim();
    
    if (newTitle.isEmpty) {
      Get.snackbar(
        'Error',
        'Book title cannot be empty',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      return;
    }
    
    controller.updateItem(
      item.id,
      newTitle,
      tags: pickedTags.toList(),
      imageUrl: imageUrlController.text.trim().isEmpty 
        ? null 
        : imageUrlController.text.trim(),
    );
    
    Get.back();
    
    Get.snackbar(
      'Success',
      'Book updated successfully',
      backgroundColor: const Color(0xFFE8C547),
      colorText: Colors.black,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
    );
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF3D5159),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orangeAccent,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Book?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete "${item.title}"?',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white38),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.deleteItem(item.id);
                        Get.back(); // Close dialog
                        Get.back(); // Go back to home
                        Get.snackbar(
                          'Deleted',
                          'Book deleted successfully',
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 8,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Delete'),
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
}