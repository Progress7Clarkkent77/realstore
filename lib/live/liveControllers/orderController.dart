import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:realstore/live/liveControllers/ecommerceCartController.dart';
import 'package:realstore/live/liveControllers/storeConfig.dart';
import 'package:realstore/live/models/orderItemModel.dart';
import 'package:realstore/live/models/orderModel.dart';
import 'package:realstore/live/pages/ecommerce_routes.dart';
import 'package:realstore/live/userAuth/authController.dart';
//import 'package:realstore/services/paystack_integration.dart';
import 'package:realstore/services/paystack_service.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final EcommerceCartController cartCtrl = Get.find<EcommerceCartController>();
  final AuthController authCtrl = Get.find<AuthController>();

  final RxBool isPlacingOrder = false.obs;
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final Rxn<OrderModel> selectedOrder = Rxn<OrderModel>();

  /// Text shown on the checkout page's blur overlay while an order is processing.
  final RxString processingMessage = 'Please wait...'.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _ordersSub;
  StreamSubscription<User?>? _authSub;

  /// Longest we wait for the payment screen to report back.
  static const Duration _paymentTimeout = Duration(seconds: 30);

  /// Longest we keep the customer waiting while the order is written.
  static const Duration _orderWriteTimeout = Duration(seconds: 8);

  String _paymentError = '';

  //==================================================
  // LIFECYCLE
  //==================================================

  @override
  void onInit() {
    super.onInit();

    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _ordersSub?.cancel();
        orders.clear();
      } else {
        loadOrders();
        recoverPaidOrders();
      }
    });
  }

  @override
  void onClose() {
    _ordersSub?.cancel();
    _authSub?.cancel();
    super.onClose();
  }

  void selectOrder(OrderModel order) => selectedOrder.value = order;

  //==================================================
  // LOAD ORDERS
  //==================================================

  /// Requires a composite index: orders (customerUid ASC, createdAt DESC).
  Future<void> loadOrders() async {
    final uid = authCtrl.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    await _ordersSub?.cancel();

    _ordersSub = _firestore
        .collection(StoreConfig.ordersCollection)
        .where('customerUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) => orders.assignAll(
            snapshot.docs.map((d) => OrderModel.fromMap(d.id, d.data())),
          ),
          onError: (Object e) => Get.log('Orders stream error: $e'),
        );
  }

  //==================================================
  // PAYMENT
  //==================================================

  /// Returns true only when the payment screen reports success.
  /// A failure reason (if any) is stored in [_paymentError].
  Future<bool> purchaseProduct({
    required double amount,
    required String reference,
  }) async {
    _paymentError = '';

    final user = authCtrl.currentUser;

    if (user == null) {
      _paymentError = 'Please login to continue.';
      return false;
    }

    final email = user.email;

    if (email == null || email.isEmpty) {
      _paymentError = 'Unable to retrieve your email address.';
      return false;
    }

    final completer = Completer<bool>();

    try {
      await PaystackService.startPayment(
        context: Get.context!,
        email: email,
        amount: amount,
        reference: reference,
        onError: (String reason) {
          _paymentError = reason;
          if (!completer.isCompleted) completer.complete(false);
        },
        onSuccess: (Map<String, dynamic> paymentData) {
          if (!completer.isCompleted) completer.complete(true);
        },
      );
    } catch (e) {
      _paymentError = e.toString();
      if (!completer.isCompleted) completer.complete(false);
    }

    // The Paystack screen has closed. The callback normally fires right
    // away; if it did not, give it a moment, then ask Paystack directly.
    if (!completer.isCompleted) {
      processingMessage.value = 'Confirming your payment...';
      await Future.delayed(const Duration(seconds: 3));
    }

    if (!completer.isCompleted) {
      final status = await PaystackService.verify(reference);

      if (!completer.isCompleted) {
        if (status == 'success') {
          completer.complete(true);
        } else {
          _paymentError = status == null
              ? 'We could not confirm your payment. If you were charged, '
                    'please contact support with reference $reference.'
              : 'The payment was not completed.';
          completer.complete(false);
        }
      }
    }

    return completer.future.timeout(
      _paymentTimeout,
      onTimeout: () {
        _paymentError =
            'We could not confirm your payment. If you were charged, please '
            'contact support with reference $reference.';
        return false;
      },
    );
  }

  //==================================================
  // SAVED SHIPPING DETAILS
  //==================================================

  DocumentReference<Map<String, dynamic>>? get _shippingRef {
    final uid = authCtrl.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;

    return _firestore.collection(StoreConfig.shippingCollection).doc(uid);
  }

  /// Returns {'phone': ..., 'address': ...} or null when nothing is saved.
  Future<Map<String, String>?> loadSavedShipping() async {
    final ref = _shippingRef;
    if (ref == null) return null;

    try {
      final doc = await ref.get();
      final data = doc.data();
      if (!doc.exists || data == null) return null;

      final phone = (data['phone'] ?? '').toString();
      final address = (data['address'] ?? '').toString();

      if (phone.isEmpty && address.isEmpty) return null;

      return {'phone': phone, 'address': address};
    } catch (e) {
      Get.log('Failed to load saved shipping details: $e');
      return null;
    }
  }

  Future<void> saveShipping({
    required String phone,
    required String address,
  }) async {
    final ref = _shippingRef;
    if (ref == null) return;

    try {
      await ref.set({
        'phone': phone,
        'address': address,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      Get.log('Failed to save shipping details: $e');
    }
  }

  Future<void> clearSavedShipping() async {
    try {
      await _shippingRef?.delete();
    } catch (e) {
      Get.log('Failed to clear shipping details: $e');
    }
  }

  //==================================================
  // PENDING ORDER SAFETY NET
  //==================================================

  /// A draft of every order is saved here BEFORE payment starts, and flagged
  /// `paid: true` the moment payment succeeds. If the app is closed, crashes
  /// or loses signal before the real order is written, [recoverPaidOrders]
  /// finishes the job next time the customer opens the app.
  static const String _pendingCollection = 'pendingOrders';

  DocumentReference<Map<String, dynamic>> _pendingDoc(String reference) =>
      _firestore.collection(_pendingCollection).doc(reference);

  Future<void> recoverPaidOrders() async {
    if (isPlacingOrder.value) return;

    final uid = authCtrl.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    try {
      final pending = await _firestore
          .collection(_pendingCollection)
          .where('customerUid', isEqualTo: uid)
          .where('paid', isEqualTo: true)
          .get();

      for (final doc in pending.docs) {
        final orderRef = _firestore
            .collection(StoreConfig.ordersCollection)
            .doc(doc.id);

        if (!(await orderRef.get()).exists) {
          final data = Map<String, dynamic>.from(doc.data())..remove('paid');
          await orderRef.set(data);
        }

        await doc.reference.delete();
      }
    } catch (e) {
      Get.log('Failed to recover pending orders: $e');
    }
  }

  //==================================================
  // PLACE ORDER
  //==================================================

  Future<bool> placeOrder({
    required String phone,
    required String address,
    bool rememberShipping = true,
  }) async {
    if (isPlacingOrder.value) return false;

    if (cartCtrl.cartItems.isEmpty) {
      Get.snackbar('Cart Empty', 'Add items to your cart first');
      return false;
    }

    final user = authCtrl.currentUser;

    if (user == null) {
      Get.snackbar('Login Required', 'Please login to continue');
      return false;
    }

    // Snapshot everything BEFORE payment, so the moment payment succeeds we
    // can write the order without any further preparation.
    final reference = 'order-${DateTime.now().millisecondsSinceEpoch}';
    final subtotal = cartCtrl.subtotal;
    final deliveryFee = cartCtrl.deliveryFee;
    final totalAmount = cartCtrl.grandTotal;
    final deliveryZone =
        cartCtrl.deliveryZone.value.name; // 'enugu' | 'outside'

    final items = cartCtrl.cartItems
        .map(
          (e) => OrderItemModel(
            productId: e.product.id,
            productName: e.product.name,
            price: e.product.price,
            quantity: e.quantity,
            // the image that shows the colour the customer chose
            image: e.image,
            colorName: e.colorName,
            colorHex: e.colorHex,
          ),
        )
        .toList();

    var paymentConfirmed = false;

    try {
      // Locks the checkout page (blur + back button blocked) straight away.
      isPlacingOrder.value = true;
      processingMessage.value = 'Opening secure payment...';

      final customerName = await _resolveCustomerName(user);

      // The payment reference doubles as the order id, so writing the same
      // order twice can never create a duplicate.
      final orderRef = _firestore
          .collection(StoreConfig.ordersCollection)
          .doc(reference);

      final order = OrderModel(
        id: reference,
        customerUid: user.uid,
        customerName: customerName,
        customerPhoneNumber: phone,
        customerDeliveryAddress: address,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        totalAmount: totalAmount,
        deliveryZone: deliveryZone,
        delivered: false,
        currentLocation: 'Order Received',
        status: 'Pending',
        items: items,
      );

      final orderData = {...order.toMap(), 'paymentReference': reference};

      // 1. Save a draft first, so the order is never lost.
      unawaited(
        _pendingDoc(reference)
            .set({...orderData, 'customerUid': user.uid, 'paid': false})
            .catchError((_) {}),
      );

      // 2. Payment.
      final paid = await purchaseProduct(
        amount: totalAmount,
        reference: reference,
      );

      if (!paid) {
        unawaited(_pendingDoc(reference).delete().catchError((_) {}));

        // Fail fast: unlock the page, then tell the customer right away.
        isPlacingOrder.value = false;

        await _showResultDialog(
          icon: Icons.cancel,
          color: Colors.red,
          title: 'Payment Unsuccessful',
          message: _friendlyPaymentMessage(),
        );
        return false;
      }

      paymentConfirmed = true;
      processingMessage.value = 'Payment successful.\nPlacing your order...';

      // 3. Flag the draft as paid (queued locally even if offline).
      unawaited(
        _pendingDoc(reference)
            .set({'paid': true}, SetOptions(merge: true))
            .catchError((_) {}),
      );

      // 4. Write the real order, but never keep the customer waiting long.
      final write = orderRef.set(orderData);
      var confirmedByServer = true;

      try {
        await write.timeout(_orderWriteTimeout);
      } on TimeoutException {
        // Firestore keeps the write queued and syncs it as soon as the
        // connection allows.
        confirmedByServer = false;
      }

      // Once the order really lands on the server, remove the draft.
      unawaited(
        write.then((_) => _pendingDoc(reference).delete()).catchError((_) {}),
      );

      // Everything below is non-critical, so it must never delay the customer.
      if (rememberShipping) {
        unawaited(saveShipping(phone: phone, address: address));
      }
      unawaited(cartCtrl.clearCart());

      // Go straight to the home page, then ask whether to view the order.
      unawaited(Get.offAllNamed(EcommerceLiveRoutes.home));
      unawaited(
        _askToViewOrder(
          confirmedByServer: confirmedByServer,
          reference: reference,
        ),
      );

      return true;
    } catch (e) {
      // Unlock first so the customer can always see and dismiss the dialog.
      isPlacingOrder.value = false;

      if (paymentConfirmed) {
        // Money was taken but the order could not be saved right now.
        // The paid draft is kept and recovered automatically next time.
        await _showResultDialog(
          icon: Icons.error_outline_rounded,
          color: Colors.red,
          title: 'Order Not Saved',
          message:
              'Your payment was received but we could not record your '
              'order yet. We will retry automatically. If it does not '
              'appear in My Orders, please contact support with '
              'reference $reference.',
        );
      } else {
        await _showResultDialog(
          icon: Icons.cancel,
          color: Colors.red,
          title: 'Order Unsuccessful',
          message:
              'Something went wrong and your order was not placed. '
              'You have not been charged. Please try again.',
        );
      }

      return false;
    } finally {
      isPlacingOrder.value = false;
    }
  }

  /// Shown on the home page after a successful order.
  /// Yes -> orders page, No -> stays on home.
  Future<void> _askToViewOrder({
    required bool confirmedByServer,
    required String reference,
  }) async {
    // Let the home page finish appearing before the dialog opens over it.
    await Future.delayed(const Duration(milliseconds: 500));

    final message = confirmedByServer
        ? 'Your payment was received and your order has been placed '
              'successfully.'
        : 'Your payment was successful and your order is being confirmed. '
              'It will appear in My Orders shortly. If it does not, please '
              'contact support with reference $reference.';

    await Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              confirmedByServer
                  ? Icons.check_circle
                  : Icons.hourglass_top_rounded,
              color: confirmedByServer ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                confirmedByServer ? 'Order Successful' : 'Payment Received',
              ),
            ),
          ],
        ),
        content: Text('$message\n\nWould you like to view your order?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.toNamed(EcommerceLiveRoutes.orders);
            },
            child: const Text(
              'Yes',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  String _friendlyPaymentMessage() {
    final reason = _paymentError.trim();

    if (reason.isEmpty) {
      return 'Your order was not completed because the payment was '
          'unsuccessful or cancelled. You have not been charged.';
    }

    return 'Your order was not completed because the payment was '
        'unsuccessful.\n\n$reason';
  }

  /// Uses the name saved at signup (e-users/{uid}.name); falls back to email.
  Future<String> _resolveCustomerName(User user) async {
    try {
      final doc = await _firestore
          .collection('e-users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 4));
      final name = (doc.data()?['name'] ?? '').toString().trim();
      if (name.isNotEmpty) return name;
    } catch (_) {}
    return user.email ?? '';
  }

  //==================================================
  // DIALOGS
  //==================================================

  Future<void> _showResultDialog({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    String confirmLabel = 'OK',
  }) async {
    await Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              confirmLabel,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
