import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/utils/app_routes.dart';
import '../../models/brand_model.dart';
import '../controllers/brands_controller.dart';

class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(BrandsController()); // Ensure controller is initialized

    return Scaffold(
      appBar: AppBar(
        title: Text(LangKeys.brands.tr),
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
            Expanded(child: _BrandDataView()),
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
    final BrandsController controller = Get.find();
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
                Get.toNamed(AppRoutes.brandForm)?.then((result) {
                  if (result == true) Get.find<BrandsController>().fetchBrands();
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

class _BrandDataView extends StatelessWidget {
  const _BrandDataView();

  @override
  Widget build(BuildContext context) {
    final BrandsController controller = Get.find();
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.filteredBrands.isEmpty) {
        return Center(child: Text(LangKeys.noBrandsFound.tr));
      }

      return LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < kMobileBreakpoint) {
          // Mobile Card View
          return ListView.builder(
            itemCount: controller.filteredBrands.length,
            itemBuilder: (context, index) =>
                _BrandMobileCard(brand: controller.filteredBrands[index]),
          );
        } else {
          // Desktop Data Table View
          return const _BrandDesktopTable();
        }
      });
    });
  }
}

class _BrandMobileCard extends StatelessWidget {
  final BrandModel brand;
  const _BrandMobileCard({required this.brand});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BrandsController>();
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kBackgroundColor,
          child: brand.logoUrl.isNotEmpty
              ? ClipOval(child: Image.network(brand.logoUrl, fit: BoxFit.cover, width: 40, height: 40))
              : const Icon(Icons.branding_watermark, color: kSecondaryTextColor),
        ),
        title: Text(brand.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(brand.description ?? '', overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => Get.toNamed(AppRoutes.brandForm, arguments: brand)?.then((result) {
                if(result == true) controller.fetchBrands();
              }),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: kErrorColor),
              onPressed: () => Get.defaultDialog(
                title: LangKeys.confirmDelete.tr,
                middleText: 'Delete "${brand.name}"?',
                onConfirm: () {
                  controller.deleteBrand(brand.id);
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

class _BrandDesktopTable extends StatelessWidget {
  const _BrandDesktopTable();
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BrandsController>();
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: double.infinity,
        child: PaginatedDataTable(
          header: Text(LangKeys.brands.tr),
          rowsPerPage: 10,
          columns: const [
            DataColumn(label: Text('Logo')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Description')),
            DataColumn(label: Text('Actions')),
          ],
          source: _BrandDataSource(
            controller: controller,
          ),
        ),
      ),
    );
  }
}

class _BrandDataSource extends DataTableSource {
  final BrandsController controller;

  _BrandDataSource({required this.controller});

  @override
  DataRow? getRow(int index) {
    if (index >= controller.filteredBrands.length) return null;
    final brand = controller.filteredBrands[index];

    return DataRow(cells: [
      DataCell(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: CircleAvatar(
            backgroundColor: kBackgroundColor,
            child: brand.logoUrl.isNotEmpty
                ? ClipOval(child: Image.network(brand.logoUrl, fit: BoxFit.contain, width: 32, height: 32))
                : const Icon(Icons.branding_watermark, color: kSecondaryTextColor, size: 20),
          ),
        ),
      ),
      DataCell(Text(brand.name)),
      DataCell(Text(brand.description ?? '', overflow: TextOverflow.ellipsis)),
      DataCell(Row(
        children: [
          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => Get.toNamed(AppRoutes.brandForm, arguments: brand)?.then((result) {
            if(result == true) controller.fetchBrands();
          })),
          IconButton(icon: const Icon(Icons.delete, color: kErrorColor), onPressed: () => Get.defaultDialog(
            title: LangKeys.confirmDelete.tr,
            middleText: 'Delete "${brand.name}"?',
            onConfirm: () {
              controller.deleteBrand(brand.id);
              Get.back();
            },
          )),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => controller.filteredBrands.length;
  @override
  int get selectedRowCount => 0;
}