import 'dart:async';

import 'package:realstore/platformControllers/domainController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'dart:async';

class EcommerceAdminDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final DomainController domainCtrl = Get.find<DomainController>();

  final RxBool isLoading = true.obs;

  final RxInt productCount = 0.obs;
  final RxInt orderCount = 0.obs;
  final RxInt customerCount = 0.obs;

  final RxDouble revenue = 0.0.obs;

  StreamSubscription? _productsSub;
  StreamSubscription? _ordersSub;
  Worker? _orgWorker;

  @override
  void onInit() {
    super.onInit();

    _initializeDashboard();
  }

  void _initializeDashboard() {
    if (domainCtrl.organizationId.value.isNotEmpty) {
      startRealtimeListeners();
      return;
    }

    _orgWorker = ever(domainCtrl.organizationId, (String orgId) {
      if (orgId.isNotEmpty) {
        startRealtimeListeners();
        _orgWorker?.dispose();
      }
    });
  }

  void startRealtimeListeners() {
    final orgId = domainCtrl.organizationId.value;

    if (orgId.isEmpty) return;

    isLoading.value = true;

    _productsSub?.cancel();
    _ordersSub?.cancel();

    //---------------------------------------
    // PRODUCTS REALTIME
    //---------------------------------------

    _productsSub = _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('products')
        .snapshots()
        .listen((snapshot) {
          productCount.value = snapshot.docs.length;
        });

    //---------------------------------------
    // ORDERS REALTIME
    //---------------------------------------

    _ordersSub = _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('orders')
        .snapshots()
        .listen((snapshot) {
          orderCount.value = snapshot.docs.length;

          final customers = <String>{};

          double totalRevenue = 0;

          for (final doc in snapshot.docs) {
            final data = doc.data();

            final customerId = data['customerId'] ?? '';

            if (customerId.toString().isNotEmpty) {
              customers.add(customerId);
            }

            final delivered = data['isDelivered'] ?? false;

            if (delivered == true) {
              totalRevenue += (data['totalAmount'] ?? 0).toDouble();
            }
          }

          customerCount.value = customers.length;

          revenue.value = totalRevenue;

          isLoading.value = false;
        });
  }

  Future<void> loadDashboard() async {
    startRealtimeListeners();
  }

  String formatAmount(double value) {
    if (value >= 1000000) {
      return '₦${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '₦${(value / 1000).toStringAsFixed(1)}K';
    }

    return '₦${value.toStringAsFixed(2)}';
  }

  @override
  void onClose() {
    _productsSub?.cancel();
    _ordersSub?.cancel();
    _orgWorker?.dispose();
    super.onClose();
  }
}
