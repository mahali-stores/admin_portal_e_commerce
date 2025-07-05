import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/lang_keys.dart';

// A generic class to hold item data for the dialog
class SelectableItem {
  final String id;
  final String name;
  SelectableItem({required this.id, required this.name});
}

void showItemSelectionDialog({
  required BuildContext context,
  required String title,
  required List<SelectableItem> allItems,
  required List<String> initiallySelectedIds,
  required Function(List<String> selectedIds) onConfirm,
}) {
  Get.dialog(
    _ItemSelectionContent(
      title: title,
      allItems: allItems,
      initiallySelectedIds: initiallySelectedIds,
      onConfirm: onConfirm,
    ),
  );
}

class _ItemSelectionContent extends StatefulWidget {
  final String title;
  final List<SelectableItem> allItems;
  final List<String> initiallySelectedIds;
  final Function(List<String> selectedIds) onConfirm;

  const _ItemSelectionContent({
    required this.title,
    required this.allItems,
    required this.initiallySelectedIds,
    required this.onConfirm,
  });

  @override
  State<_ItemSelectionContent> createState() => _ItemSelectionContentState();
}

class _ItemSelectionContentState extends State<_ItemSelectionContent> {
  late RxList<String> _selectedIds;
  late RxList<SelectableItem> _filteredItems;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedIds = RxList<String>.from(widget.initiallySelectedIds);
    _filteredItems = RxList<SelectableItem>.from(widget.allItems);
    _searchController.addListener(_filter);
  }

  void _filter() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredItems.value = widget.allItems;
    } else {
      _filteredItems.value = widget.allItems
          .where((item) => item.name.toLowerCase().contains(query))
          .toList();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: LangKeys.search.tr,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(
                    () => ListView.builder(
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    return Obx(
                          () => CheckboxListTile(
                        title: Text(item.name),
                        value: _selectedIds.contains(item.id),
                        onChanged: (bool? selected) {
                          if (selected == true) {
                            _selectedIds.add(item.id);
                          } else {
                            _selectedIds.remove(item.id);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(LangKeys.cancel.tr),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(List<String>.from(_selectedIds));
            Get.back();
          },
          child: Text(LangKeys.save.tr),
        ),
      ],
    );
  }
}