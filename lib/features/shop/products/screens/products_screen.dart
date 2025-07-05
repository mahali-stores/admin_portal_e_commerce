import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/utils/app_routes.dart';
import '../../brands/controllers/brands_controller.dart';
import '../../categories/controllers/categories_controller.dart';
import '../../models/brand_model.dart';
import '../../models/product_model.dart';
import '../controllers/products_controller.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controllers are available. In a larger app, consider a dedicated binding.
    Get.put(ProductsController());
    Get.put(BrandsController());
    Get.put(CategoriesController());

    return Scaffold(
      appBar: AppBar(
        title: Text(LangKeys.products.tr),
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
            Expanded(child: _ProductDataView()),
          ],
        ),
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
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => controller.searchQuery.value = value,
                    decoration: InputDecoration(
                      hintText: LangKeys.search.tr,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: kDefaultPadding),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed(AppRoutes.productForm)?.then((result) {
                      if (result == true)
                        Get.find<ProductsController>().fetchProducts();
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: Text(LangKeys.addNew.tr),
                ),
              ],
            ),
            const SizedBox(height: kDefaultPadding),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      hint: Text(LangKeys.productBrand.tr),
                      value: controller.filterByBrandId.value,
                      onChanged: (value) =>
                          controller.filterByBrandId.value = value,
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Brands'),
                        ),
                        ...brandsController.allBrands.map(
                          (b) => DropdownMenuItem(
                            value: b.id,
                            child: Text(b.name),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: kDefaultPadding),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      hint: Text(LangKeys.productCategories.tr),
                      value: controller.filterByCategoryId.value,
                      onChanged: (value) =>
                          controller.filterByCategoryId.value = value,
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Categories'),
                        ),
                        ...categoriesController.categories.map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        ),
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

      // Use LayoutBuilder to decide which view to show
      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < kMobileBreakpoint) {
            // Mobile Card View
            return ListView.builder(
              itemCount: controller.filteredProducts.length,
              itemBuilder: (context, index) => _ProductMobileCard(
                product: controller.filteredProducts[index],
              ),
            );
          } else {
            // Desktop Data Table View
            return const _ProductDesktopTable();
          }
        },
      );
    });
  }
}

// Mobile Card Widget
class _ProductMobileCard extends StatelessWidget {
  final ProductModel product;

  const _ProductMobileCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final ProductsController controller = Get.find();
    final String brandName = Get.find<BrandsController>().allBrands
        .firstWhere(
          (b) => b.id == product.brandId,
          orElse: () => BrandModel(id: '', name: 'N/A', logoUrl: ''),
        )
        .name;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding / 2),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(kDefaultRadius),
              child: product.imageUrls.isNotEmpty
                  ? Image.network(
                      product.imageUrls.first,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      color: kBackgroundColor,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: kSecondaryTextColor,
                      ),
                    ),
            ),
            const SizedBox(width: kDefaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    brandName,
                    style: const TextStyle(
                      color: kSecondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Get.toNamed(AppRoutes.productForm, arguments: product)?.then((
                  result,
                ) {
                  if (result == true) controller.fetchProducts();
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: kErrorColor),
              onPressed: () => Get.defaultDialog(
                title: LangKeys.confirmDelete.tr,
                middleText: 'Delete "${product.name}"?',
                onConfirm: () {
                  controller.deleteProduct(product.id);
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

// Desktop Data Table
class _ProductDesktopTable extends StatelessWidget {
  const _ProductDesktopTable();

  @override
  Widget build(BuildContext context) {
    final ProductsController controller = Get.find();
    final BrandsController brandsController = Get.find();
    return SizedBox(
      width: double.infinity,
      child: PaginatedDataTable(
        header: Text(LangKeys.products.tr),
        rowsPerPage: 10,
        columns: const [
          DataColumn(label: Text('Image')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Brand')),
          DataColumn(label: Text('Actions')),
        ],
        source: _ProductsDataSource(
          products: controller.filteredProducts,
          brands: brandsController.allBrands,
          onDelete: (product) => Get.defaultDialog(
            title: LangKeys.confirmDelete.tr,
            middleText: 'Are you sure you want to delete "${product.name}"?',
            textConfirm: LangKeys.delete.tr,
            textCancel: LangKeys.cancel.tr,
            onConfirm: () {
              controller.deleteProduct(product.id);
              Get.back();
            },
          ),
          onEdit: (product) {
            Get.toNamed(AppRoutes.productForm, arguments: product)?.then((
              result,
            ) {
              if (result == true) controller.fetchProducts();
            });
          },
        ),
      ),
    );
  }
}

// Data Source remains the same as before
class _ProductsDataSource extends DataTableSource {
  final List<ProductModel> products;
  final List<BrandModel> brands;
  final Function(ProductModel) onDelete;
  final Function(ProductModel) onEdit;

  _ProductsDataSource({
    required this.products,
    required this.brands,
    required this.onDelete,
    required this.onEdit,
  });

  String _getBrandName(String brandId) {
    return brands
        .firstWhere(
          (b) => b.id == brandId,
          orElse: () => BrandModel(id: '', name: 'N/A', logoUrl: ''),
        )
        .name;
  }

  @override
  DataRow? getRow(int index) {
    if (index >= products.length) return null;
    final product = products[index];

    return DataRow(
      cells: [
        DataCell(
          product.imageUrls.isNotEmpty
              ? Image.network(
                  product.imageUrls.first,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 40,
                  height: 40,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                ),
        ),
        DataCell(Text(product.name)),
        DataCell(Text(_getBrandName(product.brandId))),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => onEdit(product),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: kErrorColor),
                onPressed: () => onDelete(product),
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
