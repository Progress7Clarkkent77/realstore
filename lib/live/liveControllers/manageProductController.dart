import 'package:realstore/live/models/productModel.dart';
import 'package:realstore/platformControllers/domainController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ManageProductsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final DomainController domainCtrl = Get.find<DomainController>();

  final RxBool isLoading = false.obs;

  final RxList<ProductModel> products = <ProductModel>[].obs;

  final RxString searchQuery = ''.obs;

  List<ProductModel> get filteredProducts {
    if (searchQuery.value.isEmpty) {
      return products;
    }

    return products.where((p) {
      return p.name.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();

    listenProducts();
  }

  void listenProducts() {
    final orgId = domainCtrl.organizationId.value;

    if (orgId.isEmpty) return;

    isLoading.value = true;

    _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          products.value = snapshot.docs
              .map((e) => ProductModel.fromMap(e.id, e.data()))
              .toList();

          isLoading.value = false;
        });
  }

  Future<void> deleteProduct(String productId) async {
    final orgId = domainCtrl.organizationId.value;

    await _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('products')
        .doc(productId)
        .delete();

    await _firestore.collection('organizations').doc(orgId).update({
      'productCount': FieldValue.increment(-1),
    });

    Get.snackbar('Success', 'Product deleted');
  }

  Future<void> toggleProductStatus(ProductModel product) async {
    final orgId = domainCtrl.organizationId.value;

    await _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('products')
        .doc(product.id)
        .update({'isActive': !product.isActive});
  }
}
