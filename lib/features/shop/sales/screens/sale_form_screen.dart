import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../../../core/constants/ui_constants.dart';
import '../controllers/sale_form_controller.dart';

class SaleFormScreen extends StatelessWidget {
  const SaleFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SaleFormController controller = Get.put(SaleFormController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.saleToEdit.value == null
              ? LangKeys.addSale.tr
              : LangKeys.editSale.tr,
        ),
      ),
      body: Obx(
        () => Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    _buildFormSection(
                      title: 'Sale Details',
                      child: Column(
                        children: [
                          TextFormField(
                            controller: controller.nameController,
                            decoration: InputDecoration(
                              labelText: LangKeys.saleName.tr,
                            ),
                            validator: (v) =>
                                v!.isEmpty ? LangKeys.fieldRequired.tr : null,
                          ),
                          const SizedBox(height: kDefaultPadding),
                          TextFormField(
                            controller: controller.descriptionController,
                            decoration: InputDecoration(
                              labelText: LangKeys.saleDescription.tr,
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: kDefaultPadding),
                          TextFormField(
                            controller: controller.discountController,
                            decoration: InputDecoration(
                              labelText: LangKeys.discountPercentage.tr,
                              suffixText: '%',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v!.isEmpty ? LangKeys.fieldRequired.tr : null,
                          ),
                        ],
                      ),
                    ),
                    _buildFormSection(
                      title: 'Duration & Status',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildDatePicker(
                                  context: context,
                                  label: LangKeys.startDate.tr,
                                  date: controller.startDate.value,
                                  onTap: () =>
                                      controller.pickDate(context, true),
                                ),
                              ),
                              const SizedBox(width: kDefaultPadding),
                              Expanded(
                                child: _buildDatePicker(
                                  context: context,
                                  label: LangKeys.endDate.tr,
                                  date: controller.endDate.value,
                                  onTap: () =>
                                      controller.pickDate(context, false),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: kDefaultPadding / 2),
                          SwitchListTile(
                            title: Text(LangKeys.active.tr),
                            value: controller.isActive.value,
                            onChanged: (val) => controller.isActive.value = val,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                    _buildFormSection(
                      title: 'Applicability',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LangKeys.appliesTo.tr,
                            style: Get.textTheme.titleMedium,
                          ),
                          Obx(
                            () => Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: Text(LangKeys.products.tr),
                                    value: 'products',
                                    groupValue: controller.appliesTo.value,
                                    onChanged: (val) =>
                                        controller.appliesTo.value = val!,
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: Text(LangKeys.categories.tr),
                                    value: 'categories',
                                    groupValue: controller.appliesTo.value,
                                    onChanged: (val) =>
                                        controller.appliesTo.value = val!,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: kDefaultPadding),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.checklist),
                            label: Text(
                              controller.appliesTo.value == 'products'
                                  ? LangKeys.selectProducts.tr
                                  : LangKeys.selectCategories.tr,
                            ),
                            onPressed: () =>
                                controller.openItemSelectionDialog(context),
                          ),
                          const SizedBox(height: kDefaultPadding / 2),
                          Obx(
                            () => Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: controller.targetNames
                                  .map((name) => Chip(label: Text(name)))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (controller.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: Text(LangKeys.save.tr),
          onPressed: controller.isLoading.value ? null : controller.saveSale,
        ),
      ),
    );
  }

  Widget _buildFormSection({required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: kDefaultPadding),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required BuildContext context,
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat.yMMMd().format(date)),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }
}
