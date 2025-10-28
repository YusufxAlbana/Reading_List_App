import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/reading_controller.dart';
import 'package:get_storage/get_storage.dart';
import 'views/home_view.dart';
import 'views/add_view.dart';
import 'views/edit_view.dart';
import 'views/tags_view.dart';

void main() async {
  await GetStorage.init();
  Get.put(ReadingController());
  runApp(ReadingListApp());
}

// --- TEMA BARU (PUTIH/HITAM) ---

// 1. Skema Warna Terang (Sesuai permintaan Anda)
const lightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF212121), // Abu-abu sangat gelap (hampir hitam) untuk FAB/Chip
  onPrimary: Colors.white,
  secondary: Colors.grey,
  onSecondary: Colors.white,
  error: Colors.red,
  onError: Colors.white,
  background: Color(0xFFFAFAFA), // "putih nya agak di gelapkan" (Off-white)
  onBackground: Colors.black87, // "tulisannya hitam"
  surface: Colors.white, // "card nya masih putih"
  onSurface: Colors.black87, // Teks di atas card (hitam)
  outlineVariant: Color(0xFFE0E0E0), // "stroke warna hitam dikit" (Abu-abu sangat terang)
);

// 2. Skema Warna Gelap (Netral untuk memperbaiki warna kemerahan)
const darkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFBDBDBD), // Abu-abu terang untuk FAB/Chip
  onPrimary: Colors.black,
  secondary: Colors.grey,
  onSecondary: Colors.black,
  error: Colors.redAccent,
  onError: Colors.white,
  background: Color(0xFF121212), // Background dark mode standar
  onBackground: Colors.white, // Teks putih
  surface: Color(0xFF1E1E1E), // Warna Card (sedikit lebih terang)
  onSurface: Colors.white, // Teks di atas card (putih)
  outlineVariant: Color(0xFF424242), // Stroke abu-abu gelap
);

// --- APLIKASI UTAMA ---

class ReadingListApp extends StatelessWidget {
  const ReadingListApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Light Theme ---
    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: lightScheme,
      scaffoldBackgroundColor: lightScheme.background,
      cardColor: lightScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: lightScheme.surface, // AppBar putih
        elevation: 1,
        foregroundColor: lightScheme.onSurface, // Teks AppBar hitam
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightScheme.primary, // FAB hitam
        foregroundColor: lightScheme.onPrimary, // Ikon FAB putih
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightScheme.surface, // Field input putih
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIconColor: lightScheme.onSurface, // Ikon search hitam
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: lightScheme.surface, // Card putih
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: lightScheme.outlineVariant, // Stroke abu-abu terang
            width: 1.5, // Sedikit lebih tebal agar terlihat
          ),
        ),
      ),
      textTheme: Theme.of(context).textTheme.apply(
            bodyColor: lightScheme.onBackground,
            displayColor: lightScheme.onBackground,
          ),
      chipTheme: ChipThemeData(
        selectedColor: lightScheme.primary, // Chip "Semua" (aktif)
        backgroundColor: lightScheme.surface, // Chip (non-aktif)
        labelStyle: TextStyle(color: lightScheme.onSurface), // Teks chip (hitam)
        secondaryLabelStyle: TextStyle(color: lightScheme.onPrimary), // Teks chip (aktif/putih)
        side: BorderSide(color: lightScheme.outlineVariant), // Border chip
      ),
    );

    // --- Dark Theme ---
    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: darkScheme,
      scaffoldBackgroundColor: darkScheme.background,
      cardColor: darkScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: darkScheme.surface,
        elevation: 1,
        foregroundColor: darkScheme.onSurface,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkScheme.primary,
        foregroundColor: darkScheme.onPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIconColor: darkScheme.onSurfaceVariant,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: darkScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      textTheme: Theme.of(context).textTheme.apply(
            bodyColor: darkScheme.onBackground,
            displayColor: darkScheme.onBackground,
          ),
      chipTheme: ChipThemeData(
        selectedColor: darkScheme.primary,
        backgroundColor: darkScheme.surface,
        labelStyle: TextStyle(color: darkScheme.onSurface),
        secondaryLabelStyle: TextStyle(color: darkScheme.onPrimary),
        side: BorderSide(color: darkScheme.outlineVariant),
      ),
    );

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system, // Akan pilih light/dark sesuai sistem
      theme: lightTheme, // Tema terang kustom kita
      darkTheme: darkTheme, // Tema gelap kustom kita
      home: HomeView(),
      getPages: [
        GetPage(name: '/', page: () => HomeView()),
        GetPage(name: '/tags', page: () => TagsView()),
        GetPage(name: '/add', page: () => AddView()),
        GetPage(name: '/edit', page: () => EditView()),
      ],
    );
  }
}