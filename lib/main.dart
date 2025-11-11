import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'constants/theme_constants.dart';
import 'controllers/reading_controller.dart';
import 'views/home_view.dart';
import 'views/add_view.dart';
import 'views/edit_view.dart';
import 'views/tags_view.dart';
import 'views/all_books_view.dart';
import 'views/read_books_view.dart';
import 'views/splash_view.dart'; // ⬅️ Tambahkan ini
import 'package:reading_list_app/views/settings_view.dart'; // TAMBAH INI

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAhK-Lw_clLeIc6epAKIfWmA_G4VoNqUrk',
        appId: '1:226685690681:android:3b15c8bebec43d7fa43ee8',
        messagingSenderId: '226685690681',
        projectId: 'reading-list-app-8dfe9',
      ),
    );
    print("Firebase Terhubung ke:");
    print("API Key: ${Firebase.app().options.apiKey}");
    print("Project ID: ${Firebase.app().options.projectId}");
    
    // Initialize GetStorage
    await GetStorage.init();
    
    // Initialize Controller
    Get.put(ReadingController());
    
    runApp(const ReadingListApp());
  } catch (e) {
    debugPrint('Error initializing app: $e');
    // Implement proper error handling
  }
}

// --- APLIKASI UTAMA ---
class ReadingListApp extends StatelessWidget {
  const ReadingListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reading List App',
      themeMode: ThemeMode.system, // Let system decide theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      defaultTransition: Transition.fade,
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => SplashView()),
        GetPage(
          name: '/', 
          page: () => HomeView(),
          transition: Transition.fadeIn
        ),
        GetPage(
          name: '/tags', 
          page: () => TagsView(),
          transition: Transition.rightToLeft
        ),
        GetPage(
          name: '/add', 
          page: () => AddView(),
          transition: Transition.rightToLeft
        ),
        GetPage(
          name: '/edit', 
          page: () => EditView(),
          transition: Transition.rightToLeft
        ),
        GetPage(
          name: '/all-books', 
          page: () => AllBooksView(),
          transition: Transition.rightToLeft
        ),
        GetPage(
          name: '/read-books',
          page: () => ReadBooksView(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/settings', 
          page: () => SettingsView(),
          transition: Transition.rightToLeft
        ),
      ],
    );
  }
}
