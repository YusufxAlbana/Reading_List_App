// lib/views/splash_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_view.dart';
import '../constants/theme_constants.dart'; // Import AppColors

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Kontroler utama untuk seluruh durasi animasi
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Total durasi 2 detik
    );

    // 2. Animasi Logo (Skala & Fade)
    // Berjalan dari 0% - 70% durasi (0 - 1400ms)
    // Menggunakan Kurva 'elasticOut' untuk efek memantul yang modern
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn), // Fade in cepat
    );

    // 3. Animasi Teks (Fade)
    // Berjalan dari 60% - 100% durasi (1200ms - 2000ms)
    // Muncul setelah logo stabil
    _textFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    );

    // Mulai animasi
    _controller.forward();

    // 4. Navigasi ke HomeView setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      // Gunakan 'off' agar pengguna tidak bisa kembali ke Splash Screen
      Get.off(() => HomeView(), transition: Transition.fadeIn);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildLogo() {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Gunakan warna surface dari tema
        color: AppColors.surface,
        // Beri efek 'glow' dengan warna primary
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(
        // Ikon buku yang lebih tematik
        Icons.auto_stories_rounded,
        size: 70,
        // Gunakan warna primary dari tema
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildText() {
    return const Text(
      "Reading List App",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Colors.white, // Teks putih di background gelap
        letterSpacing: 1.5,
        shadows: [
          Shadow(
            color: Colors.black26,
            offset: Offset(1, 1),
            blurRadius: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    // Memberi 'sesuatu' untuk dilihat selagi menunggu 3 detik
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 2800), // Sedikit < 3 detik
      builder: (context, value, child) {
        return SizedBox(
          width: 150,
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: AppColors.surface,
            color: AppColors.primary,
            minHeight: 5,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 5. Gunakan warna background utama aplikasi
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo akan membesar dan fade in
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildLogo(),
              ),
            ),

            const SizedBox(height: 30),

            // Teks akan fade in setelah logo
            FadeTransition(
              opacity: _textFadeAnimation,
              child: _buildText(),
            ),

            const SizedBox(height: 80),

            // Indikator loading opsional
            _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }
}