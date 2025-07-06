import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/shared_widgets/confirmation_dialog.dart';
import '../../../../core/utils/app_routes.dart';
import '../../brands/controllers/brands_controller.dart';
import '../../categories/controllers/categories_controller.dart';
import '../../models/product_model.dart';
import '../controllers/products_controller.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProductsController());
    Get.put(BrandsController());
    Get.put(CategoriesController());

    return Scaffold(
      appBar: AppBar(
        title: Text(LangKeys.products.tr),
      ),
      body: RefreshIndicator(
        onRefresh: () => Get.find<ProductsController>().fetchProducts(),
        child: const Column(
          children: [
            _Header(),
            Expanded(child: _ProductDataView()),
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
    final ProductsController controller = Get.find();
    final BrandsController brandsController = Get.find();
    final CategoriesController categoriesController = Get.find();

    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => controller.searchQuery.value = value,
                  decoration: InputDecoration(
                    hintText: '${LangKeys.search.tr} ${LangKeys.products.tr.toLowerCase()}...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: kDefaultPadding),
              ElevatedButton.icon(
                onPressed: () {
                  Get.toNamed(AppRoutes.productForm)?.then((result) {
                    if (result == true) controller.fetchProducts();
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
          const SizedBox(height: kDefaultPadding),
          Obx(
                () => Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    hint: Text(LangKeys.allBrands.tr),
                    value: controller.filterByBrandId.value,
                    onChanged: (value) =>
                    controller.filterByBrandId.value = value,
                    items: [
                      DropdownMenuItem<String>(
                          value: null, child: Text(LangKeys.allBrands.tr)),
                      ...brandsController.allBrands.map((b) =>
                          DropdownMenuItem(value: b.id, child: Text(b.name))),
                    ],
                  ),
                ),
                const SizedBox(width: kDefaultPadding),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    hint: Text(LangKeys.allCategories.tr),
                    value: controller.filterByCategoryId.value,
                    onChanged: (value) =>
                    controller.filterByCategoryId.value = value,
                    items: [
                      DropdownMenuItem<String>(
                          value: null, child: Text(LangKeys.allCategories.tr)),
                      ...categoriesController.flattenedCategoriesForDisplay
                          .map((c) =>
                          DropdownMenuItem(value: c.id, child: Text(c.name))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductDataView extends StatelessWidget {
  const _ProductDataView();

  @override
  Widget build(BuildContext context) {
    final ProductsController controller = Get.find();
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.filteredProducts.isEmpty) {
        return Center(
            child: Text(LangKeys.noProductsFound.tr,
                style: Get.textTheme.titleMedium));
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < kMobileBreakpoint) {
            return _ProductListView(products: controller.filteredProducts);
          } else {
            return _ProductDesktopTable(products: controller.filteredProducts);
          }
        },
      );
    });
  }
}

class _ProductListView extends StatelessWidget {
  final List<ProductModel> products;
  const _ProductListView({required this.products});

  @override
  Widget build(BuildContext context) {
    final ProductsController controller = Get.find();
    return ListView.separated(
      padding: const EdgeInsets.all(kDefaultPadding),
      itemCount: products.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding / 2, vertical: kDefaultPadding),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(kDefaultRadius / 2),
            child: product.imageUrls.isNotEmpty
                ? Image.network(product.imageUrls.first,
                width: 56, height: 56, fit: BoxFit.cover)
                : Container(
                width: 56,
                height: 56,
                color: kBackgroundColor,
                child: const Icon(Icons.shopping_bag_outlined,
                    color: kSecondaryTextColor)),
          ),
          title: Text(product.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(product.brandName ?? LangKeys.noBrand.tr,
              style:
              const TextStyle(color: kSecondaryTextColor, fontSize: 12)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: kPrimaryColor),
                onPressed: () => Get.toNamed(AppRoutes.productForm,
                    arguments: product)?.then((result) {
                  if (result == true) controller.fetchProducts();
                }),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: kErrorColor),
                onPressed: () => showConfirmationDialog(
                  title: LangKeys.confirmDelete.tr,
                  message: LangKeys.confirmDeleteItem.trParams({'item': product.name}),
                  onConfirm: () => controller.deleteProduct(product.id),
                ),
              ),
            ],
          ),
          onTap: () => Get.toNamed(AppRoutes.productForm,
              arguments: product)?.then((result) {
            if (result == true) controller.fetchProducts();
          }),
        );
      },
    );
  }
}

class _ProductDesktopTable extends StatelessWidget {
  final List<ProductModel> products;
  const _ProductDesktopTable({required this.products});

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
                  label: Text(LangKeys.productImage.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text(LangKeys.name.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text(LangKeys.brand.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text(LangKeys.featured.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text(LangKeys.actions.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: List.generate(products.length, (index) {
              final product = products[index];
              return _buildDataRow(product, Get.find<ProductsController>());
            }),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(ProductModel product, ProductsController controller) {
    return DataRow(
      cells: [
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kDefaultRadius / 2),
              child: product.imageUrls.isNotEmpty
                  ? Image.network(product.imageUrls.first,
                  width: 40, height: 40, fit: BoxFit.cover)
                  : Container(
                  width: 40,
                  height: 40,
                  color: kBackgroundColor,
                  child: const Icon(Icons.image_not_supported_outlined,
                      size: 20, color: kSecondaryTextColor)),
            ),
          ),
        ),
        DataCell(Text(product.name)),
        DataCell(Text(product.brandName ?? LangKeys.noBrand.tr)),
        DataCell(
          product.isFeatured
              ? const Icon(Icons.check_circle, color: kAccentColor)
              : const Icon(Icons.cancel_outlined, color: kSecondaryTextColor),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: kPrimaryColor),
                onPressed: () => Get.toNamed(AppRoutes.productForm,
                    arguments: product)?.then((result) {
                  if (result == true) controller.fetchProducts();
                }),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: kErrorColor),
                onPressed: () => showConfirmationDialog(
                  title: LangKeys.confirmDelete.tr,
                  message: LangKeys.confirmDeleteItem.trParams({'item': product.name}),
                  onConfirm: () => controller.deleteProduct(product.id),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
