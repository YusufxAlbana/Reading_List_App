// lib/views/explore_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 1. Ubah menjadi StatefulWidget
class ExploreView extends StatefulWidget {
  ExploreView({super.key});

  // Data dummy dipindahkan ke sini agar bisa diakses oleh State
  final List<Map<String, dynamic>> topRecommendations = [
    {
      'title': 'Atomic Habits',
      'author': 'James Clear',
      'description': 'Panduan praktis untuk membangun kebiasaan baik dan menghilangkan kebiasaan buruk dengan perubahan kecil yang memberikan hasil luar biasa.',
      'rating': 4.8,
      'reviews': 15234,
      'imageUrl': 'assets/images/1.png',
      'color': const Color(0xFF8B4513),
    },
    {
      'title': 'The Psychology of Money',
      'author': 'Morgan Housel',
      'description': 'Kumpulan cerita pendek tentang bagaimana orang berpikir tentang uang dan mengajarkan cara membuat keputusan finansial yang lebih baik.',
      'rating': 4.7,
      'reviews': 12890,
      'imageUrl': 'assets/images/2.png', // Path gambar diubah
      'color': const Color(0xFF2F4F4F),
    },
    {
      'title': 'Sapiens',
      'author': 'Yuval Noah Harari',
      'description': 'Sejarah singkat umat manusia dari zaman batu hingga era modern, mengeksplorasi bagaimana Homo sapiens menjadi spesies dominan.',
      'rating': 4.6,
      'reviews': 23456,
      'imageUrl': 'assets/images/3.png', // Path gambar diubah
      'color': const Color(0xFF556B2F),
    },
    {
      'title': 'Deep Work',
      'author': 'Cal Newport',
      'description': 'Aturan untuk fokus sukses di dunia yang penuh distraksi, mengajarkan bagaimana mengembangkan kemampuan bekerja secara mendalam.',
      'rating': 4.5,
      'reviews': 9876,
      'imageUrl': 'assets/images/4.png', // Path gambar diubah
      'color': const Color(0xFFCC7722),
    },
  ];

  final List<Map<String, dynamic>> popularBooks = [
    {
      'title': 'Think and Grow Rich',
      'author': 'Napoleon Hill',
      'description': 'Filosofi klasik tentang kesuksesan pribadi dan finansial berdasarkan wawancara dengan orang-orang sukses.',
      'rating': 4.4,
      'reviews': 8765,
      'imageUrl': 'assets/images/1.png',
      'color': const Color(0xFF4B0082),
    },
    {
      'title': 'The Lean Startup',
      'author': 'Eric Ries',
      'description': 'Pendekatan baru untuk membangun dan meluncurkan startup dengan cepat dan efisien melalui iterasi dan pembelajaran.',
      'rating': 4.3,
      'reviews': 7654,
      'imageUrl': 'assets/images/2.png',
      'color': const Color(0xFFDC143C),
    },
    {
      'title': 'Educated',
      'author': 'Tara Westover',
      'description': 'Memoar yang menginspirasi tentang seorang wanita yang tumbuh di keluarga survivalis dan perjalanannya menuju pendidikan.',
      'rating': 4.6,
      'reviews': 11234,
      'imageUrl': 'assets/images/3.png',
      'color': const Color(0xFF8B4513),
    },
    {
      'title': 'The 7 Habits',
      'author': 'Stephen Covey',
      'description': 'Tujuh kebiasaan orang yang sangat efektif untuk mencapai kesuksesan pribadi dan profesional.',
      'rating': 4.5,
      'reviews': 14567,
      'imageUrl': 'assets/images/4.png',
      'color': const Color(0xFF2F4F4F),
    },
    // ... (data dummy lainnya tetap sama)
  ];

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

// 2. Buat Class State
class _ExploreViewState extends State<ExploreView> {
  // 3. Tambahkan state untuk pencarian
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // 4. Tambahkan list untuk data yang sudah difilter
  List<Map<String, dynamic>> _filteredTopRecommendations = [];
  List<Map<String, dynamic>> _filteredPopularBooks = [];

  @override
  void initState() {
    super.initState();
    // 5. Inisialisasi list filter dengan data penuh saat pertama kali dibuka
    _filteredTopRecommendations = widget.topRecommendations;
    _filteredPopularBooks = widget.popularBooks;
    
    // 6. Tambahkan listener ke controller
    _searchController.addListener(_filterLists);
  }

  @override
  void dispose() {
    // 7. Bersihkan controller
    _searchController.removeListener(_filterLists);
    _searchController.dispose();
    super.dispose();
  }

  // 8. Buat fungsi untuk memfilter
  void _filterLists() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();

      if (_searchQuery.isEmpty) {
        // Jika search kosong, tampilkan semua
        _filteredTopRecommendations = widget.topRecommendations;
        _filteredPopularBooks = widget.popularBooks;
      } else {
        // Jika ada query, filter kedua list
        _filteredTopRecommendations = widget.topRecommendations
            .where((book) =>
                book['title'].toLowerCase().contains(_searchQuery) ||
                book['author'].toLowerCase().contains(_searchQuery))
            .toList();
        
        _filteredPopularBooks = widget.popularBooks
            .where((book) =>
                book['title'].toLowerCase().contains(_searchQuery) ||
                book['author'].toLowerCase().contains(_searchQuery))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // 9. Cek apakah ada hasil pencarian
    final bool noResults = _filteredTopRecommendations.isEmpty &&
                           _filteredPopularBooks.isEmpty &&
                           _searchQuery.isNotEmpty;

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
          'Explore Books',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // 10. Hapus icon search di AppBar, karena kita ganti dengan TextField di body
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFFE8C547)),
            onPressed: () {
              Get.snackbar(
                'Tentang Halaman Explore',
                'Data di halaman ini adalah data dummy (contoh).',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF3D5159),
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 11. Tambahkan TextField untuk Search
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D5159),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: TextField(
                    controller: _searchController, // Hubungkan controller
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search by title or author...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white38, size: 20),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : const SizedBox.shrink(),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              // 12. Tampilkan UI berdasarkan hasil filter
              if (noResults)
                _buildEmptySearchState() // Tampilkan jika tidak ada hasil
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Recommendations Section
                    // 13. Hanya tampilkan section jika list-nya tidak kosong
                    if (_filteredTopRecommendations.isNotEmpty) ...[
                      const Text(
                        '🌟 Top Recomendations',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _searchQuery.isEmpty 
                          ? "Editor's choice of the best books"
                          : "Hasil pencarian di Top Recommendations",
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 14. Gunakan list yang sudah difilter
                      ..._filteredTopRecommendations.map((book) => _buildBookCard(book, true)),
                      
                      const SizedBox(height: 32),
                    ],
                    
                    // Popular Books Section
                    // 15. Hanya tampilkan section jika list-nya tidak kosong
                    if (_filteredPopularBooks.isNotEmpty) ...[
                      const Text(
                        '🔥 Popular This Week',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _searchQuery.isEmpty 
                          ? 'The most widely read book'
                          : "Hasil pencarian di Popular This Week",
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 16. Gunakan list yang sudah difilter
                      ..._filteredPopularBooks.map((book) => _buildBookCard(book, false)),
                      
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 17. Widget untuk Tampilan "Tidak Ada Hasil"
  Widget _buildEmptySearchState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            const Icon(Icons.search_off, color: Colors.white24, size: 64),
            const SizedBox(height: 16),
            Text(
              'No results found for "$_searchQuery"',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try another keyword for the title or author',
              style: TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book, bool isTopRecommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3D5159),
        borderRadius: BorderRadius.circular(12),
        border: isTopRecommendation 
          ? Border.all(color: const Color(0xFFE8C547), width: 2)
          : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.2 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Cover
          Container(
            width: 80,
            height: 120,
            decoration: BoxDecoration(
              color: book['color'] as Color,
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
              // Gunakan Image.asset karena path ada di assets
              child: (book['imageUrl'] != null && book['imageUrl'].toString().isNotEmpty)
                ? Image.asset(
                    book['imageUrl'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildFallbackCover(book['title']);
                    },
                  )
                : _buildFallbackCover(book['title']),
            ),
          ),
          const SizedBox(width: 16),
          
          // Book Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge untuk top recommendation
                if (isTopRecommendation)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8C547),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'TOP PICK',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isTopRecommendation) const SizedBox(height: 8),
                
                // Title
                Text(
                  book['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
                // Author
                Text(
                  'oleh ${book['author']}',
                  style: const TextStyle(
                    color: Color(0xFFE8C547),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Rating
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFD700), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      book['rating'].toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${book['reviews']} reviews)',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Description
                Text(
                  book['description'],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                // Action Button
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigasi ke halaman add dengan data buku sudah terisi
                    Get.toNamed('/add', arguments: {
                      'title': book['title'],
                      'author': book['author'],
                      'description': book['description'],
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add to Reading List'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8C547),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method untuk fallback cover (jika imageUrl kosong)
  Widget _buildFallbackCover(String title) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}