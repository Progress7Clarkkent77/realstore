import 'dart:typed_data';
import 'dart:convert';

import 'package:realstore/live/liveControllers/adminDashboardController.dart';
import 'package:realstore/platformControllers/domainController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UploadProductController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final DomainController domainCtrl = Get.find<DomainController>();

  final EcommerceAdminDashboardController dashboardCtrl =
      Get.find<EcommerceAdminDashboardController>();

  final ImagePicker _picker = ImagePicker();

  final RxBool isLoading = false.obs;

  //==================================================
  // FORM CONTROLLERS
  //==================================================

  final TextEditingController nameCtrl = TextEditingController();

  final TextEditingController descriptionCtrl = TextEditingController();

  final TextEditingController priceCtrl = TextEditingController();

  final TextEditingController deliveryFeeCtrl = TextEditingController();

  final TextEditingController stockCtrl = TextEditingController();

  //==================================================
  // IMAGES
  //==================================================

  /// Used for preview in UI
  final RxList<Uint8List> selectedImages = <Uint8List>[].obs;

  /// Stored in Firestore
  final RxList<String> imageBase64List = <String>[].obs;

  //==================================================
  // CATEGORY
  //==================================================

  final RxList<String> categories = <String>[
    'Electronics',
    'Fashion',
    'Beauty',
    'Groceries',
    'Phones',
    'Computers',
    'Home & Kitchen',
    'Books',
    'Foods',
    'Sports',
    'Automobile',
  ].obs;

  final RxString selectedCategory = ''.obs;

  @override
  void onClose() {
    nameCtrl.dispose();
    descriptionCtrl.dispose();
    priceCtrl.dispose();
    deliveryFeeCtrl.dispose();
    stockCtrl.dispose();
    super.onClose();
  }

  //==================================================
  // PICK MULTIPLE IMAGES
  //==================================================

  Future<void> pickImages() async {
    try {
      final files = await _picker.pickMultiImage(imageQuality: 80);

      if (files.isEmpty) {
        return;
      }

      selectedImages.clear();
      imageBase64List.clear();

      for (final file in files) {
        final bytes = await file.readAsBytes();

        selectedImages.add(bytes);

        imageBase64List.add(base64Encode(bytes));
      }
    } catch (e) {
      Get.snackbar('Images', e.toString());
    }
  }

  //==================================================
  // REMOVE IMAGE
  //==================================================

  void removeImage(int index) {
    if (index < 0 || index >= selectedImages.length) {
      return;
    }

    selectedImages.removeAt(index);
    imageBase64List.removeAt(index);
  }

  //==================================================
  // VALIDATE
  //==================================================

  bool validateForm() {
    if (nameCtrl.text.trim().isEmpty) {
      Get.snackbar('Product', 'Product name required');
      return false;
    }

    if (selectedCategory.value.isEmpty) {
      Get.snackbar('Category', 'Please select a category');
      return false;
    }

    if (priceCtrl.text.trim().isEmpty) {
      Get.snackbar('Price', 'Enter product price');
      return false;
    }

    if (double.tryParse(priceCtrl.text.trim()) == null) {
      Get.snackbar('Price', 'Invalid price');
      return false;
    }

    return true;
  }

  //==================================================
  // UPLOAD PRODUCT
  //==================================================

  // Future<void> uploadProduct() async {
  //   try {
  //     final orgId = domainCtrl.organizationId.value;

  //     if (orgId.isEmpty) {
  //       Get.snackbar(
  //         'Organization',
  //         'Organization not found',
  //       );
  //       return;
  //     }

  //     if (!validateForm()) {
  //       return;
  //     }

  //     isLoading.value = true;

  //     await _firestore
  //         .collection('organizations')
  //         .doc(orgId)
  //         .collection('products')
  //         .add({
  //       'name': nameCtrl.text.trim(),

  //       'description': descriptionCtrl.text.trim(),

  //       'category': selectedCategory.value,

  //       'price': double.parse(
  //         priceCtrl.text.trim(),
  //       ),

  //       'deliveryFee': double.tryParse(
  //             deliveryFeeCtrl.text.trim(),
  //           ) ??
  //           0,

  //       'stock': int.tryParse(
  //             stockCtrl.text.trim(),
  //           ) ??
  //           0,

  //       // Images saved to Firestore
  //       'images': imageBase64List.toList(),

  //       'isActive': true,

  //       'createdAt': FieldValue.serverTimestamp(),
  //     });

  //     await _firestore.collection('organizations').doc(orgId).update({
  //       'productCount': FieldValue.increment(1),
  //     });

  //     await dashboardCtrl.loadDashboard();

  //     clearForm();

  //     Get.snackbar(
  //       'Success',
  //       'Product uploaded successfully',
  //     );
  //   } catch (e) {
  //     Get.snackbar(
  //       'Upload Failed',
  //       e.toString(),
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  //==================================================
  // UPLOAD PRODUCT
  //==================================================

  Future<void> uploadProduct() async {
    try {
      final orgId = domainCtrl.organizationId.value;

      if (orgId.isEmpty) {
        Get.snackbar('Organization', 'Organization not found');
        return;
      }

      if (!validateForm()) {
        return;
      }

      isLoading.value = true;

      final double originalPrice = double.parse(priceCtrl.text.trim());

      /// 5% platform markup
      final double platformFee = (originalPrice * 0.05);

      final double sellingPrice = originalPrice + platformFee;

      await _firestore
          .collection('organizations')
          .doc(orgId)
          .collection('products')
          .add({
            /// PRODUCT INFO
            'name': nameCtrl.text.trim(),

            'description': descriptionCtrl.text.trim(),

            'category': selectedCategory.value,

            /// PRICING
            'price': sellingPrice,

            'originalPrice': originalPrice,

            'platformFee': platformFee,

            /// DELIVERY
            'deliveryFee': double.tryParse(deliveryFeeCtrl.text.trim()) ?? 0,

            /// STOCK
            'stock': int.tryParse(stockCtrl.text.trim()) ?? 0,

            /// IMAGES
            'images': imageBase64List.toList(),

            /// STATUS
            'isActive': true,

            /// TIMESTAMP
            'createdAt': FieldValue.serverTimestamp(),
          });

      await _firestore.collection('organizations').doc(orgId).update({
        'productCount': FieldValue.increment(1),
      });

      await dashboardCtrl.loadDashboard();

      clearForm();

      Get.snackbar('Success', 'Product uploaded successfully');
    } catch (e) {
      Get.snackbar('Upload Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  //==================================================
  // CLEAR FORM
  //==================================================

  void clearForm() {
    nameCtrl.clear();
    descriptionCtrl.clear();
    priceCtrl.clear();
    deliveryFeeCtrl.clear();
    stockCtrl.clear();

    selectedImages.clear();
    imageBase64List.clear();

    selectedCategory.value = '';
  }
}
