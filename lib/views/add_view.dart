import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reading_controller.dart';

class AddView extends StatelessWidget {
  final controller = Get.find<ReadingController>();
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambahkan Bacaan')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: textController,
              decoration: InputDecoration(labelText: 'Judul Bacaan'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  controller.addItem(textController.text);
                  Get.back();
                }
              },
              child: Text('Simpan'),
            )
          ],
        ),
      ),
    );
  }
}
