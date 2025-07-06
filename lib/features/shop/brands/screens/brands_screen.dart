import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/shared_widgets/confirmation_dialog.dart';
import '../../../../core/utils/app_routes.dart';
import '../../models/brand_model.dart';
import '../controllers/brands_controller.dart';

class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(BrandsController());

    return Scaffold(
      appBar: AppBar(
        title: Text(LangKeys.brands.tr),
      ),
      body: RefreshIndicator(
        onRefresh: () => Get.find<BrandsController>().fetchBrands(),
        child: const Padding(
          padding: EdgeInsets.all(kDefaultPadding),
          child: Column(
            children: [
              _Header(),
              SizedBox(height: kDefaultPadding),
              Expanded(child: _BrandDataView()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(AppRoutes.brandForm)?.then((result) {
            if (result == true) Get.find<BrandsController>().fetchBrands();
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
    final BrandsController controller = Get.find();
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
          return _BrandListView(brands: controller.filteredBrands);
        } else {
          return _BrandDesktopTable(brands: controller.filteredBrands);
        }
      });
    });
  }
}

class _BrandListView extends StatelessWidget {
  final List<BrandModel> brands;
  const _BrandListView({required this.brands});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BrandsController>();
    return ListView.builder(
      itemCount: brands.length,
      itemBuilder: (context, index) {
        final brand = brands[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: kBackgroundColor,
              backgroundImage: brand.logoUrl.isNotEmpty ? NetworkImage(brand.logoUrl) : null,
              child: brand.logoUrl.isEmpty ? const Icon(Icons.branding_watermark_outlined, color: kSecondaryTextColor) : null,
            ),
            title: Text(brand.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(brand.description ?? '', overflow: TextOverflow.ellipsis, maxLines: 1),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: kPrimaryColor),
                  onPressed: () => Get.toNamed(AppRoutes.brandForm, arguments: brand)?.then((result) {
                    if (result == true) controller.fetchBrands();
                  }),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: kErrorColor),
                  onPressed: () => showConfirmationDialog(
                    title: LangKeys.confirmDelete.tr,
                    message: 'Delete "${brand.name}"?',
                    onConfirm: () => controller.deleteBrand(brand.id),
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

class _BrandDesktopTable extends StatelessWidget {
  final List<BrandModel> brands;
  const _BrandDesktopTable({required this.brands});

  @override
  Widget build(BuildContext context) {
    return Card(
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
          source: _BrandDataSource(brands: brands),
        ),
      ),
    );
  }
}

class _BrandDataSource extends DataTableSource {
  final List<BrandModel> brands;
  _BrandDataSource({required this.brands});

  @override
  DataRow? getRow(int index) {
    if (index >= brands.length) return null;
    final brand = brands[index];
    final controller = Get.find<BrandsController>();

    return DataRow(cells: [
      DataCell(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: CircleAvatar(
            backgroundColor: kBackgroundColor,
            backgroundImage: brand.logoUrl.isNotEmpty ? NetworkImage(brand.logoUrl) : null,
            child: brand.logoUrl.isEmpty ? const Icon(Icons.branding_watermark_outlined, color: kSecondaryTextColor, size: 20) : null,
          ),
        ),
      ),
      DataCell(Text(brand.name)),
      DataCell(Text(brand.description ?? '', overflow: TextOverflow.ellipsis)),
      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: kPrimaryColor),
            onPressed: () => Get.toNamed(AppRoutes.brandForm, arguments: brand)?.then((result) {
              if (result == true) controller.fetchBrands();
            }),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: kErrorColor),
            onPressed: () => showConfirmationDialog(
              title: LangKeys.confirmDelete.tr,
              message: 'Delete "${brand.name}"?',
              onConfirm: () => controller.deleteBrand(brand.id),
            ),
          ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => brands.length;
  @override
  int get selectedRowCount => 0;
}
