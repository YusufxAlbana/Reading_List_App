import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reading_controller.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final controller = Get.put(ReadingController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: Text('Reading List'),
          actions: [
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: colorScheme.surface,
                    builder: (ctx) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(ctx).viewInsets.bottom,
                          left: 16,
                          right: 16,
                          top: 20,
                        ),
                        child: SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(ctx).size.height * 0.8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sort',
                                    style: theme.textTheme.titleMedium),
                                const SizedBox(height: 8),
                                Obx(() => Row(
                                      children: [
                                        ChoiceChip(
                                          label: Text('Terbaru'),
                                          selected:
                                              controller.sortOrder.value ==
                                                  'newest',
                                          onSelected: (_) => controller
                                              .sortOrder.value = 'newest',
                                        ),
                                        SizedBox(width: 8),
                                        ChoiceChip(
                                          label: Text('Terlama'),
                                          selected:
                                              controller.sortOrder.value ==
                                                  'oldest',
                                          onSelected: (_) => controller
                                              .sortOrder.value = 'oldest',
                                        ),
                                      ],
                                    )),
                                const SizedBox(height: 16),
                                Text('Filter by tags',
                                    style: theme.textTheme.titleMedium),
                                const SizedBox(height: 8),
                                Obx(() {
                                  final tags = controller.availableTags;
                                  if (tags.isEmpty) {
                                    return Text(
                                        'No tags yet. Create tags below.');
                                  }
                                  return Wrap(
                                    spacing: 8,
                                    children: tags
                                        .map((t) => FilterChip(
                                              label: Text(t),
                                              selected: controller.selectedTags
                                                  .contains(t),
                                              onSelected: (_) => controller
                                                  .toggleSelectedTag(t),
                                            ))
                                        .toList(),
                                  );
                                }),
                                const SizedBox(height: 16),
                                Text('Manage tags',
                                    style: theme.textTheme.titleMedium),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    OutlinedButton(
                                      onPressed: () {
                                        Get.back(); // Tutup bottom sheet
                                        Get.toNamed('/tags'); // Pindah halaman
                                      },
                                      child: Text('Open full Tag manager'),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: _TagManager( // Ini adalah baris (sekitar 106) yang error
                                            controller: controller)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              },
            )
          ],
        ),
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

          const SizedBox(height: 8),
          Divider(indent: 16, endIndent: 16),

          // List items
          Expanded(
            child: Obx(() {
              var items = controller.filteredList;
              if (items.isEmpty) {
                return Center(child: Text('Tidak ditemukan'));
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

                  Widget? tagWidget;
                  if (item.tags.isNotEmpty) {
                    tagWidget = Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 6.0,
                        runSpacing: 4.0,
                        children: item.tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            labelStyle: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            backgroundColor:
                                colorScheme.surfaceContainerHighest.withOpacity(0.5),
                            padding: EdgeInsets.symmetric(horizontal: 6.0),
                            side: BorderSide.none,
                            visualDensity:
                                VisualDensity(horizontal: 0.0, vertical: -4),
                          );
                        }).toList(),
                      ),
                    );
                  }

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(item.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.timeAgo(),
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant
                                    .withOpacity(0.8)),
                          ),
                          if (tagWidget != null) tagWidget,
                        ],
                      ),
                      leading: Checkbox(
                        value: item.isRead,
                        onChanged: (_) => controller.toggleStatus(item.id),
                        activeColor: colorScheme.primary,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () =>
                                Get.toNamed('/edit', arguments: item),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            color: colorScheme.error,
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

// --- BAGIAN YANG HILANG (DIKEMBALIKAN) ---
// Ini adalah definisi Widget
class _TagManager extends StatefulWidget {
  final ReadingController controller;
  const _TagManager({super.key, required this.controller});

  @override
  State<_TagManager> createState() => _TagManagerState();
}
// --- AKHIR BAGIAN YANG HILANG ---


// Ini adalah definisi State (Logika) - yang ini sudah ada sebelumnya
class _TagManagerState extends State<_TagManager> {
  final TextEditingController _newTagController = TextEditingController();
  bool _deleteMode = false;
  final Set<String> _toDelete = {};

  @override
  void dispose() {
    _newTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 4),
        Obx(() {
          final tags = widget.controller.tags;
          if (tags.isEmpty) return Text('No tags defined yet');

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _deleteMode ? 'Select tags to delete' : 'Tags',
                      style: Theme.of(context).textTheme.bodyLarge,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_deleteMode) {
                          _deleteMode = false;
                          _toDelete.clear();
                        } else {
                          _deleteMode = true;
                        }
                      });
                    },
                    child: Text(_deleteMode ? 'Cancel' : 'Delete tags'),
                  )
                ],
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 260),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((t) {
                      final selected = _toDelete.contains(t);
                      return ChoiceChip(
                        label: Text(t),
                        selected: _deleteMode ? selected : false,
                        onSelected: (_) {
                          if (!_deleteMode) return;
                          setState(() {
                            if (selected) {
                              _toDelete.remove(t);
                            } else {
                              _toDelete.add(t);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              if (_deleteMode)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _toDelete.clear();
                              _deleteMode = false;
                            });
                          },
                          child: Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _toDelete.isEmpty
                            ? null
                            : () {
                                widget.controller
                                    .removeTags(_toDelete.toList());
                                setState(() {
                                  _toDelete.clear();
                                  _deleteMode = false;
                                });
                              },
                        child: Text('Delete selected'),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }
}