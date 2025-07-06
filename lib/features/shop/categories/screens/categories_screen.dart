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
    final CategoriesController controller = Get.put(CategoriesController());

    return Scaffold(
      appBar: AppBar(
        title: Text(LangKeys.categories.tr),
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchCategories,
        child: const Column(
          children: [
            _Header(),
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
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                hintText:
                '${LangKeys.search.tr} ${LangKeys.categories.tr.toLowerCase()}...',
                prefixIcon: const Icon(Icons.search, size: 20),
              ),
            ),
          ),
          const SizedBox(width: kDefaultPadding),
          ElevatedButton.icon(
            onPressed: () {
              Get.toNamed(AppRoutes.categoryForm)?.then((result) {
                if (result == true) controller.fetchCategories();
              });
            },
            icon: const Icon(Icons.add),
            label: Text(LangKeys.addNew.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: kDefaultPadding,
                vertical: 14,
              ),
            ),
          ),
        ],
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
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off,
                  size: 60, color: kSecondaryTextColor),
              const SizedBox(height: kDefaultPadding),
              Text(LangKeys.noCategoriesFound.tr,
                  style: Get.textTheme.titleMedium),
            ],
          ),
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < kMobileBreakpoint) {
            return _CategoryListView(categories: controller.filteredCategories);
          } else {
            return _CategoryDesktopTable(
                categories: controller.filteredCategories);
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
    return ListView.separated(
      padding: const EdgeInsets.only(
          left: kDefaultPadding,
          right: kDefaultPadding,
          bottom: kDefaultPadding),
      itemCount: categories.length,
      separatorBuilder: (context, index) =>
      const Divider(height: 1, thickness: 0.1, color: Color(0xFF858585)),
      itemBuilder: (context, index) {
        final category = categories[index];
        final originalCategory =
        controller.categories.firstWhere((c) => c.id == category.id);
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding / 2, vertical: kDefaultPadding),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey.shade100,
            backgroundImage: (category.imageUrl != null &&
                category.imageUrl!.isNotEmpty)
                ? NetworkImage(category.imageUrl!)
                : null,
            child: (category.imageUrl == null || category.imageUrl!.isEmpty)
                ? const Icon(Icons.category_outlined,
                color: kSecondaryTextColor)
                : null,
          ),
          title: Text(
            category.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle:
          category.description != null && category.description!.isNotEmpty
              ? Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              category.description!,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: kPrimaryColor),
                tooltip: LangKeys.edit.tr,
                onPressed: () => Get.toNamed(AppRoutes.categoryForm,
                    arguments: originalCategory)?.then((result) {
                  if (result == true) controller.fetchCategories();
                }),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: kErrorColor),
                tooltip: LangKeys.delete.tr,
                onPressed: () => showConfirmationDialog(
                  title: LangKeys.confirmDelete.tr,
                  message: LangKeys.confirmDeleteCategoryMessage.trParams(
                      {'item': category.name.replaceAll(RegExp(r'—\s*'), '')}),
                  onConfirm: () => controller.deleteCategory(category.id),
                ),
              ),
            ],
          ),
          onTap: () => Get.toNamed(AppRoutes.categoryForm,
              arguments: originalCategory)?.then((result) {
            if (result == true) controller.fetchCategories();
          }),
        );
      },
    );
  }
}

class _CategoryDesktopTable extends StatelessWidget {
  final List<CategoryModel> categories;
  const _CategoryDesktopTable({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(
                  label: Text(LangKeys.image.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text(LangKeys.name.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text(LangKeys.description.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text(LangKeys.actions.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: List.generate(categories.length, (index) {
              final category = categories[index];
              return _buildDataRow(category, Get.find<CategoriesController>());
            }),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(CategoryModel category, CategoriesController controller) {
    final originalCategory =
    controller.categories.firstWhere((c) => c.id == category.id);
    return DataRow(
      cells: [
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
            child: CircleAvatar(
              backgroundColor: kBackgroundColor,
              backgroundImage: (category.imageUrl != null &&
                  category.imageUrl!.isNotEmpty)
                  ? NetworkImage(category.imageUrl!)
                  : null,
              child: (category.imageUrl == null || category.imageUrl!.isEmpty)
                  ? const Icon(Icons.category_outlined,
                  color: kSecondaryTextColor, size: 20)
                  : null,
            ),
          ),
        ),
        DataCell(SizedBox(width: 250, child: Text(category.name))),
        DataCell(
          SizedBox(
            width: 300,
            child: Text(
              category.description ?? '',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                color: kPrimaryColor,
                tooltip: LangKeys.edit.tr,
                onPressed: () => Get.toNamed(AppRoutes.categoryForm,
                    arguments: originalCategory)?.then((result) {
                  if (result == true) controller.fetchCategories();
                }),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: kErrorColor,
                tooltip: LangKeys.delete.tr,
                onPressed: () => showConfirmationDialog(
                  title: LangKeys.confirmDelete.tr,
                  message: LangKeys.confirmDeleteCategoryMessage.trParams(
                      {'item': category.name.replaceAll(RegExp(r'—\s*'), '')}),
                  onConfirm: () => controller.deleteCategory(category.id),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
