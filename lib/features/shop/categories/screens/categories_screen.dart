import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/shared_widgets/confirmation_dialog.dart';
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
      ),
      body: RefreshIndicator(
        onRefresh: () => Get.find<CategoriesController>().fetchCategories(),
        child: const Padding(
          padding: EdgeInsets.all(kDefaultPadding),
          child: Column(
            children: [
              _Header(),
              SizedBox(height: kDefaultPadding),
              Expanded(child: _CategoryDataView()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(AppRoutes.categoryForm)?.then((result) {
            if (result == true) {
              Get.find<CategoriesController>().fetchCategories();
            }
          });
        },
        child: const Icon(Icons.add),
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
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: TextField(
          onChanged: (value) => controller.searchQuery.value = value,
          decoration: InputDecoration(
            hintText: '${LangKeys.search.tr}...',
            prefixIcon: const Icon(Icons.search, size: 20),
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: kDefaultPadding),
          ),
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
            return _CategoryListView(categories: controller.filteredCategories);
          } else {
            return const _CategoryDesktopTable();
          }
        },
      );
    });
  }
}

class _CategoryListView extends StatelessWidget {
  final List<CategoryModel> categories;
  const _CategoryListView({required this.categories});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoriesController>();
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: kBackgroundColor,
              backgroundImage: (category.imageUrl != null && category.imageUrl!.isNotEmpty)
                  ? NetworkImage(category.imageUrl!)
                  : null,
              child: (category.imageUrl == null || category.imageUrl!.isEmpty)
                  ? const Icon(Icons.category_outlined, color: kSecondaryTextColor)
                  : null,
            ),
            title: Text(category.name),
            subtitle: Text(
              'Parent: ${controller.getParentCategoryName(category.parentCategoryId)}',
              style: context.textTheme.bodySmall,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: kPrimaryColor),
                  onPressed: () => Get.toNamed(AppRoutes.categoryForm, arguments: category)
                      ?.then((result) {
                    if (result == true) controller.fetchCategories();
                  }),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: kErrorColor),
                  onPressed: () => showConfirmationDialog(
                    title: LangKeys.confirmDelete.tr,
                    message: 'Delete "${category.name.replaceAll('— ', '')}"? This will also delete all sub-categories.',
                    onConfirm: () => controller.deleteCategory(category.id),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryDesktopTable extends StatelessWidget {
  const _CategoryDesktopTable();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoriesController>();
    return Card(
      clipBehavior: Clip.antiAlias,
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
    final originalCategory = controller.categories.firstWhere((c) => c.id == category.id);

    return DataRow(
      cells: [
        DataCell(Text(category.name)), // Name with hierarchy indicator
        DataCell(Text(controller.getParentCategoryName(category.parentCategoryId))),
        DataCell(Text(category.description ?? '', overflow: TextOverflow.ellipsis)),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: kPrimaryColor),
                tooltip: LangKeys.edit.tr,
                onPressed: () => Get.toNamed(AppRoutes.categoryForm, arguments: originalCategory)
                    ?.then((result) {
                  if (result == true) controller.fetchCategories();
                }),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: kErrorColor),
                tooltip: LangKeys.delete.tr,
                onPressed: () => showConfirmationDialog(
                  title: LangKeys.confirmDelete.tr,
                  message: 'Delete "${category.name.replaceAll('— ', '')}"? This will also delete all sub-categories.',
                  onConfirm: () => controller.deleteCategory(category.id),
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
