import 'package:flutter/material.dart'; // TAMBAH INI
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  final GetStorage _box = GetStorage();
  
  // Settings variables
  final RxBool _darkMode = true.obs;
  final RxString _language = 'English'.obs;
  final RxBool _notifications = true.obs;
  final RxBool _autoSync = false.obs;
  final RxInt _fontSize = 14.obs;
  final RxString _themeColor = 'Default'.obs;

  // Getters
  bool get darkMode => _darkMode.value;
  String get language => _language.value;
  bool get notifications => _notifications.value;
  bool get autoSync => _autoSync.value;
  int get fontSize => _fontSize.value;
  String get themeColor => _themeColor.value;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  // Load settings from local storage
  void _loadSettings() {
    _darkMode.value = _box.read('darkMode') ?? true;
    _language.value = _box.read('language') ?? 'English';
    _notifications.value = _box.read('notifications') ?? true;
    _autoSync.value = _box.read('autoSync') ?? false;
    _fontSize.value = _box.read('fontSize') ?? 14;
    _themeColor.value = _box.read('themeColor') ?? 'Default';
  }

  // Save settings to local storage
  void _saveSettings() {
    _box.write('darkMode', _darkMode.value);
    _box.write('language', _language.value);
    _box.write('notifications', _notifications.value);
    _box.write('autoSync', _autoSync.value);
    _box.write('fontSize', _fontSize.value);
    _box.write('themeColor', _themeColor.value);
  }

  // Update methods
  void toggleDarkMode(bool value) {
    _darkMode.value = value;
    _saveSettings();
  }

  void updateLanguage(String value) {
    _language.value = value;
    _saveSettings();
  }

  void toggleNotifications(bool value) {
    _notifications.value = value;
    _saveSettings();
  }

  void toggleAutoSync(bool value) {
    _autoSync.value = value;
    _saveSettings();
  }

  void updateFontSize(int value) {
    _fontSize.value = value;
    _saveSettings();
  }

  void updateThemeColor(String value) {
    _themeColor.value = value;
    _saveSettings();
  }

  // Reset to default settings
  void resetToDefaults() {
    _darkMode.value = true;
    _language.value = 'English';
    _notifications.value = true;
    _autoSync.value = false;
    _fontSize.value = 14;
    _themeColor.value = 'Default';
    _saveSettings();
  }

  // Export/Import data methods
  Future<void> exportData() async {
    // Implement data export logic
    Get.snackbar(
      'Export Successful',
      'Your data has been exported',
      backgroundColor: const Color(0xFFE8C547),
      colorText: Colors.black,
    );
  }

  Future<void> importData() async {
    // Implement data import logic
    Get.snackbar(
      'Import Successful',
      'Your data has been imported',
      backgroundColor: const Color(0xFFE8C547),
      colorText: Colors.black,
    );
  }

  // Clear all data
  void clearAllData() {
    Get.defaultDialog(
      title: "Clear All Data",
      titleStyle: const TextStyle(color: Colors.white),
      backgroundColor: const Color(0xFF2C3E45),
      content: const Text(
        "This will delete all your books and settings. This action cannot be undone.",
        style: TextStyle(color: Colors.white70),
      ),
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.black,
      cancelTextColor: const Color(0xFFE8C547),
      buttonColor: const Color(0xFFE8C547),
      onConfirm: () {
        _box.erase();
        Get.back();
        Get.offAllNamed('/');
        Get.snackbar(
          'Data Cleared',
          'All data has been deleted',
          backgroundColor: const Color(0xFFE8C547),
          colorText: Colors.black,
        );
      },
    );
  }
}