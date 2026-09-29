import 'dart:async';
import 'dart:ui';

import 'package:realstore/live/liveControllers/ecommerceCartController.dart';
import 'package:realstore/live/models/orderItemModel.dart';
import 'package:realstore/live/models/orderModel.dart';
import 'package:realstore/live/pages/ecommerce_routes.dart';
import 'package:realstore/live/userAuth/authController.dart';
import 'package:realstore/platformControllers/domainController.dart';
import 'package:realstore/services/paystack_integration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final cartCtrl = Get.find<EcommerceCartController>();

  final authCtrl = Get.find<AuthController1>();

  final domainCtrl = Get.find<DomainController>();

  final RxBool isPlacingOrder = false.obs;

  final Rxn<OrderModel> selectedOrder = Rxn<OrderModel>();

  @override
  void onInit() {
    super.onInit();

    loadOrders();
  }

  void selectOrder(OrderModel order) {
    selectedOrder.value = order;
  }

  final RxList<OrderModel> orders = <OrderModel>[].obs;

  StreamSubscription? _ordersSub;

  Future<void> loadOrders() async {
    final uid = authCtrl.currentUser?.uid ?? '';

    final orgId = domainCtrl.organizationId.value;

    if (uid.isEmpty || orgId.isEmpty) {
      return;
    }

    await _ordersSub?.cancel();

    _ordersSub = _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('orders')
        .where('customerUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          orders.assignAll(
            snapshot.docs.map((doc) {
              return OrderModel.fromMap(doc.id, doc.data());
            }),
          );
        });
  }

  Future<bool> purchaseProduct({required double amount}) async {
    final user = authCtrl.currentUser;

    if (user == null) {
      Get.snackbar("Login Required", "Please login to continue");
      return false;
    }

    final email = user.email;

    if (email == null || email.isEmpty) {
      Get.snackbar("Error", "Unable to retrieve user email");
      return false;
    }

    final completer = Completer<bool>();

    PaystackPopup.openPaystackPopup(
      email: email,
      amount: (amount * 100).round().toString(),
      ref: "order-${DateTime.now().millisecondsSinceEpoch}",
      onClosed: () {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
      onSuccess: () {
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      },
    );

    return completer.future;
  }

  Future<bool> placeOrder({
    required String phone,
    required String address,
  }) async {
    try {
      final paymentSuccess = await purchaseProduct(amount: cartCtrl.grandTotal);

      if (!paymentSuccess) {
        await showPaymentFailedDialog();
        return false;
      }

      showPlacingOrderDialog();

      isPlacingOrder.value = true;

      final uid = authCtrl.currentUser?.uid ?? '';

      final customerEmail = authCtrl.currentUser?.email ?? '';

      final orgId = domainCtrl.organizationId.value;

      final items = cartCtrl.cartItems.map((e) {
        return OrderItemModel(
          productId: e.product.id,
          productName: e.product.name,
          price: e.product.price,
          quantity: e.quantity,
          image: e.product.images.isEmpty ? '' : e.product.images.first,
        );
      }).toList();

      final orderRef = _firestore
          .collection('organizations')
          .doc(orgId)
          .collection('orders')
          .doc();

      final order = OrderModel(
        id: orderRef.id,
        organizationId: orgId,
        customerUid: uid,
        customerName: customerEmail,
        customerPhoneNumber: phone,
        customerDeliveryAddress: address,
        subtotal: cartCtrl.subtotal,
        deliveryFee: cartCtrl.deliveryFee,
        totalAmount: cartCtrl.grandTotal,
        delivered: false,
        currentLocation: 'Order Received',
        status: 'Pending',
        items: items,
      );

      await orderRef.set(order.toMap());

      await cartCtrl.clearCart();

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.offNamed(EcommerceLiveRoutes.orders);

      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text("Order Successful"),
            ],
          ),
          content: const Text("Your order has been placed successfully."),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text(
                "Continue",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      return true;
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar("Error", e.toString());

      return false;
    } finally {
      isPlacingOrder.value = false;
    }
  }

  void showPlacingOrderDialog() {
    Get.dialog(
      PopScope(
        canPop: false,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  width: 45,
                  height: 45,
                  child: CircularProgressIndicator(color: Colors.black),
                ),
                SizedBox(height: 20),
                Text(
                  "Placing Order...",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  "Please wait while we process your order.",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> showPaymentFailedDialog() async {
    await Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 10),
            Text("Payment Failed"),
          ],
        ),
        content: const Text(
          "Your order was not completed because payment was unsuccessful.",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("OK", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
