// lib/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reading_controller.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final controller = Get.put(ReadingController());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1000;
    
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E45),
      appBar: isMobile ? _buildMobileAppBar() : null,
      body: SafeArea(
        child: isMobile 
          ? _buildMobileLayout()
          : Row(
              children: [
                // Left Navigation Sidebar (Desktop only)
                if (!isTablet) _buildLeftNav(),
                
                // Main Content
                Expanded(
                  child: Column(
                    children: [
                      _buildTopBar(), // <-- Search bar dihapus dari sini
                      Expanded(
                        child: _buildMainContent(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/add'),
        backgroundColor: const Color(0xFFE8C547),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('Add Book', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
      bottomNavigationBar: isMobile ? _buildBottomNav() : null,
    );
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF2C3E45),
      elevation: 0,
      title: const Text(
        'Reading List App',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Color(0xFFE8C547)),
          onPressed: _showFilterSheet,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBottomNav() {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF1E2D34),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha((0.2 * 255).round()),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomNavItem(Icons.home, 'Home', true, () {
              // Already on home, do nothing
            }),
            _bottomNavItem(Icons.bookmark_border, 'Already read', false, () {
              Get.toNamed('/read-books');
            }),
            _bottomNavItem(Icons.explore_outlined, 'Explore', false, () {
              Get.toNamed('/explore');
            }),
          ],
        ),
      ),
    ),
  );
}

  Widget _bottomNavItem(IconData icon, String label, bool active, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: active ? const Color(0xFFE8C547) : Colors.white54,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFFE8C547) : Colors.white54,
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildMobileLayout() {
    return CustomScrollView(
      slivers: [
        // --- BAGIAN SEARCH BAR DIHAPUS DARI SINI ---
        
        // Previous Reading Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), // Padding atas ditambahkan
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Last Reading',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final books = controller.filteredList
                      .where((b) => !b.isRead)
                      .take(6)
                      .toList();
                  
                  if (books.isEmpty) {
                    return _emptyState(
                        'There are no unfinished readings',
                        'Add the first reading to begin',
                    );
                  }
                  
                  return SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: books.length,
                      itemBuilder: (ctx, i) => _mobileBookCard(books[i], i),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        
        // Subjects Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                         'Tags',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final tags = controller.availableTags;
                  
                  if (tags.isEmpty) {
                    return _emptyState(
                      'No categories',
                      'Create tags to organize your books',
                    );
                  }
                  
                  return Column(
                    children: tags.take(6).map((tag) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _mobileSubjectCard(tag),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        
        // New Books Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Books',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/all-books'),
                      child: const Text(
                        'View All',
                        style: TextStyle(color: Color(0xFFE8C547), fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final books = controller.filteredList.take(6).toList();
                  
                  if (books.isEmpty) {
                    return _emptyState(
                      'No books yet',
                      'Start building your reading list',
                    );
                  }
                  
                  return SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: books.length,
                      itemBuilder: (ctx, i) => _mobileBookCard(books[i], i),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        
        // Statistics
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            child: _buildMobileStats(),
          ),
        ),
      ],
    );
  }

  Widget _buildLeftNav() {
  return Container(
    width: 70,
    color: const Color(0xFF1E2D34),
    child: Column(
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.local_library, color: Colors.white70, size: 30),
        const SizedBox(height: 40),
        _navIcon(Icons.home, true, () {
          // Already on home, do nothing
        }),
        _navIcon(Icons.bookmark_border, false, () {
          Get.toNamed('/read-books');
        }),
        _navIcon(Icons.explore_outlined, false, () {
          Get.toNamed('/explore');
        }),
        const Spacer(),
        const SizedBox(height: 20),
      ],
    ),
  );
}

  Widget _navIcon(IconData icon, bool active, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF3D5159) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: active ? const Color(0xFFE8C547) : Colors.white54,
        size: 22,
      ),
    ),
  );
}

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            'Library',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 24),
          const Text(
            'Books',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const Spacer(),
          
          // --- BAGIAN SEARCH BAR DIHAPUS DARI SINI ---

          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFE8C547),
            child: const Text(
              'U',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Previous Reading Section
            _buildPreviousReading(),
            const SizedBox(height: 32),
            
            // Subjects Section
            _buildSubjects(),
            const SizedBox(height: 32),
            
            // New Books Section
            _buildNewBooks(),
            const SizedBox(height: 32),
            
            // Statistics
            _buildStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousReading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Previous Reading',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () => Get.toNamed('/all-books'),
                  child: const Text(
                    'View all',
                    style: TextStyle(color: Color(0xFFE8C547)),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _showFilterSheet,
                  icon: const Icon(Icons.filter_list, color: Color(0xFFE8C547), size: 18),
                  label: const Text(
                    'Filter',
                    style: TextStyle(color: Color(0xFFE8C547)),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          final books = controller.filteredList.where((b) => !b.isRead).take(6).toList();
          
          if (books.isEmpty) {
            return _emptyState('No reading has been completed yet', 'Add the first reading to begin');
          }
          
          return SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: books.length,
              itemBuilder: (ctx, i) => _bookCard(books[i], i),
            ),
          );
        }),
      ],
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
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.3 * 255).round()),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.title,
              style: const TextStyle(color: Colors.white, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              item.timeAgo(),
              style: const TextStyle(color: Colors.white54, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjects() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subjects section',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final tags = controller.availableTags;
          
          if (tags.isEmpty) {
            return _emptyState('No categories yet', 'Create tags to organize your reading');
          }
          
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: tags.take(6).map((tag) => _subjectCard(tag)).toList(),
          );
        }),
      ],
    );
  }

  Widget _subjectCard(String tag) {
    final count = controller.list.where((b) => b.tags.contains(tag)).length;
    final isSpecial = count > 20;
    
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSpecial ? const Color(0xFFE8C547) : const Color(0xFF3D5159),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _getTagIcon(tag),
            color: isSpecial ? Colors.black : Colors.white54,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tag,
                  style: TextStyle(
                    color: isSpecial ? Colors.black : const Color(0xFFE8C547),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$count',
                  style: TextStyle(
                    color: isSpecial ? Colors.black : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Books available',
                  style: TextStyle(
                    color: isSpecial ? Colors.black54 : Colors.white54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTagIcon(String tag) {
    final lower = tag.toLowerCase();
    if (lower.contains('science')) return Icons.science;
    if (lower.contains('art')) return Icons.palette;
    if (lower.contains('business')) return Icons.business_center;
    if (lower.contains('design')) return Icons.design_services;
    if (lower.contains('cook')) return Icons.restaurant;
    return Icons.book;
  }

  Widget _buildNewBooks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'New books',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/all-books'),
              child: const Text(
                'Show all',
                style: TextStyle(color: Color(0xFFE8C547)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          final books = controller.filteredList.take(6).toList();
          
          if (books.isEmpty) {
            return _emptyState('No books yet', 'Start building your reading list');
          }
          
          return SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: books.length,
              itemBuilder: (ctx, i) => _bookCard(books[i], i),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStats() {
    return Obx(() {
      final total = controller.list.length;
      final read = controller.list.where((b) => b.isRead).length;
      final unread = total - read;
      
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF3D5159),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem('Total', total.toString()),
                _statItem('Read', read.toString()),
                _statItem('Unread', unread.toString()),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Get.toNamed('/add'),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Book'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8C547),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.toNamed('/tags'),
                    icon: const Icon(Icons.label_outline, size: 18),
                    label: const Text('Tags'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE8C547),
                      side: const BorderSide(color: Color(0xFFE8C547)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFE8C547),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _emptyState(String title, String subtitle) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF3D5159),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book, color: Colors.white38, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
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
                    labelStyle: TextStyle(
                      color: controller.sortOrder.value == 'oldest'
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
                    labelStyle: TextStyle(
                      color: controller.filterStatus.value == 'read'
                          ? Colors.black
                          : Colors.white70,
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
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
        ),
      ),
    );
  }

  // Mobile-specific widgets
  Widget _mobileBookCard(item, int index) {
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
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.25 * 255).round()),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.title,
              style: const TextStyle(color: Colors.white, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              item.timeAgo(),
              style: const TextStyle(color: Colors.white54, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mobileSubjectCard(String tag) {
    final count = controller.list.where((b) => b.tags.contains(tag)).length;
    final isSpecial = count > 10;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSpecial ? const Color(0xFFE8C547) : const Color(0xFF3D5159),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _getTagIcon(tag),
            color: isSpecial ? Colors.black : Colors.white54,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tag,
                  style: TextStyle(
                    color: isSpecial ? Colors.black : const Color(0xFFE8C547),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$count',
                      style: TextStyle(
                        color: isSpecial ? Colors.black : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Books',
                      style: TextStyle(
                        color: isSpecial ? Colors.black54 : Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStats() {
    return Obx(() {
      final total = controller.list.length;
      final read = controller.list.where((b) => b.isRead).length;
      final unread = total - read;
      
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF3D5159),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _mobileStatItem('Total', total.toString()),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white24,
                ),
                _mobileStatItem('Read', read.toString()),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white24,
                ),
                _mobileStatItem('Unread', unread.toString()),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Get.toNamed('/add'),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Book'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8C547),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.toNamed('/tags'),
                    icon: const Icon(Icons.label_outline, size: 18),
                    label: const Text('Manage Tags'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE8C547),
                      side: const BorderSide(color: Color(0xFFE8C547)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _mobileStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFE8C547),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}