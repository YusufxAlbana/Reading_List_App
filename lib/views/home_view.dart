import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reading_controller.dart';

class HomeView extends StatelessWidget {
  final controller = Get.put(ReadingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reading List'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add'),
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Cari judul",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (v) => controller.searchQuery.value = v,
            ),
          ),

          // Filter buttons
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: Text("Semua"),
                selected: controller.filterStatus.value == 'all',
                onSelected: (_) => controller.filterStatus.value = 'all',
              ),
              SizedBox(width: 8),
              ChoiceChip(
                label: Text("Belum"),
                selected: controller.filterStatus.value == 'unread',
                onSelected: (_) => controller.filterStatus.value = 'unread',
              ),
              SizedBox(width: 8),
              ChoiceChip(
                label: Text("Sudah"),
                selected: controller.filterStatus.value == 'read',
                onSelected: (_) => controller.filterStatus.value = 'read',
              ),
            ],
          )),

          const SizedBox(height: 10),

          // List items
          Expanded(
            child: Obx(() {
              var items = controller.filteredList;
              if (items.isEmpty) {
                return Center(child: Text('Tidak ditemukan'));
              }
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(item.title),
                      leading: Checkbox(
                        value: item.isRead,
                        onChanged: (_) => controller.toggleStatus(item.id),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => Get.toNamed('/edit', arguments: item),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => controller.deleteItem(item.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
