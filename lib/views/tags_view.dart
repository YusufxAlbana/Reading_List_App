import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reading_controller.dart';

class TagsView extends StatelessWidget {
  TagsView({Key? key}) : super(key: key);

  final controller = Get.find<ReadingController>();
  final TextEditingController _newTagController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Tags')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newTagController,
                    decoration: InputDecoration(labelText: 'New tag'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final t = _newTagController.text.trim();
                    if (t.isNotEmpty) {
                      controller.addTag(t);
                      _newTagController.clear();
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                final tags = controller.tags;
                if (tags.isEmpty) return Center(child: Text('No tags yet'));

                return _TagList(tags: tags.toList(), controller: controller);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagList extends StatefulWidget {
  final List<String> tags;
  final ReadingController controller;
  const _TagList({Key? key, required this.tags, required this.controller})
      : super(key: key);

  @override
  State<_TagList> createState() => _TagListState();
}

class _TagListState extends State<_TagList> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: widget.tags.length,
            itemBuilder: (ctx, i) {
              final t = widget.tags[i];
              return Card(
                // Warna & border card otomatis dari CardTheme
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: CheckboxListTile(
                  // Warna teks otomatis dari tema
                  title: Text(t),
                  value: _selected.contains(t),
                  onChanged: (v) {
                    setState(() {
                      if (v == true)
                        _selected.add(t);
                      else
                        _selected.remove(t);
                    });
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _selected.isEmpty
                      ? null
                      : () {
                          setState(() => _selected.clear());
                        },
                  child: Text('Clear selection'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _selected.isEmpty
                    ? null
                    : () {
                        widget.controller.removeTags(_selected.toList());
                        final removed = _selected.toList();
                        setState(() => _selected.clear());
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Deleted ${removed.length} tag(s)')));
                      },
                child: Text('Delete selected'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}