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
    final BrandsController controller = Get.put(BrandsController());

    return Scaffold(
      appBar: AppBar(title: Text(LangKeys.brands.tr)),
      body: RefreshIndicator(
        onRefresh: controller.fetchBrands,
        child: const Column(
          children: [
            _Header(),
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
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                hintText:
                    '${LangKeys.search.tr} ${LangKeys.brands.tr.toLowerCase()}...',
                prefixIcon: const Icon(Icons.search, size: 20),
              ),
            ),
          ),
          const SizedBox(width: kDefaultPadding),
          // "Add New" button is now prominently in the header
          ElevatedButton.icon(
            onPressed: () {
              Get.toNamed(AppRoutes.brandForm)?.then((result) {
                if (result == true) controller.fetchBrands();
              });
            },
            icon: const Icon(Icons.add),
            label: Text(LangKeys.addNew.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: kDefaultPadding,
                vertical: 14, // Custom padding for button height
              ),
            ),
          ),
        ],
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
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_off,
                size: 60,
                color: kSecondaryTextColor,
              ),
              const SizedBox(height: kDefaultPadding),
              Text(LangKeys.noBrandsFound.tr, style: Get.textTheme.titleMedium),
            ],
          ),
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < kMobileBreakpoint) {
            // A cleaner, more spacious list view for mobile
            return _BrandListView(brands: controller.filteredBrands);
          } else {
            // The robust desktop data table
            return _BrandDesktopTable(brands: controller.filteredBrands);
          }
        },
      );
    });
  }
}

class _BrandListView extends StatelessWidget {
  final List<BrandModel> brands;

  const _BrandListView({required this.brands});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BrandsController>();
    // Using ListView.separated for cleaner dividers
    return ListView.separated(
      padding: const EdgeInsets.only(
        left: kDefaultPadding,
        right: kDefaultPadding,
        bottom: kDefaultPadding,
      ),
      itemCount: brands.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, thickness: 0.1, color: Color(0xFF858585)),
      itemBuilder: (context, index) {
        final brand = brands[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: kDefaultPadding / 2,
            vertical: kDefaultPadding,
          ),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey.shade100,
            backgroundImage: brand.logoUrl.isNotEmpty
                ? NetworkImage(brand.logoUrl)
                : null,
            child: brand.logoUrl.isEmpty
                ? const Icon(
                    Icons.branding_watermark_outlined,
                    color: kSecondaryTextColor,
                  )
                : null,
          ),
          title: Text(
            brand.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: brand.description != null && brand.description!.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    brand.description!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: LangKeys.edit.tr,
                color: kPrimaryColor,
                onPressed: () =>
                    Get.toNamed(AppRoutes.brandForm, arguments: brand)?.then((
                      result,
                    ) {
                      if (result == true) controller.fetchBrands();
                    }),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: LangKeys.delete.tr,
                color: kErrorColor,
                onPressed: () => showConfirmationDialog(
                  title: LangKeys.confirmDelete.tr,
                  message: LangKeys.confirmDeleteItem.trParams({
                    'item': brand.name,
                  }),
                  onConfirm: () => controller.deleteBrand(brand.id),
                ),
              ),
            ],
          ),
          onTap: () => Get.toNamed(AppRoutes.brandForm, arguments: brand)?.then(
            (result) {
              if (result == true) controller.fetchBrands();
            },
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
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: SingleChildScrollView(
          child: DataTable(
            columns: [
              DataColumn(
                label: Text(
                  LangKeys.logo.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  LangKeys.name.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  LangKeys.description.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  LangKeys.actions.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: List.generate(brands.length, (index) {
              final brand = brands[index];
              return _buildDataRow(brand, Get.find<BrandsController>());
            }),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(BrandModel brand, BrandsController controller) {
    return DataRow(
      cells: [
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
            child: CircleAvatar(
              backgroundColor: kBackgroundColor,
              backgroundImage: brand.logoUrl.isNotEmpty
                  ? NetworkImage(brand.logoUrl)
                  : null,
              child: brand.logoUrl.isEmpty
                  ? const Icon(
                      Icons.branding_watermark_outlined,
                      color: kSecondaryTextColor,
                      size: 20,
                    )
                  : null,
            ),
          ),
        ),
        DataCell(Text(brand.name)),
        DataCell(
          SizedBox(
            width: 300,
            child: Text(
              brand.description ?? '',
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
                onPressed: () =>
                    Get.toNamed(AppRoutes.brandForm, arguments: brand)?.then((
                      result,
                    ) {
                      if (result == true) controller.fetchBrands();
                    }),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: kErrorColor,
                tooltip: LangKeys.delete.tr,
                onPressed: () => showConfirmationDialog(
                  title: LangKeys.confirmDelete.tr,
                  message: LangKeys.confirmDeleteItem.trParams({
                    'item': brand.name,
                  }),
                  onConfirm: () => controller.deleteBrand(brand.id),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
