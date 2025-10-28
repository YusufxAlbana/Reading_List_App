import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reading_controller.dart';
import '../models/reading_item.dart';

class EditView extends StatelessWidget {
  EditView({Key? key}) : super(key: key) {
    item = Get.arguments;
  }

  final controller = Get.find<ReadingController>();
  late final ReadingItem item;

  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    textController.text = item.title;

    return Scaffold(
      appBar: AppBar(title: Text('Edit Bacaan')),
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
                controller.updateItem(item.id, textController.text);
                Get.back();
              },
              child: Text('Update'),
            )
          ],
        ),
      ),
    );
  }
}
