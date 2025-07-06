import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/shared_widgets/form_section_card.dart';
import '../../brands/controllers/brands_controller.dart';
import '../../categories/controllers/categories_controller.dart';
import '../../models/brand_model.dart';
import '../../models/category_model.dart';
import '../controllers/product_form_controller.dart';

class ProductFormScreen extends StatelessWidget {
  const ProductFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductFormController controller = Get.put(ProductFormController());
    Get.put(BrandsController());
    Get.put(CategoriesController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.productToEdit.value == null
            ? LangKeys.addProduct.tr
            : LangKeys.editProduct.tr)),
      ),
      body: Center(
        child: SizedBox(
          width: 1200,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Form(
              key: controller.formKey,
              child: LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildBasicInfoCard(controller),
                            _buildVariantsCard(controller),
                          ],
                        ),
                      ),
                      const SizedBox(width: kDefaultPadding),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _buildStatusCard(controller),
                            _buildCategorizationCard(controller),
                            _buildImageCard(controller),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildBasicInfoCard(controller),
                      _buildStatusCard(controller),
                      _buildCategorizationCard(controller),
                      _buildImageCard(controller),
                      _buildVariantsCard(controller),
                    ],
                  );
                }
              }),
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
              ElevatedButton.icon(
                icon: const Icon(Icons.save_alt_outlined),
                label: Text(LangKeys.save.tr.toUpperCase()),
                onPressed: controller.saveProduct,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(ProductFormController controller) {
    return FormSectionCard(
      title: LangKeys.basicInformation.tr,
      child: Column(
        children: [
          TextFormField(
            controller: controller.nameController,
            decoration: InputDecoration(labelText: LangKeys.productName.tr),
            validator: (v) => v!.isEmpty ? LangKeys.fieldRequired.tr : null,
          ),
          const SizedBox(height: kDefaultPadding),
          TextFormField(
            controller: controller.descriptionController,
            decoration:
            InputDecoration(labelText: LangKeys.productDescription.tr),
            maxLines: 6,
            minLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(ProductFormController controller) {
    return FormSectionCard(
      title: LangKeys.status.tr,
      child: Obx(
            () => SwitchListTile(
          title: Text(LangKeys.featuredProduct.tr),
          value: controller.isFeatured.value,
          onChanged: (val) => controller.isFeatured.value = val,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildCategorizationCard(ProductFormController controller) {
    final BrandsController brandsController = Get.find();
    final CategoriesController categoriesController = Get.find();

    return FormSectionCard(
      title: LangKeys.categorization.tr,
      child: Column(
        children: [
          Obx(
                () => DropdownButtonFormField<BrandModel>(
              value: controller.selectedBrand.value,
              hint: Text(LangKeys.productBrand.tr),
              onChanged: (val) => controller.selectedBrand.value = val,
              items: brandsController.allBrands
                  .map((b) => DropdownMenuItem(value: b, child: Text(b.name)))
                  .toList(),
              validator: (v) => v == null ? LangKeys.fieldRequired.tr : null,
              decoration: InputDecoration(labelText: LangKeys.productBrand.tr),
            ),
          ),
          const SizedBox(height: kDefaultPadding),
          Obx(
                () => MultiSelectDialogField<CategoryModel>(
              buttonText: Text(LangKeys.productCategories.tr),
              title: Text(LangKeys.selectCategories.tr),
              items: categoriesController.flattenedCategoriesForDisplay
                  .map((c) => MultiSelectItem(c, c.name))
                  .toList(),
              listType: MultiSelectListType.LIST,
              onConfirm: (values) {
                controller.selectedCategories.value = values;
              },
              initialValue: controller.selectedCategories.toList(),
              chipDisplay: MultiSelectChipDisplay.none(),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(kDefaultRadius),
              ),
              selectedItemsTextStyle:
              TextStyle(color: Get.theme.primaryColor),
            ),
          ),
          Obx(() {
            if (controller.selectedCategories.isEmpty) return const SizedBox();
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                children: controller.selectedCategories
                    .map((item) => Chip(
                  label: Text(item.name.replaceAll(RegExp(r'—\s*'), '')),
                  onDeleted: () {
                    controller.selectedCategories.remove(item);
                  },
                ))
                    .toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildImageCard(ProductFormController controller) {
    return FormSectionCard(
      title: LangKeys.productImages.tr,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.pickProductImages,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(LangKeys.addImages.tr),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 45)),
                ),
              ),
              const SizedBox(width: kDefaultPadding / 2),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    controller.openUrlDialog();
                    Get.dialog(_UrlInputDialog(controller: controller));
                  },
                  icon: const Icon(Icons.link),
                  label: Text(LangKeys.addImageUrls.tr),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 45)),
                ),
              ),
            ],
          ),
          const SizedBox(height: kDefaultPadding),
          Obx(() {
            if (controller.productImages.isEmpty) {
              return SizedBox(
                height: 100,
                child: Center(
                    child: Text(LangKeys.noImagesSelected.tr,
                        style: const TextStyle(color: kSecondaryTextColor))),
              );
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: controller.productImages.length,
              itemBuilder: (context, index) {
                final imageSource = controller.productImages[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(kDefaultRadius / 2),
                      child: imageSource.data is String
                          ? Image.network(imageSource.data as String,
                          fit: BoxFit.cover)
                          : Image.memory(imageSource.data as Uint8List,
                          fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => controller.removeProductImage(index),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child:
                          Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    )
                  ],
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVariantsCard(ProductFormController controller) {
    return FormSectionCard(
      title: LangKeys.productVariants.tr,
      child: Column(
        children: [
          Obx(() => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.variantForms.length,
            itemBuilder: (ctx, index) =>
                _buildVariantForm(controller, index),
            separatorBuilder: (ctx, index) =>
            const Divider(height: kDefaultPadding * 2),
          )),
          const SizedBox(height: kDefaultPadding),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: Text(LangKeys.addVariant.tr),
            onPressed: controller.addVariantForm,
            style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45)),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantForm(ProductFormController controller, int index) {
    final formState = controller.variantForms[index];
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding / 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(kDefaultRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${LangKeys.variant.tr} ${index + 1}",
                  style: Get.textTheme.titleMedium),
              if (controller.variantForms.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: kErrorColor),
                  onPressed: () => controller.removeVariantForm(index),
                ),
            ],
          ),
          const SizedBox(height: kDefaultPadding),
          TextFormField(
            controller: formState.attributesController,
            decoration: InputDecoration(
              labelText: LangKeys.variantAttributes.tr,
              hintText: LangKeys.attributesHint.tr,
            ),
          ),
          const SizedBox(height: kDefaultPadding),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: formState.priceController,
                  decoration: InputDecoration(labelText: LangKeys.price.tr),
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) =>
                  v!.isEmpty ? LangKeys.fieldRequired.tr : null,
                ),
              ),
              const SizedBox(width: kDefaultPadding),
              Expanded(
                child: TextFormField(
                  controller: formState.stockController,
                  decoration:
                  InputDecoration(labelText: LangKeys.stockQuantity.tr),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                  v!.isEmpty ? LangKeys.fieldRequired.tr : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: kDefaultPadding),
          TextFormField(
            controller: formState.skuController,
            decoration: InputDecoration(labelText: LangKeys.sku.tr),
          ),
        ],
      ),
    );
  }
}

class _UrlInputDialog extends StatelessWidget {
  final ProductFormController controller;
  const _UrlInputDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(LangKeys.enterImageUrls.tr),
      content: SizedBox(
        width: Get.width * 0.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Obx(
                    () => ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.urlControllers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller.urlControllers[index],
                              decoration: InputDecoration(
                                labelText:
                                "${LangKeys.imageUrl.tr} ${index + 1}",
                                hintText: LangKeys.imageUrlHint.tr,
                              ),
                            ),
                          ),
                          if (controller.urlControllers.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: kErrorColor),
                              onPressed: () => controller.removeUrlField(index),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: kDefaultPadding),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: controller.addUrlField,
                icon: const Icon(Icons.add),
                label: Text(LangKeys.addUrl.tr),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text(LangKeys.cancel.tr),
        ),
        ElevatedButton(
          onPressed: controller.addImageUrlsFromDialog,
          child: Text(LangKeys.addImages.tr),
        ),
      ],
    );
  }
}
