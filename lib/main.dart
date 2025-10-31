import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controllers/reading_controller.dart';
import 'views/home_view.dart';
import 'views/add_view.dart';
import 'views/edit_view.dart';
import 'views/tags_view.dart';
import 'views/all_books_view.dart';
import 'views/splash_view.dart'; // ⬅️ Tambahkan ini

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(ReadingController());
  runApp(const ReadingListApp());
}

// --- APLIKASI UTAMA ---
class ReadingListApp extends StatelessWidget {
  const ReadingListApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Tema dark elegan
    final libraryTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF2C3E45),
      primaryColor: const Color(0xFFE8C547),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFE8C547),
        secondary: Color(0xFF3D5159),
        surface: Color(0xFF3D5159),
        error: Colors.redAccent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2C3E45),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF3D5159),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: libraryTheme,
      darkTheme: libraryTheme,

      // ⬇️ SplashView jadi halaman pertama
      home: const SplashView(),

      // Routing GetX
      getPages: [
        GetPage(name: '/', page: () => HomeView()),
        GetPage(name: '/tags', page: () => TagsView()),
        GetPage(name: '/add', page: () => AddView()),
        GetPage(name: '/edit', page: () => EditView()),
        GetPage(name: '/all-books', page: () => AllBooksView()),
      ],
    );
  }
}
