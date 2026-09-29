import 'dart:async';

import 'package:realstore/live/models/productModel.dart';
import 'package:realstore/platformControllers/domainController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EcommerceStoreController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final DomainController domainCtrl = Get.find<DomainController>();

  //==================================================
  // PRODUCTS
  //==================================================

  final RxList<ProductModel> products = <ProductModel>[].obs;

  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;

  //==================================================
  // CATEGORIES
  //==================================================

  final RxList<String> categories = <String>['All'].obs;

  final RxString selectedCategory = 'All'.obs;

  //==================================================
  // SEARCH
  //==================================================

  final RxString searchText = ''.obs;

  final TextEditingController searchCtrl = TextEditingController();

  //==================================================
  // STATE
  //==================================================

  final RxBool isLoading = false.obs;

  final RxBool isInitialized = false.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _productsSubscription;

  //==================================================
  // INIT
  //==================================================

  @override
  void onInit() {
    super.onInit();
  }

  //==================================================
  // INITIALIZE STORE
  //==================================================

  Future<void> initializeStore() async {
    final orgId = domainCtrl.organizationId.value;

    if (orgId.isEmpty) {
      debugPrint('EcommerceStoreController: organizationId is empty');
      return;
    }

    if (isInitialized.value) {
      return;
    }

    isLoading.value = true;

    try {
      await loadProducts();

      isInitialized.value = true;
    } catch (e) {
      debugPrint('Store initialization failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  //==================================================
  // LOAD PRODUCTS
  //==================================================

  Future<void> loadProducts() async {
    final orgId = domainCtrl.organizationId.value;

    if (orgId.isEmpty) {
      debugPrint('Cannot load products. Organization ID is empty.');
      return;
    }

    await _productsSubscription?.cancel();

    _productsSubscription = _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('products')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen(
          (snapshot) {
            final data = snapshot.docs
                .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
                .toList();

            products.assignAll(data);

            _loadCategoriesFromProducts();

            filterProducts();
          },
          onError: (error) {
            debugPrint('Product stream error: $error');
          },
        );
  }

  //==================================================
  // LOAD CATEGORIES
  //==================================================

  void _loadCategoriesFromProducts() {
    final uniqueCategories = products
        .map((e) => e.category.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    uniqueCategories.sort();

    categories.assignAll(['All', ...uniqueCategories]);

    if (!categories.contains(selectedCategory.value)) {
      selectedCategory.value = 'All';
    }
  }

  //==================================================
  // FILTER PRODUCTS
  //==================================================

  void filterProducts() {
    List<ProductModel> result = products.toList();

    //------------------------------------------
    // CATEGORY FILTER
    //------------------------------------------

    if (selectedCategory.value != 'All') {
      result = result.where((product) {
        return product.category == selectedCategory.value;
      }).toList();
    }

    //------------------------------------------
    // SEARCH FILTER
    //------------------------------------------

    final query = searchText.value.trim().toLowerCase();

    if (query.isNotEmpty) {
      result = result.where((product) {
        return product.name.toLowerCase().contains(query) ||
            product.category.toLowerCase().contains(query) ||
            product.price.toString().contains(query);
      }).toList();
    }

    filteredProducts.assignAll(result);
  }

  //==================================================
  // SEARCH
  //==================================================

  void updateSearch(String value) {
    searchText.value = value;

    filterProducts();
  }

  //==================================================
  // CATEGORY
  //==================================================

  void updateCategory(String category) {
    selectedCategory.value = category;

    filterProducts();
  }

  //==================================================
  // REFRESH
  //==================================================

  Future<void> refreshStore() async {
    isInitialized.value = false;

    await initializeStore();
  }

  //==================================================
  // RESET
  //==================================================

  Future<void> resetStore() async {
    await _productsSubscription?.cancel();

    products.clear();
    filteredProducts.clear();

    categories.assignAll(['All']);

    selectedCategory.value = 'All';

    searchText.value = '';

    searchCtrl.clear();

    isInitialized.value = false;
  }

  //==================================================
  // SELECTED PRODUCT
  //==================================================

  final Rxn<ProductModel> selectedProduct = Rxn<ProductModel>();

  void selectProduct(ProductModel product) {
    selectedProduct.value = product;
  }

  //==================================================
  // DISPOSE
  //==================================================

  @override
  void onClose() {
    _productsSubscription?.cancel();

    searchCtrl.dispose();

    super.onClose();
  }
}
