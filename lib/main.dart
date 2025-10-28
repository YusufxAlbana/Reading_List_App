import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'views/home_view.dart';
import 'views/add_view.dart';
import 'views/edit_view.dart';

void main() async {
  await GetStorage.init();
  runApp(ReadingListApp());
}

class ReadingListApp extends StatelessWidget {
  const ReadingListApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
      ),
      home: HomeView(),
      getPages: [
        GetPage(name: '/', page: () => HomeView()),
        GetPage(name: '/add', page: () => AddView()),
        GetPage(name: '/edit', page: () => EditView()),
      ],
    );
  }
}
