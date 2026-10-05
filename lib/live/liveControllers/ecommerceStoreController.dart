import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realstore/live/liveControllers/storeConfig.dart';

import 'package:realstore/live/models/productModel.dart';

class EcommerceStoreController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  final Rxn<ProductModel> selectedProduct = Rxn<ProductModel>();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _productsSubscription;

  //==================================================
  // LIFECYCLE
  //==================================================

  @override
  void onInit() {
    super.onInit();
    initializeStore();
  }

  @override
  void onClose() {
    _productsSubscription?.cancel();
    searchCtrl.dispose();
    super.onClose();
  }

  //==================================================
  // INITIALIZE
  //==================================================

  Future<void> initializeStore() async {
    if (isInitialized.value) return;

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
  // LOAD PRODUCTS (REALTIME)
  //==================================================

  Future<void> loadProducts() async {
    await _productsSubscription?.cancel();

    _productsSubscription = _firestore
        .collection(StoreConfig.productsCollection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen(
          (snapshot) {
            products.assignAll(
              snapshot.docs.map((d) => ProductModel.fromMap(d.id, d.data())),
            );

            _loadCategoriesFromProducts();
            filterProducts();
          },
          onError: (Object error) => debugPrint('Product stream error: $error'),
        );
  }

  void _loadCategoriesFromProducts() {
    final unique =
        products
            .map((e) => e.category.trim())
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    categories.assignAll(['All', ...unique]);

    if (!categories.contains(selectedCategory.value)) {
      selectedCategory.value = 'All';
    }
  }

  //==================================================
  // FILTER
  //==================================================

  void filterProducts() {
    Iterable<ProductModel> result = products;

    if (selectedCategory.value != 'All') {
      result = result.where((p) => p.category == selectedCategory.value);
    }

    final query = searchText.value.trim().toLowerCase();

    if (query.isNotEmpty) {
      result = result.where(
        (p) =>
            p.name.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query) ||
            p.price.toString().contains(query),
      );
    }

    filteredProducts.assignAll(result);
  }

  void updateSearch(String value) {
    searchText.value = value;
    filterProducts();
  }

  void updateCategory(String category) {
    selectedCategory.value = category;
    filterProducts();
  }

  void selectProduct(ProductModel product) => selectedProduct.value = product;

  //==================================================
  // REFRESH / RESET
  //==================================================

  Future<void> refreshStore() async {
    isInitialized.value = false;
    await initializeStore();
  }

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
}
