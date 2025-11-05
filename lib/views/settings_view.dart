import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends StatelessWidget {
  SettingsView({super.key}); // HAPUS 'const' DARI CONSTRUCTOR

  final SettingsController settingsController = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E45),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E45),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE8C547)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Appearance Section
              _buildSectionHeader('Appearance'),
              const SizedBox(height: 12),
              Obx(() => _buildSettingItem(
                icon: Icons.dark_mode,
                title: 'Mode Gelap',
                subtitle: 'Gunakan tema gelap',
                trailing: Switch(
                  value: settingsController.darkMode,
                  activeThumbColor: const Color(0xFFE8C547),
                  onChanged: settingsController.toggleDarkMode,
                ),
              )),
              
              const SizedBox(height: 12),
              _buildSettingOption(
                icon: Icons.palette,
                title: 'Warna Tema',
                subtitle: 'Ganti warna aksen',
                onTap: () {
                  Get.snackbar(
                    'Segera hadir',
                    'Fitur warna tema sedang dikembangkan',
                    backgroundColor: const Color(0xFFE8C547),
                    colorText: Colors.black,
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Preferences Section
              _buildSectionHeader('Preferences'),
              const SizedBox(height: 12),
              Obx(() => _buildSettingItem(
                icon: Icons.notifications,
                title: 'Notifikasi',
                subtitle: 'Terima pengingat bacaan',
                trailing: Switch(
                  value: settingsController.notifications,
                  activeThumbColor: const Color(0xFFE8C547),
                  onChanged: settingsController.toggleNotifications,
                ),
              )),
              
              const SizedBox(height: 12),
              _buildSettingOption(
                icon: Icons.language,
                title: 'Bahasa',
                subtitle: 'Bahasa aplikasi',
                onTap: () {
                  Get.snackbar(
                    'Segera hadir',
                    'Fitur bahasa sedang dikembangkan',
                    backgroundColor: const Color(0xFFE8C547),
                    colorText: Colors.black,
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Data Section
              _buildSectionHeader('Data'),
              const SizedBox(height: 12),
              _buildSettingOption(
                icon: Icons.backup,
                title: 'Backup Data',
                subtitle: 'Export your reading list',
                onTap: settingsController.exportData,
              ),
              
              const SizedBox(height: 12),
              _buildSettingOption(
                icon: Icons.restore,
                title: 'Restore Data',
                subtitle: 'Import your reading list',
                onTap: settingsController.importData,
              ),
              
              const SizedBox(height: 12),
              _buildSettingOption(
                icon: Icons.delete_forever,
                title: 'Clear All Data',
                subtitle: 'Hapus semua bacaan dan pengaturan',
                onTap: settingsController.clearAllData,
                isDestructive: true,
              ),
              
              const SizedBox(height: 24),
              
              // Reset Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: settingsController.resetToDefaults,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D5159),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restore, size: 20),
                      SizedBox(width: 8),
                      Text('Reset ke Pengaturan Default'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFE8C547),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3D5159),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE8C547), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildSettingOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3D5159),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFFE8C547),
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDestructive ? Colors.red.withAlpha((0.7 * 255).round()) : Colors.white70,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDestructive ? Colors.red : const Color(0xFFE8C547),
        ),
        onTap: onTap,
      ),
    );
  }
}