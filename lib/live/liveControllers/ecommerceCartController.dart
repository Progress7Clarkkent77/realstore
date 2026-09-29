import 'package:realstore/live/liveControllers/ecommerceStoreController.dart';
import 'package:realstore/live/models/cartItemModel.dart';
import 'package:realstore/live/models/productModel.dart';
import 'package:realstore/live/userAuth/authController.dart';
import 'package:realstore/platformControllers/domainController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class EcommerceCartController extends GetxController {
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final DomainController domainCtrl = Get.find<DomainController>();

  final AuthController1 authCtrl = Get.find<AuthController1>();

  @override
  void onInit() {
    super.onInit();

    ever(authCtrl.isAuthenticated.obs, (_) {
      if (authCtrl.isAuthenticated) {
        loadCart();
      }
    });
  }

  //--------------------------------------------------
  // CART COUNT
  //--------------------------------------------------

  int get cartCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  //--------------------------------------------------
  // SUBTOTAL
  //--------------------------------------------------

  double get subtotal => cartItems.fold(0.0, (sum, item) => sum + item.total);

  //--------------------------------------------------
  // DELIVERY
  //--------------------------------------------------

  double get deliveryFee =>
      cartItems.fold(0.0, (sum, item) => sum + item.product.deliveryFee);

  //--------------------------------------------------
  // GRAND TOTAL
  //--------------------------------------------------

  double get grandTotal => subtotal + deliveryFee;

  //--------------------------------------------------
  // LOAD CART
  //--------------------------------------------------

  Future<void> loadCart() async {
    final uid = authCtrl.currentUser?.uid;

    if (uid == null) return;

    final orgId = domainCtrl.organizationId.value;

    final snapshot = await _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('carts')
        .doc(uid)
        .collection('items')
        .get();

    cartItems.clear();

    for (final doc in snapshot.docs) {
      final productId = doc['productId'];

      final quantity = doc['quantity'];

      final product = Get.find<EcommerceStoreController>().products
          .firstWhereOrNull((e) => e.id == productId);

      if (product != null) {
        cartItems.add(CartItemModel(product: product, quantity: quantity));
      }
    }
  }

  //--------------------------------------------------
  // ADD TO CART
  //--------------------------------------------------

  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    final uid = authCtrl.currentUser?.uid;

    if (uid == null) {
      Get.snackbar("Login Required", "Please login first");
      return;
    }

    final orgId = domainCtrl.organizationId.value;

    final existingIndex = cartItems.indexWhere(
      (e) => e.product.id == product.id,
    );

    if (existingIndex != -1) {
      cartItems[existingIndex].quantity += quantity;

      cartItems.refresh();
    } else {
      cartItems.add(CartItemModel(product: product, quantity: quantity));
    }

    final item = cartItems.firstWhere((e) => e.product.id == product.id);

    await _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('carts')
        .doc(uid)
        .collection('items')
        .doc(product.id)
        .set({
          'productId': product.id,
          'quantity': item.quantity,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  //--------------------------------------------------
  // REMOVE
  //--------------------------------------------------

  Future<void> removeItem(ProductModel product) async {
    cartItems.removeWhere((e) => e.product.id == product.id);

    final uid = authCtrl.currentUser?.uid;

    if (uid == null) return;

    final orgId = domainCtrl.organizationId.value;

    await _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('carts')
        .doc(uid)
        .collection('items')
        .doc(product.id)
        .delete();
  }

  Future<void> _saveQuantity(ProductModel product, int quantity) async {
    final uid = authCtrl.currentUser?.uid;

    if (uid == null) return;

    final orgId = domainCtrl.organizationId.value;

    await _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('carts')
        .doc(uid)
        .collection('items')
        .doc(product.id)
        .update({'quantity': quantity});
  }

  //--------------------------------------------------
  // INCREASE
  //--------------------------------------------------

  Future<void> increaseQty(ProductModel product) async {
    final item = cartItems.firstWhere((e) => e.product.id == product.id);

    item.quantity++;

    await _saveQuantity(product, item.quantity);

    cartItems.refresh();
  }

  //--------------------------------------------------
  // DECREASE
  //--------------------------------------------------

  Future<void> decreaseQty(ProductModel product) async {
    final item = cartItems.firstWhere((e) => e.product.id == product.id);

    if (item.quantity > 1) {
      item.quantity--;

      await _saveQuantity(product, item.quantity);

      cartItems.refresh();
    }
  }

  //--------------------------------------------------
  // CLEAR
  //--------------------------------------------------

  Future<void> clearCart() async {
    final uid = authCtrl.currentUser?.uid;

    if (uid == null) return;

    final orgId = domainCtrl.organizationId.value;

    final items = await _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('carts')
        .doc(uid)
        .collection('items')
        .get();

    for (final doc in items.docs) {
      await doc.reference.delete();
    }

    cartItems.clear();
  }
}
