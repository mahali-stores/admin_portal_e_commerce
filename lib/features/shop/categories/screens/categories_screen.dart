import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/utils/app_routes.dart';
import '../../models/category_model.dart';
import '../controllers/categories_controller.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CategoriesController()); // Ensure controller is initialized

    return Scaffold(
      appBar: AppBar(
        title: Text(LangKeys.categories.tr),
        backgroundColor: kSurfaceColor,
        elevation: 0,
        foregroundColor: kTextColor,
      ),
      body: const Padding(
        padding: EdgeInsets.all(kDefaultPadding),
        child: Column(
          children: [
            _Header(),
            SizedBox(height: kDefaultPadding),
            Expanded(child: _CategoryDataView()),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final CategoriesController controller = Get.find();
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) => controller.searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: LangKeys.search.tr,
                  prefixIcon: const Icon(Icons.search, size: 20),
                ),
              ),
            ),
            const SizedBox(width: kDefaultPadding),
            ElevatedButton.icon(
              onPressed: () {
                Get.toNamed(AppRoutes.categoryForm)?.then((result) {
                  if (result == true)
                    Get.find<CategoriesController>().fetchCategories();
                });
              },
              icon: const Icon(Icons.add),
              label: Text(LangKeys.addNew.tr),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDataView extends StatelessWidget {
  const _CategoryDataView();

  @override
  Widget build(BuildContext context) {
    final CategoriesController controller = Get.find();
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.filteredCategories.isEmpty) {
        return Center(child: Text(LangKeys.noCategoriesFound.tr));
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < kMobileBreakpoint) {
            // Mobile Card View
            return ListView.builder(
              itemCount: controller.filteredCategories.length,
              itemBuilder: (context, index) => _CategoryMobileCard(
                category: controller.filteredCategories[index],
              ),
            );
          } else {
            // Desktop Data Table View
            return const _CategoryDesktopTable();
          }
        },
      );
    });
  }
}

class _CategoryMobileCard extends StatelessWidget {
  final CategoryModel category;

  const _CategoryMobileCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoriesController>();
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kBackgroundColor,
          child: category.imageUrl != null && category.imageUrl!.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    category.imageUrl!,
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                  ),
                )
              : const Icon(Icons.category, color: kSecondaryTextColor),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Parent: ${controller.getParentCategoryName(category.parentCategoryId)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () =>
                  Get.toNamed(
                    AppRoutes.categoryForm,
                    arguments: category,
                  )?.then((result) {
                    if (result == true) controller.fetchCategories();
                  }),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: kErrorColor),
              onPressed: () => Get.defaultDialog(
                title: LangKeys.confirmDelete.tr,
                middleText: 'Delete "${category.name.replaceAll('— ', '')}"?',
                onConfirm: () {
                  controller.deleteCategory(category.id);
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDesktopTable extends StatelessWidget {
  const _CategoryDesktopTable();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoriesController>();
    return Card(
      elevation: 0,
      child: SizedBox(
        width: double.infinity,
        child: PaginatedDataTable(
          header: Text(LangKeys.categories.tr),
          rowsPerPage: 15,
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Parent Category')),
            DataColumn(label: Text('Description')),
            DataColumn(label: Text('Actions')),
          ],
          source: _CategoryDataSource(controller: controller),
        ),
      ),
    );
  }
}

class _CategoryDataSource extends DataTableSource {
  final CategoriesController controller;

  _CategoryDataSource({required this.controller});

  @override
  DataRow? getRow(int index) {
    if (index >= controller.filteredCategories.length) return null;
    final category = controller.filteredCategories[index];

    return DataRow(
      cells: [
        DataCell(Text(category.name)),
        DataCell(
          Text(controller.getParentCategoryName(category.parentCategoryId)),
        ),
        DataCell(
          Text(category.description ?? '', overflow: TextOverflow.ellipsis),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () =>
                    Get.toNamed(
                      AppRoutes.categoryForm,
                      arguments: category,
                    )?.then((result) {
                      if (result == true) controller.fetchCategories();
                    }),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: kErrorColor),
                onPressed: () => Get.defaultDialog(
                  title: LangKeys.confirmDelete.tr,
                  middleText: 'Delete "${category.name.replaceAll('— ', '')}"?',
                  onConfirm: () {
                    controller.deleteCategory(category.id);
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => controller.filteredCategories.length;

  @override
  int get selectedRowCount => 0;
}
