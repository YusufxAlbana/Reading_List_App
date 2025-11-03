// lib/views/read_books_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reading_controller.dart';
import '../models/reading_item.dart';
import 'widgets/book_image_widget.dart';

class ReadBooksView extends StatelessWidget {
  ReadBooksView({super.key});

  final controller = Get.find<ReadingController>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF2C3E45),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E45),
        elevation: 0,
        title: const Text('Read Books', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 300));
            controller.list.refresh();
          },
          color: const Color(0xFFE8C547),
          backgroundColor: const Color(0xFF3D5159),
          child: Obx(() {
            final books = controller.list.where((b) => b.isRead).toList();

            if (books.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(32),
                children: [
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 72, color: Color(0xFFE8C547)),
                        const SizedBox(height: 16),
                        const Text('No read books yet',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('Mark books as read to collect them here',
                            style: TextStyle(color: Colors.white54)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => Get.toNamed('/add'),
                          icon: const Icon(Icons.add, color: Colors.black),
                          label: const Text('Add Book'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8C547),
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 2 : (screenWidth < 1000 ? 3 : 4),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.65,
              ),
              itemCount: books.length,
              itemBuilder: (ctx, i) => _bookCard(books[i]),
            );
          }),
        ),
      ),
    );
  }

  Widget _bookCard(ReadingItem item) {
    return GestureDetector(
      onTap: () => Get.toNamed('/edit', arguments: item),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF3D5159),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: BookImageWidget(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(item.timeAgo(), style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
