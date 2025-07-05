import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/shared_widgets/image_picker_widget.dart';
import '../controllers/category_form_controller.dart';

class CategoryFormScreen extends StatelessWidget {
  const CategoryFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoryFormController controller = Get.put(CategoryFormController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.categoryToEdit.value == null
              ? LangKeys.addCategory.tr
              : LangKeys.editCategory.tr,
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
                      title: 'Category Details',
                      child: Column(
                        children: [
                          TextFormField(
                            controller: controller.nameController,
                            decoration: InputDecoration(
                              labelText: LangKeys.categoryName.tr,
                            ),
                            validator: (value) => value!.isEmpty
                                ? LangKeys.fieldRequired.tr
                                : null,
                          ),
                          const SizedBox(height: kDefaultPadding),
                          Obx(
                            () => DropdownButtonFormField<String>(
                              value: controller.parentCategoryId.value,
                              hint: Text(LangKeys.parentCategory.tr),
                              onChanged: controller.onParentCategoryChanged,
                              items: [
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: Text(LangKeys.noParent.tr),
                                ),
                                ...controller.availableParentCategories.map((
                                  cat,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: cat.id,
                                    child: Text(cat.name.replaceAll('— ', '')),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                          const SizedBox(height: kDefaultPadding),
                          TextFormField(
                            controller: controller.descriptionController,
                            decoration: InputDecoration(
                              labelText: LangKeys.categoryDescription.tr,
                            ),
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                    _buildFormSection(
                      title: LangKeys.categoryImage.tr,
                      child: ImagePickerWidget(
                        initialImageUrl:
                            controller.categoryToEdit.value?.imageUrl,
                        onImageSelected: controller.onImageSelected,
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
          onPressed: controller.isLoading.value
              ? null
              : controller.saveCategory,
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
}
