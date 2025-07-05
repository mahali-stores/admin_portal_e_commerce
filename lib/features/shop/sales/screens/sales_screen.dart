import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/utils/app_routes.dart';
import '../../models/sale_model.dart';
import '../controllers/sales_controller.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SalesController()); // Ensure controller is initialized

    return Scaffold(
      appBar: AppBar(
        title: Text(LangKeys.sales.tr),
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
                Get.toNamed(AppRoutes.saleForm)?.then((result) {
                  if (result == true) Get.find<SalesController>().fetchSales();
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
        return Center(child: Text(LangKeys.noSalesFound.tr));
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < kMobileBreakpoint) {
            // Mobile Card View
            return ListView.builder(
              itemCount: controller.filteredSales.length,
              itemBuilder: (context, index) =>
                  _SaleMobileCard(sale: controller.filteredSales[index]),
            );
          } else {
            // Desktop Data Table View
            return const _SaleDesktopTable();
          }
        },
      );
    });
  }
}

class _SaleMobileCard extends StatelessWidget {
  final SaleModel sale;

  const _SaleMobileCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SalesController>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    sale.name,
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(sale.status),
              ],
            ),
            const Divider(height: kDefaultPadding),
            Text.rich(
              TextSpan(
                style: const TextStyle(color: kSecondaryTextColor, height: 1.5),
                children: [
                  TextSpan(
                    text: '${sale.discountPercentage}% OFF\n',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kAccentColor,
                    ),
                  ),
                  TextSpan(
                    text: 'Applies to: ${sale.appliesTo.capitalizeFirst}\n',
                  ),
                  TextSpan(
                    text:
                        'Period: ${DateFormat.yMMMd().format(sale.startDate.toDate())} - ${DateFormat.yMMMd().format(sale.endDate.toDate())}',
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () =>
                      Get.toNamed(AppRoutes.saleForm, arguments: sale)?.then((
                        result,
                      ) {
                        if (result == true) controller.fetchSales();
                      }),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: kErrorColor),
                  onPressed: () => Get.defaultDialog(
                    title: LangKeys.confirmDelete.tr,
                    middleText: 'Delete "${sale.name}"?',
                    onConfirm: () {
                      controller.deleteSale(sale.id);
                      Get.back();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SaleDesktopTable extends StatelessWidget {
  const _SaleDesktopTable();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SalesController>();
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: double.infinity,
        child: PaginatedDataTable(
          header: Text(LangKeys.sales.tr),
          rowsPerPage: 10,
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Discount')),
            DataColumn(label: Text('Period')),
            DataColumn(label: Text('Applies To')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          source: _SaleDataSource(controller: controller),
        ),
      ),
    );
  }
}

class _SaleDataSource extends DataTableSource {
  final SalesController controller;

  _SaleDataSource({required this.controller});

  @override
  DataRow? getRow(int index) {
    if (index >= controller.filteredSales.length) return null;
    final sale = controller.filteredSales[index];

    return DataRow(
      cells: [
        DataCell(Text(sale.name)),
        DataCell(Text('${sale.discountPercentage}%')),
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
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () =>
                    Get.toNamed(AppRoutes.saleForm, arguments: sale)?.then((
                      result,
                    ) {
                      if (result == true) controller.fetchSales();
                    }),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: kErrorColor),
                onPressed: () => Get.defaultDialog(
                  title: LangKeys.confirmDelete.tr,
                  middleText: 'Delete "${sale.name}"?',
                  onConfirm: () {
                    controller.deleteSale(sale.id);
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
  int get rowCount => controller.filteredSales.length;

  @override
  int get selectedRowCount => 0;
}

Widget _buildStatusChip(String status) {
  Color color;
  switch (status) {
    case 'Active':
      color = kAccentColor;
      break;
    case 'Expired':
      color = kSecondaryTextColor;
      break;
    case 'Upcoming':
      color = Colors.orange;
      break;
    default:
      color = kErrorColor;
  }
  return Chip(
    label: Text(status),
    backgroundColor: color.withOpacity(0.1),
    labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    side: BorderSide.none,
    padding: const EdgeInsets.symmetric(horizontal: 8),
  );
}
