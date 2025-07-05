import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/shared_widgets/image_picker_widget.dart';
import '../controllers/brand_form_controller.dart';

class BrandFormScreen extends StatelessWidget {
  const BrandFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BrandFormController controller = Get.put(BrandFormController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.brandToEdit.value == null
              ? LangKeys.addBrand.tr
              : LangKeys.editBrand.tr,
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
                      title: 'Brand Details',
                      child: Column(
                        children: [
                          TextFormField(
                            controller: controller.nameController,
                            decoration: InputDecoration(
                              labelText: LangKeys.brandName.tr,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return LangKeys.fieldRequired.tr;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: kDefaultPadding),
                          TextFormField(
                            controller: controller.descriptionController,
                            decoration: InputDecoration(
                              labelText: LangKeys.brandDescription.tr,
                            ),
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                    _buildFormSection(
                      title: LangKeys.brandLogo.tr,
                      child: ImagePickerWidget(
                        initialImageUrl: controller.brandToEdit.value?.logoUrl,
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
          onPressed: controller.isLoading.value ? null : controller.saveBrand,
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
