import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/shared_widgets/form_section_card.dart';
import '../controllers/sale_form_controller.dart';

class SaleFormScreen extends StatelessWidget {
  const SaleFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SaleFormController controller = Get.put(SaleFormController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.saleToEdit.value == null
              ? LangKeys.addSale.tr
              : LangKeys.editSale.tr,
        )),
      ),
      body: Center(
        child: SizedBox(
          width: 800,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  FormSectionCard(
                    title: LangKeys.saleDetails.tr,
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
                  FormSectionCard(
                    title: LangKeys.durationAndStatus.tr,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildDatePicker(
                                context: context,
                                label: LangKeys.startDate.tr,
                                date: controller.startDate.value,
                                onTap: () => controller.pickDate(context, true),
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
                        Obx(() => SwitchListTile(
                          title: Text(LangKeys.active.tr),
                          value: controller.isActive.value,
                          onChanged: (val) =>
                          controller.isActive.value = val,
                          contentPadding: EdgeInsets.zero,
                        )),
                      ],
                    ),
                  ),
                  FormSectionCard(
                    title: LangKeys.applicability.tr,
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
                                  onChanged: (val) {
                                    controller.appliesTo.value = val!;
                                    controller.targetIds.clear();
                                    controller.targetNames.clear();
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: Text(LangKeys.categories.tr),
                                  value: 'categories',
                                  groupValue: controller.appliesTo.value,
                                  onChanged: (val) {
                                    controller.appliesTo.value = val!;
                                    controller.targetIds.clear();
                                    controller.targetNames.clear();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: kDefaultPadding),
                        SizedBox(
                          width: double.infinity,
                          child: Obx(() => OutlinedButton.icon(
                            icon: const Icon(Icons.checklist),
                            label: Text(
                              controller.appliesTo.value == 'products'
                                  ? LangKeys.selectProducts.tr
                                  : LangKeys.selectCategories.tr,
                            ),
                            style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 45)),
                            onPressed: () =>
                                controller.openItemSelectionDialog(context),
                          )),
                        ),
                        const SizedBox(height: kDefaultPadding),
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
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding / 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(LangKeys.cancel.tr),
              ),
              const SizedBox(width: kDefaultPadding),
              Obx(() => ElevatedButton.icon(
                icon: const Icon(Icons.save_alt_outlined),
                label: Text(LangKeys.save.tr.toUpperCase()),
                onPressed: controller.isLoading.value
                    ? null
                    : controller.saveSale,
              )),
            ],
          ),
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
      borderRadius: BorderRadius.circular(kDefaultRadius),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
