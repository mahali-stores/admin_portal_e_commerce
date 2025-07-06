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
        child: const Padding(
          padding: EdgeInsets.all(kDefaultPadding),
          child: Column(
            children: [
              _Header(),
              SizedBox(height: kDefaultPadding),
              Expanded(child: _ProductDataView()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(AppRoutes.productForm)?.then((result) {
            if (result == true) Get.find<ProductsController>().fetchProducts();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Header with Filters and Actions
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final ProductsController controller = Get.find();
    final BrandsController brandsController = Get.find();
    final CategoriesController categoriesController = Get.find();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: '${LangKeys.search.tr} ${LangKeys.products.tr}...',
                prefixIcon: const Icon(Icons.search, size: 20),
              ),
            ),
            const SizedBox(height: kDefaultPadding),
            Obx(
                  () => Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      hint: Text('All ${LangKeys.brands.tr}'),
                      value: controller.filterByBrandId.value,
                      onChanged: (value) => controller.filterByBrandId.value = value,
                      items: [
                        DropdownMenuItem<String>(value: null, child: Text('All ${LangKeys.brands.tr}')),
                        ...brandsController.allBrands.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))),
                      ],
                    ),
                  ),
                  const SizedBox(width: kDefaultPadding),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      hint: Text('All ${LangKeys.categories.tr}'),
                      value: controller.filterByCategoryId.value,
                      onChanged: (value) => controller.filterByCategoryId.value = value,
                      items: [
                        DropdownMenuItem<String>(value: null, child: Text('All ${LangKeys.categories.tr}')),
                        // Use the flattened list for hierarchy display in dropdown
                        ...categoriesController.flattenedCategoriesForDisplay.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Responsive Data View
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
        return Center(child: Text(LangKeys.noProductsFound.tr));
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

// Mobile List View
class _ProductListView extends StatelessWidget {
  final List<ProductModel> products;
  const _ProductListView({required this.products});

  @override
  Widget build(BuildContext context) {
    final ProductsController controller = Get.find();
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(kDefaultRadius / 2),
              child: product.imageUrls.isNotEmpty
                  ? Image.network(product.imageUrls.first, width: 56, height: 56, fit: BoxFit.cover)
                  : Container(width: 56, height: 56, color: kBackgroundColor, child: const Icon(Icons.shopping_bag_outlined, color: kSecondaryTextColor)),
            ),
            title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(product.brandName ?? 'No Brand', style: const TextStyle(color: kSecondaryTextColor, fontSize: 12)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: kPrimaryColor),
                  onPressed: () => Get.toNamed(AppRoutes.productForm, arguments: product)?.then((result) {
                    if (result == true) controller.fetchProducts();
                  }),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: kErrorColor),
                  onPressed: () => showConfirmationDialog(
                    title: LangKeys.confirmDelete.tr,
                    message: 'Delete "${product.name}"?',
                    onConfirm: () => controller.deleteProduct(product.id),
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

// Desktop Data Table
class _ProductDesktopTable extends StatelessWidget {
  final List<ProductModel> products;
  const _ProductDesktopTable({required this.products});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: double.infinity,
        child: PaginatedDataTable(
          header: Text(LangKeys.products.tr),
          rowsPerPage: 10,
          columns: const [
            DataColumn(label: Text('Image')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Brand')),
            DataColumn(label: Text('Featured')),
            DataColumn(label: Text('Actions')),
          ],
          source: _ProductsDataSource(products: products),
        ),
      ),
    );
  }
}

// Data Source for PaginatedDataTable
class _ProductsDataSource extends DataTableSource {
  final List<ProductModel> products;
  _ProductsDataSource({required this.products});

  @override
  DataRow? getRow(int index) {
    if (index >= products.length) return null;
    final product = products[index];
    final controller = Get.find<ProductsController>();

    return DataRow(
      cells: [
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kDefaultRadius / 2),
              child: product.imageUrls.isNotEmpty
                  ? Image.network(product.imageUrls.first, width: 40, height: 40, fit: BoxFit.cover)
                  : Container(width: 40, height: 40, color: kBackgroundColor, child: const Icon(Icons.image_not_supported_outlined, size: 20, color: kSecondaryTextColor)),
            ),
          ),
        ),
        DataCell(Text(product.name)),
        DataCell(Text(product.brandName ?? 'N/A')),
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
                onPressed: () => Get.toNamed(AppRoutes.productForm, arguments: product)?.then((result) {
                  if (result == true) controller.fetchProducts();
                }),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: kErrorColor),
                onPressed: () => showConfirmationDialog(
                  title: LangKeys.confirmDelete.tr,
                  message: 'Are you sure you want to delete "${product.name}"?',
                  onConfirm: () => controller.deleteProduct(product.id),
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
  int get rowCount => products.length;
  @override
  int get selectedRowCount => 0;
}
