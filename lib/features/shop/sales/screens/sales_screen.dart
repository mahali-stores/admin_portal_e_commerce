import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/shared_widgets/confirmation_dialog.dart';
import '../../../../core/utils/app_routes.dart';
import '../../models/sale_model.dart';
import '../controllers/sales_controller.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SalesController controller = Get.put(SalesController());

    return Scaffold(
      appBar: AppBar(
        title: Text(LangKeys.sales.tr),
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchSales,
        child: const Column(
          children: [
            _Header(),
            Expanded(child: _SalesDataView()),
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
    final SalesController controller = Get.find();
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                hintText:
                '${LangKeys.search.tr} ${LangKeys.sales.tr.toLowerCase()}...',
                prefixIcon: const Icon(Icons.search, size: 20),
              ),
            ),
          ),
          const SizedBox(width: kDefaultPadding),
          ElevatedButton.icon(
            onPressed: () {
              Get.toNamed(AppRoutes.saleForm)?.then((result) {
                if (result == true) controller.fetchSales();
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

class _SalesDataView extends StatelessWidget {
  const _SalesDataView();

  @override
  Widget build(BuildContext context) {
    final SalesController controller = Get.find();
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.filteredSales.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off,
                  size: 60, color: kSecondaryTextColor),
              const SizedBox(height: kDefaultPadding),
              Text(LangKeys.noSalesFound.tr, style: Get.textTheme.titleMedium),
            ],
          ),
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < kMobileBreakpoint) {
            return _SaleListView(sales: controller.filteredSales);
          } else {
            return _SaleDesktopTable(sales: controller.filteredSales);
          }
        },
      );
    });
  }
}

class _SaleListView extends StatelessWidget {
  final List<SaleModel> sales;
  const _SaleListView({required this.sales});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SalesController>();
    return ListView.separated(
      padding: const EdgeInsets.all(kDefaultPadding),
      itemCount: sales.length,
      separatorBuilder: (context, index) =>
      const SizedBox(height: kDefaultPadding),
      itemBuilder: (context, index) {
        final sale = sales[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () =>
                Get.toNamed(AppRoutes.saleForm, arguments: sale)?.then((result) {
                  if (result == true) controller.fetchSales();
                }),
            child: Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          sale.name,
                          style: Get.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      _buildStatusChip(sale.status),
                    ],
                  ),
                  const SizedBox(height: kDefaultPadding / 2),
                  if (sale.description != null && sale.description!.isNotEmpty)
                    Text(sale.description!,
                        style: Get.textTheme.bodyMedium),
                  const Divider(height: kDefaultPadding * 1.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          style: Get.textTheme.bodyMedium,
                          children: [
                            TextSpan(
                                text:
                                '${sale.discountPercentage.toStringAsFixed(0)}% OFF\n',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: kAccentColor,
                                    fontSize: 16)),
                            TextSpan(
                                text:
                                '${LangKeys.period.tr}: ${DateFormat.yMMMd().format(sale.startDate.toDate())} - ${DateFormat.yMMMd().format(sale.endDate.toDate())}'),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: kPrimaryColor),
                            tooltip: LangKeys.edit.tr,
                            onPressed: () => Get.toNamed(AppRoutes.saleForm,
                                arguments: sale)?.then((result) {
                              if (result == true) controller.fetchSales();
                            }),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: kErrorColor),
                            tooltip: LangKeys.delete.tr,
                            onPressed: () => showConfirmationDialog(
                              title: LangKeys.confirmDelete.tr,
                              message: LangKeys.confirmDeleteItem.trParams({'item': sale.name}),
                              onConfirm: () => controller.deleteSale(sale.id),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SaleDesktopTable extends StatelessWidget {
  final List<SaleModel> sales;
  const _SaleDesktopTable({required this.sales});

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
                  label: Text(LangKeys.name.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text(LangKeys.discount.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text(LangKeys.period.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text(LangKeys.appliesTo.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text(LangKeys.status.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text(LangKeys.actions.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: List.generate(sales.length, (index) {
              final sale = sales[index];
              return _buildDataRow(sale, Get.find<SalesController>());
            }),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(SaleModel sale, SalesController controller) {
    return DataRow(
      cells: [
        DataCell(Text(sale.name)),
        DataCell(Text('${sale.discountPercentage.toStringAsFixed(0)}%')),
        DataCell(
          Text(
            '${DateFormat.yMMMd().format(sale.startDate.toDate())} - ${DateFormat.yMMMd().format(sale.endDate.toDate())}',
          ),
        ),
        DataCell(Text(sale.appliesTo.capitalizeFirst ?? sale.appliesTo)),
        DataCell(_buildStatusChip(sale.status)),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                color: kPrimaryColor,
                tooltip: LangKeys.edit.tr,
                onPressed: () =>
                    Get.toNamed(AppRoutes.saleForm, arguments: sale)
                        ?.then((result) {
                      if (result == true) controller.fetchSales();
                    }),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: kErrorColor,
                tooltip: LangKeys.delete.tr,
                onPressed: () => showConfirmationDialog(
                  title: LangKeys.confirmDelete.tr,
                  message: LangKeys.confirmDeleteItem.trParams({'item': sale.name}),
                  onConfirm: () => controller.deleteSale(sale.id),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _buildStatusChip(String status) {
  Color color;
  String label;
  switch (status) {
    case 'Active':
      color = kAccentColor;
      label = LangKeys.statusActive.tr;
      break;
    case 'Expired':
      color = kSecondaryTextColor;
      label = LangKeys.statusExpired.tr;
      break;
    case 'Upcoming':
      color = Colors.orange;
      label = LangKeys.statusUpcoming.tr;
      break;
    default:
      color = kErrorColor;
      label = status;
  }
  return Chip(
    label: Text(label),
    backgroundColor: color.withOpacity(0.1),
    labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    side: BorderSide.none,
    padding: const EdgeInsets.symmetric(horizontal: 8),
  );
}
