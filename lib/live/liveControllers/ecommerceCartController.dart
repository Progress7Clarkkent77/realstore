import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:realstore/live/liveControllers/ecommerceStoreController.dart';
import 'package:realstore/live/liveControllers/storeConfig.dart';
import 'package:realstore/live/models/cartItemModel.dart';
import 'package:realstore/live/models/productModel.dart';
import 'package:realstore/live/userAuth/authController.dart';

class EcommerceCartController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final AuthController authCtrl = Get.find<AuthController>();

  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final RxBool isLoading = false.obs;

  /// Where the order is being delivered. Shared by the product page, cart and
  /// checkout so the delivery fee is always the same everywhere.
  final Rx<DeliveryZone> deliveryZone = DeliveryZone.enugu.obs;

  StreamSubscription<User?>? _authSub;

  //--------------------------------------------------
  // LIFECYCLE
  //--------------------------------------------------

  @override
  void onInit() {
    super.onInit();

    // Load the cart whenever a user signs in; clear it on sign out.
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        cartItems.clear();
      } else {
        loadCart();
      }
    });
  }

  @override
  void onClose() {
    _authSub?.cancel();
    super.onClose();
  }

  //--------------------------------------------------
  // HELPERS
  //--------------------------------------------------

  String? get _uid => authCtrl.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> _cartRef(String uid) =>
      _firestore.collection(StoreConfig.cartsCollection).doc(uid);

  CollectionReference<Map<String, dynamic>> _itemsRef(String uid) =>
      _cartRef(uid).collection(StoreConfig.cartItemsCollection);

  /// Units of this product already in the cart, across all colours.
  int qtyInCartFor(String productId) => cartItems
      .where((e) => e.product.id == productId)
      .fold(0, (sum, e) => sum + e.quantity);

  //--------------------------------------------------
  // TOTALS
  //--------------------------------------------------

  int get cartCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => cartItems.fold(0.0, (sum, item) => sum + item.total);

  /// Delivery fee if the order went to [zone]. A product is charged once,
  /// even when it is in the cart in several colours.
  double deliveryFeeForZone(DeliveryZone zone) {
    final counted = <String>{};
    var sum = 0.0;

    for (final item in cartItems) {
      if (counted.add(item.product.id)) {
        sum += item.product.deliveryFeeFor(zone);
      }
    }

    return sum;
  }

  /// Delivery fee for the currently selected zone.
  double get deliveryFee => deliveryFeeForZone(deliveryZone.value);

  double get grandTotal => subtotal + deliveryFee;

  //--------------------------------------------------
  // DELIVERY ZONE
  //--------------------------------------------------

  Future<void> setDeliveryZone(DeliveryZone zone) async {
    if (deliveryZone.value == zone) return;

    deliveryZone.value = zone;

    // Best effort: remember the choice, but never block the UI on it.
    final uid = _uid;
    if (uid == null) return;

    try {
      await _cartRef(uid)
          .set({'deliveryZone': zone.key}, SetOptions(merge: true));
    } catch (_) {}
  }

  //--------------------------------------------------
  // LOAD CART
  //--------------------------------------------------

  Future<void> loadCart() async {
    final uid = _uid;
    if (uid == null) return;

    try {
      isLoading.value = true;

      // Restore the delivery zone (ignored if it cannot be read).
      try {
        final cartDoc = await _cartRef(uid).get();
        deliveryZone.value = DeliveryZoneX.fromKey(
          cartDoc.data()?['deliveryZone'] as String?,
        );
      } catch (_) {}

      final snapshot = await _itemsRef(uid).get();

      final storeProducts = Get.isRegistered<EcommerceStoreController>()
          ? Get.find<EcommerceStoreController>().products
          : <ProductModel>[];

      final loaded = <CartItemModel>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final productId = (data['productId'] ?? doc.id).toString();
        final quantity = (data['quantity'] as num? ?? 1).toInt();

        var product = storeProducts.firstWhereOrNull((p) => p.id == productId);

        // Fall back to Firestore if the store list has not loaded yet.
        if (product == null) {
          final productDoc = await _firestore
              .collection(StoreConfig.productsCollection)
              .doc(productId)
              .get();

          if (productDoc.exists) {
            product = ProductModel.fromMap(productDoc.id, productDoc.data()!);
          }
        }

        if (product != null && product.isActive) {
          loaded.add(
            CartItemModel(
              product: product,
              quantity: quantity,
              colorName: (data['colorName'] ?? '').toString(),
              colorHex: (data['colorHex'] ?? '').toString(),
              imageIndex: (data['imageIndex'] as num? ?? 0).toInt(),
            ),
          );
        }
      }

      cartItems.assignAll(loaded);
    } catch (e) {
      Get.log('Failed to load cart: $e');
    } finally {
      isLoading.value = false;
    }
  }

  //--------------------------------------------------
  // ADD TO CART
  //--------------------------------------------------

  /// Adds [quantity] of [product] (in the chosen [color]).
  /// Returns false if nothing was added.
  ///
  /// [onAdded] fires the moment the item lands in the local cart (before the
  /// Firestore write finishes) so the UI can play its fly-to-cart animation
  /// instantly instead of waiting on the network.
  Future<bool> addToCart(
    ProductModel product, {
    int quantity = 1,
    ProductColor? color,
    int imageIndex = 0,
    VoidCallback? onAdded,
  }) async {
    final uid = _uid;

    if (uid == null) {
      Get.snackbar(
        'Login Required',
        'Please login first',
        backgroundColor: Colors.black,
        colorText: Colors.white,
      );
      return false;
    }

    // Stock is shared by every colour of the product.
    var qty = quantity;

    if (product.stock > 0) {
      final room = product.stock - qtyInCartFor(product.id);

      if (room <= 0) {
        Get.snackbar(
          'Maximum reached',
          'All available units of this product are already in your cart.',
        );
        return false;
      }

      if (qty > room) qty = room;
    }

    final colorKey = color?.key ?? '';
    final lineId = CartItemModel.lineIdFor(product.id, colorKey);

    final index = cartItems.indexWhere((e) => e.lineId == lineId);

    if (index != -1) {
      cartItems[index].quantity += qty;
      cartItems.refresh();
    } else {
      cartItems.add(
        CartItemModel(
          product: product,
          quantity: qty,
          colorName: color?.name ?? '',
          colorHex: color?.hex ?? '',
          imageIndex: imageIndex,
        ),
      );
    }

    final item = cartItems.firstWhere((e) => e.lineId == lineId);

    onAdded?.call();

    await _itemsRef(uid).doc(lineId).set({
      'productId': product.id,
      'quantity': item.quantity,
      'colorName': item.colorName,
      'colorHex': item.colorHex,
      'imageIndex': item.imageIndex,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return true;
  }

  //--------------------------------------------------
  // REMOVE
  //--------------------------------------------------

  Future<void> removeItem(CartItemModel item) async {
    final lineId = item.lineId;

    cartItems.removeWhere((e) => e.lineId == lineId);

    final uid = _uid;
    if (uid == null) return;

    await _itemsRef(uid).doc(lineId).delete();
  }

  //--------------------------------------------------
  // QUANTITY
  //--------------------------------------------------

  Future<void> _saveQuantity(CartItemModel item) async {
    final uid = _uid;
    if (uid == null) return;

    await _itemsRef(uid).doc(item.lineId).update({
      'quantity': item.quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> increaseQty(CartItemModel item) async {
    final line = cartItems.firstWhereOrNull((e) => e.lineId == item.lineId);
    if (line == null) return;

    final stock = line.product.stock;
    if (stock > 0 && qtyInCartFor(line.product.id) >= stock) return;

    line.quantity++;
    cartItems.refresh();

    await _saveQuantity(line);
  }

  Future<void> decreaseQty(CartItemModel item) async {
    final line = cartItems.firstWhereOrNull((e) => e.lineId == item.lineId);
    if (line == null || line.quantity <= 1) return;

    line.quantity--;
    cartItems.refresh();

    await _saveQuantity(line);
  }

  //--------------------------------------------------
  // CLEAR
  //--------------------------------------------------

  Future<void> clearCart() async {
    final uid = _uid;
    if (uid == null) return;

    final items = await _itemsRef(uid).get();

    if (items.docs.isNotEmpty) {
      final batch = _firestore.batch();
      for (final doc in items.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }

    cartItems.clear();
  }
}
