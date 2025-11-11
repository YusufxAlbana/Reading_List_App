import 'package:flutter/material.dart';
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
import 'views/splash_view.dart';
import 'views/explore_view.dart';

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
          name: '/explore',
          page: () => ExploreView(),
          transition: Transition.rightToLeft,
        ),
      ],
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize GetStorage
  await GetStorage.init();
  
  // Initialize Controller
  Get.put(ReadingController());
  
  runApp(const ReadingListApp());
}
