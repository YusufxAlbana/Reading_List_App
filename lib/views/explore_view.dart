import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExploreView extends StatelessWidget {
  ExploreView({super.key});

  // Data dummy untuk buku-buku rekomendasi
  final List<Map<String, dynamic>> topRecommendations = [
    {
      'title': 'Atomic Habits',
      'author': 'James Clear',
      'description': 'Panduan praktis untuk membangun kebiasaan baik dan menghilangkan kebiasaan buruk dengan perubahan kecil yang memberikan hasil luar biasa.',
      'rating': 4.8,
      'reviews': 15234,
      'imageUrl': 'assets/images/1.png', // Kosongkan untuk diisi nanti
      'color': const Color(0xFF8B4513),
    },
    {
      'title': 'The Psychology of Money',
      'author': 'Morgan Housel',
      'description': 'Kumpulan cerita pendek tentang bagaimana orang berpikir tentang uang dan mengajarkan cara membuat keputusan finansial yang lebih baik.',
      'rating': 4.7,
      'reviews': 12890,
      'imageUrl': 'assets/images/1.png', // Kosongkan untuk diisi nanti
      'color': const Color(0xFF2F4F4F),
    },
    {
      'title': 'Sapiens',
      'author': 'Yuval Noah Harari',
      'description': 'Sejarah singkat umat manusia dari zaman batu hingga era modern, mengeksplorasi bagaimana Homo sapiens menjadi spesies dominan.',
      'rating': 4.6,
      'reviews': 23456,
      'imageUrl': 'assets/images/1.png', // Kosongkan untuk diisi nanti
      'color': const Color(0xFF556B2F),
    },
    {
      'title': 'Deep Work',
      'author': 'Cal Newport',
      'description': 'Aturan untuk fokus sukses di dunia yang penuh distraksi, mengajarkan bagaimana mengembangkan kemampuan bekerja secara mendalam.',
      'rating': 4.5,
      'reviews': 9876,
      'imageUrl': 'assets/images/1.png', // Kosongkan untuk diisi nanti
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
      'imageUrl': 'assets/images/1.png', // Kosongkan untuk diisi nanti
      'color': const Color(0xFF4B0082),
    },
    {
      'title': 'The Lean Startup',
      'author': 'Eric Ries',
      'description': 'Pendekatan baru untuk membangun dan meluncurkan startup dengan cepat dan efisien melalui iterasi dan pembelajaran.',
      'rating': 4.3,
      'reviews': 7654,
      'imageUrl': 'assets/images/1.png', // Kosongkan untuk diisi nanti
      'color': const Color(0xFFDC143C),
    },
    {
      'title': 'Educated',
      'author': 'Tara Westover',
      'description': 'Memoar yang menginspirasi tentang seorang wanita yang tumbuh di keluarga survivalis dan perjalanannya menuju pendidikan.',
      'rating': 4.6,
      'reviews': 11234,
      'imageUrl': 'assets/images/1.png', // Kosongkan untuk diisi nanti
      'color': const Color(0xFF8B4513),
    },
    {
      'title': 'The 7 Habits',
      'author': 'Stephen Covey',
      'description': 'Tujuh kebiasaan orang yang sangat efektif untuk mencapai kesuksesan pribadi dan profesional.',
      'rating': 4.5,
      'reviews': 14567,
      'imageUrl': 'assets/images/1.png', // Kosongkan untuk diisi nanti
      'color': const Color(0xFF2F4F4F),
    },
    {
      'title': 'Start With Why',
      'author': 'Simon Sinek',
      'description': 'Bagaimana pemimpin hebat menginspirasi semua orang untuk mengambil tindakan dengan memulai dari "mengapa".',
      'rating': 4.4,
      'reviews': 9876,
      'imageUrl': 'assets/images/1.png', // Kosongkan untuk diisi nanti
      'color': const Color(0xFF556B2F),
    },
    {
      'title': 'Mindset',
      'author': 'Carol Dweck',
      'description': 'Psikologi baru tentang kesuksesan yang menjelaskan perbedaan antara fixed mindset dan growth mindset.',
      'rating': 4.3,
      'reviews': 8765,
      'imageUrl': 'assets/images/1.png', // Kosongkan untuk diisi nanti
      'color': const Color(0xFFCC7722),
    },
  ];

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
          'Explore Books',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFFE8C547)),
            onPressed: () {
              // TODO: Implement search
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
              // Top Recommendations Section
              const Text(
                '🌟 Top Recomendations',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Editor's choice of the best books",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              
              // Top Recommendations List
              ...topRecommendations.map((book) => _buildBookCard(book, true)),
              
              const SizedBox(height: 32),
              
              // Popular Books Section
              const Text(
                '🔥 Popular This Week',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'The most widely read book',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              
              // Popular Books Grid/List
              ...popularBooks.map((book) => _buildBookCard(book, false)),
              
              const SizedBox(height: 24),
            ],
          ),
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
              child: (book['imageUrl'] != null && book['imageUrl'].toString().isNotEmpty)
                ? Image.network(
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
                  label: const Text('Tambahkan ke Library'),
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
