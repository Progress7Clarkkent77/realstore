import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realstore/live/liveControllers/theme_controller.dart';
import 'package:realstore/live/userAuth/authController.dart';

//import 'package:url_launcher/url_launcher.dart';

class VerifiedController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _auth = Get.find<AuthController>();
  final ThemeController _themeCtrl = Get.find<ThemeController>();

  final RxBool isVerified = false.obs;
  final Rx<DateTime?> verifiedAt = Rx<DateTime?>(null);
  final Rx<DateTime?> verifiedExpiresAt = Rx<DateTime?>(null);
  final RxInt daysLeft = 0.obs;

  bool get _isDark => _themeCtrl.isDarkMode.value;
  String? get uid => _auth.currentUser?.uid;

  bool _listenerAttached = false;

  @override
  void onInit() {
    super.onInit();
    _waitForUserAndListen();
  }

  /* -------------------------------------------------------------------------- */
  /*                  ⏳ WAIT FOR AUTH THEN ATTACH LISTENER                      */
  /* -------------------------------------------------------------------------- */

  void _waitForUserAndListen() async {
    /// Wait until Firebase auth is hydrated (web-safe)
    while (_auth.currentUser == null) {
      await Future.delayed(const Duration(milliseconds: 200));
    }

    _listenToVerification();
  }

  /* -------------------------------------------------------------------------- */
  /*                         🔍 LISTEN TO USER STATUS                           */
  /* -------------------------------------------------------------------------- */

  void _listenToVerification() {
    if (uid == null || _listenerAttached) return;

    _listenerAttached = true;

    _firestore.collection('e-users').doc(uid).snapshots().listen((doc) {
      if (!doc.exists) return;

      final data = doc.data()!;

      isVerified.value = data['verified'] ?? false;
      verifiedAt.value = (data['verifiedAt'] as Timestamp?)?.toDate();
      verifiedExpiresAt.value = (data['verifiedExpiresAt'] as Timestamp?)
          ?.toDate();

      _checkExpiry();
    });
  }

  /* -------------------------------------------------------------------------- */
  /*                           ⏳ CHECK EXPIRY                                   */
  /* -------------------------------------------------------------------------- */

  // Future<void> _checkExpiry() async {
  //   if (verifiedExpiresAt.value == null || uid == null) return;

  //   final now = DateTime.now();
  //   final expiry = verifiedExpiresAt.value!;

  //   final remaining = expiry.difference(now).inDays;
  //   daysLeft.value = remaining < 0 ? 0 : remaining;

  //   if (now.isAfter(expiry) && isVerified.value) {
  //     await _firestore.collection('e-users').doc(uid).update({
  //       'verified': false,
  //       'verifiedAt': null,
  //       'verifiedExpiresAt': null,
  //     });

  //     isVerified.value = false;
  //     verifiedAt.value = null;
  //     verifiedExpiresAt.value = null;
  //     daysLeft.value = 0;
  //   }
  // }

  Future<void> _checkExpiry() async {
    if (verifiedExpiresAt.value == null || uid == null) return;

    final now = DateTime.now();
    final expiry = verifiedExpiresAt.value!;

    final remaining = expiry.difference(now).inDays;
    daysLeft.value = remaining > 0 ? remaining : 0;

    /// 🔥 EXPIRE IF DAYS LEFT IS 0 OR TIME PASSED
    if (remaining <= 0 && isVerified.value) {
      await _firestore.collection('e-users').doc(uid).update({
        'verified': false,
        'verifiedAt': null,
        'verifiedExpiresAt': null,
      });

      isVerified.value = false;
      verifiedAt.value = null;
      verifiedExpiresAt.value = null;
      daysLeft.value = 0;
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                     🔐 ACTIVATE / EXTEND VERIFICATION                       */
  /* -------------------------------------------------------------------------- */

  Future<void> _activateOrExtendVerification() async {
    if (uid == null) return;

    final now = DateTime.now();
    DateTime newExpiry;

    if (verifiedExpiresAt.value != null &&
        verifiedExpiresAt.value!.isAfter(now)) {
      newExpiry = verifiedExpiresAt.value!.add(const Duration(days: 30));
    } else {
      newExpiry = now.add(const Duration(days: 30));
    }

    await _firestore.collection('e-users').doc(uid).update({
      'verified': true,
      'verifiedAt': Timestamp.fromDate(now),
      'verifiedExpiresAt': Timestamp.fromDate(newExpiry),
    });

    _snack('Verified Successfully', 'Your verification is active');
  }

  /* -------------------------------------------------------------------------- */
  /*                              🔔 SNACKBAR                                   */
  /* -------------------------------------------------------------------------- */

  void _snack(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _isDark ? Colors.grey.shade900 : Colors.grey.shade100,
      colorText: _isDark ? Colors.white : Colors.black,
    );
  }
}
