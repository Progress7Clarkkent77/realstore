import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:realstore/live/liveControllers/theme_controller.dart';
import 'package:realstore/live/userAuth/authController.dart';

import 'package:url_launcher/url_launcher.dart';

// class ReferController extends GetxController {
//   final RewardController rewardController = Get.find<RewardController>();
//   final AuthController authController = Get.find<AuthController>();
//   final ThemeController themeController = Get.find<ThemeController>();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   final TextEditingController linkController = TextEditingController();

//   final RxString selectedPlatform = ''.obs;

//   final RxBool submitting = false.obs;

//   final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> submissions =
//       <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;

//   StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
//       _submissionSubscription;

//   final List<String> platforms = [
//     'TikTok',
//     'Facebook',
//     'Instagram',
//   ];

//   @override
//   void onInit() {
//     super.onInit();
//     loadMySubmissions();
//   }

//   @override
//   void onClose() {
//     _submissionSubscription?.cancel();
//     linkController.dispose();
//     super.onClose();
//   }

//   /// 🔗 Build referral text dynamically using user doc ID
//   String _buildReferText(String uid) {
//     final referralLink = 'https://Textido.com/$uid';

//     return '''
// Textido is 100% Legit

// Click the link below, sign up, and log in:
// $referralLink

// Once inside, you earn money for every action—posting daily, reacting to posts, chatting, and even when people react to your posts.
// ''';
//   }

//   /// 🔔 Themed Snackbar (Dark / Light aware)
//   void _showSnackbar(String title, String message) {
//     final isDark = themeController.isDarkMode.value;

//     Get.snackbar(
//       title,
//       message,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
//       colorText: isDark ? Colors.white : Colors.black,
//       borderRadius: 12,
//       margin: const EdgeInsets.all(12),
//     );
//   }

//   void loadMySubmissions() {
//     final uid = authController.currentUser?.uid;

//     if (uid == null) return;

//     _submissionSubscription?.cancel();

//     _submissionSubscription = _firestore
//         .collection('promotionSubmissions1')
//         .where('uid', isEqualTo: uid)
//         .snapshots()
//         .listen(
//       (snapshot) {
//         final docs = snapshot.docs;

//         docs.sort((a, b) {
//           final ta = a.data()['submittedAt'] as Timestamp?;
//           final tb = b.data()['submittedAt'] as Timestamp?;

//           if (ta == null && tb == null) return 0;
//           if (ta == null) return 1;
//           if (tb == null) return -1;

//           return tb.compareTo(ta);
//         });

//         submissions.assignAll(docs);
//       },
//       onError: (e) {
//         _showSnackbar(
//           'Error',
//           e.toString(),
//         );
//       },
//     );
//   }

//   /// Submit promotion (Maximum 3 submissions per day)
//   Future<void> submitPromotion({
//     required String userName,
//     required String userEmail,
//   }) async {
//     final uid = authController.currentUser?.uid;

//     if (uid == null) return;

//     final link = linkController.text.trim();

//     if (link.isEmpty) {
//       _showSnackbar(
//         'Missing Link',
//         'Please paste your content link.',
//       );
//       return;
//     }

//     if (selectedPlatform.value.isEmpty) {
//       _showSnackbar(
//         'Platform Required',
//         'Please select a social platform.',
//       );
//       return;
//     }

//     final uri = Uri.tryParse(link);

//     if (uri == null || !uri.hasAbsolutePath) {
//       _showSnackbar(
//         'Invalid Link',
//         'Please enter a valid public URL.',
//       );
//       return;
//     }

//     try {
//       submitting.value = true;

//       final now = DateTime.now();

//       int todayCount = 0;

//       for (final doc in submissions) {
//         final timestamp = doc.data()['submittedAt'] as Timestamp?;

//         if (timestamp == null) continue;

//         final date = timestamp.toDate();

//         if (date.year == now.year &&
//             date.month == now.month &&
//             date.day == now.day) {
//           todayCount++;
//         }
//       }

//       if (todayCount >= 3) {
//         _showSnackbar(
//           'Daily Limit Reached',
//           'You can only submit 3 promotions per day.',
//         );
//         return;
//       }

//       await _firestore.collection('promotionSubmissions1').add({
//         'uid': uid,
//         'name': userName,
//         'email': userEmail,
//         'platform': selectedPlatform.value,
//         'link': link,
//         'status': false,
//         'rewardGiven': false,
//         'submittedAt': FieldValue.serverTimestamp(),
//         'reviewedAt': null,
//       });

//       linkController.clear();
//       selectedPlatform.value = '';

//       _showSnackbar(
//         'Submitted',
//         'Your promotion has been submitted for review.',
//       );
//     } catch (e) {
//       _showSnackbar(
//         'Submission Failed',
//         e.toString(),
//       );
//     } finally {
//       submitting.value = false;
//     }
//   }

//   /// Admin approves submission
//   Future<void> approveSubmission(String documentId) async {
//     try {
//       final docRef =
//           _firestore.collection('promotionSubmissions1').doc(documentId);

//       final doc = await docRef.get();

//       if (!doc.exists) return;

//       final data = doc.data()!;

//       if (data['rewardGiven'] == true) {
//         return;
//       }

//       await docRef.update({
//         'status': true,
//         'rewardGiven': true,
//         'reviewedAt': FieldValue.serverTimestamp(),
//       });

//       await rewardController.incrementRefer(
//         uid: data['uid'],
//       );
//     } catch (_) {}
//   }

//   /// Admin rejects (keeps pending false)
//   Future<void> rejectSubmission(String documentId) async {
//     await _firestore
//         .collection('promotionSubmissions1')
//         .doc(documentId)
//         .update({
//       'status': false,
//       'reviewedAt': FieldValue.serverTimestamp(),
//     });
//   }

//   String statusText(bool status) {
//     return status ? 'Approved' : 'Pending';
//   }

//   Color statusColor(bool status) {
//     return status ? Colors.green : Colors.orange;
//   }

// //===========================================================================================================//
//   // Share to WhatsApp////////////////////////////////
//   //===========================================================================================================//

//   /// 🔗 Share referral ONCE per day
//   Future<void> shareToWhatsAppStatus() async {
//     final uid = authController.currentUser?.uid;
//     if (uid == null) return;

//     try {
//       final userRef = _firestore.collection('e-users').doc(uid);
//       final userDoc = await userRef.get();

//       DateTime? lastReferDate;
//       if (userDoc.exists && userDoc.data()?['lastReferDate'] != null) {
//         lastReferDate =
//             (userDoc.data()!['lastReferDate'] as Timestamp).toDate();
//       }

//       final now = DateTime.now();

//       final alreadySharedToday = lastReferDate != null &&
//           lastReferDate.year == now.year &&
//           lastReferDate.month == now.month &&
//           lastReferDate.day == now.day;

//       if (alreadySharedToday) {
//         _showSnackbar(
//           'Already Shared',
//           'You can only share once per day. Try again tomorrow.',
//         );
//         return;
//       }

//       final referText = _buildReferText(uid);

//       // 📋 Always copy first (Status UX)
//       await Clipboard.setData(ClipboardData(text: referText));

//       // ✅ OFFICIAL WhatsApp entry (works on Android)
//       final uri = Uri.parse(
//         'https://wa.me/?text=${Uri.encodeComponent(referText)}',
//       );

//       if (!await canLaunchUrl(uri)) {
//         _showSnackbar(
//           'WhatsApp Error',
//           'Unable to open WhatsApp.',
//         );
//         return;
//       }

//       await launchUrl(
//         uri,
//         mode: LaunchMode.externalApplication,
//       );

//       // 🎁 Reward
//       await rewardController.incrementRefer(uid: uid);

//       // 💾 Save date
//       await userRef.update({
//         'lastReferDate': Timestamp.fromDate(now),
//       });

//       _showSnackbar(
//         'Almost Done',
//         'WhatsApp opened. Tap “My Status” to post.',
//       );
//     } catch (e) {
//       _showSnackbar(
//         'Error',
//         'Unable to share referral right now.',
//       );
//     }
//   }
// }

/// 🔹 Referral system, code-based:
/// - Every user has a 6-digit `referCode` on their e-users doc, generated
///   by AuthController (on signup, and backfilled on login).
/// - This controller just displays that code as simple, copiable text —
///   no submissions, no admin approval.
/// - The actual reward is handled entirely by AuthController: when a new
///   user who entered someone's referCode at signup gets their `verify`
///   field set to true, that referrer is rewarded automatically (once).
class ReferController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final ThemeController themeController = Get.find<ThemeController>();

  final RxString referCode = ''.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadReferCode();
  }

  /// 🔢 Loads this user's referCode, generating + saving one first if the
  /// field somehow isn't set yet (AuthController already does this on
  /// every login/signup — this is just a safety net for the refer page).
  Future<void> loadReferCode() async {
    final uid = authController.currentUser?.uid;

    if (uid == null) {
      isLoading.value = false;
      return;
    }

    try {
      final code = await authController.ensureReferCode(uid);
      referCode.value = code;
    } catch (e) {
      _showSnackbar(
        'Error',
        'Could not load your referral code. Pull to refresh and try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔗 The exact copiable referral message, built with this user's code.
  String get referralText {
    final code = referCode.value;

    return '''
RealStore is 100% Legit! 🎉

Download RealStore and sign up with my referral code: $code, Log in, verify your email & start earning rewards by:

• Liking Available Products.
''';
  }

  /// 🔔 Themed Snackbar (Dark / Light aware)
  void _showSnackbar(String title, String message) {
    final isDark = themeController.isDarkMode.value;

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
      colorText: isDark ? Colors.white : Colors.black,
      borderRadius: 12,
      margin: const EdgeInsets.all(12),
    );
  }

  /// 📋 Copy the full referral message to the clipboard.
  Future<void> copyReferralText() async {
    if (referCode.value.isEmpty) {
      _showSnackbar('Not ready', 'Your referral code is still loading.');
      return;
    }

    await Clipboard.setData(ClipboardData(text: referralText));

    _showSnackbar('Copied', 'Referral message copied to clipboard.');
  }

  /// 🔗 Open WhatsApp with the referral message prefilled. No reward is
  /// tied to sharing itself — the reward only fires once someone who
  /// actually used this code verifies their email (see AuthController).
  Future<void> shareToWhatsApp() async {
    if (referCode.value.isEmpty) {
      _showSnackbar('Not ready', 'Your referral code is still loading.');
      return;
    }

    final uri = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(referralText)}',
    );

    if (!await canLaunchUrl(uri)) {
      _showSnackbar('WhatsApp Error', 'Unable to open WhatsApp.');
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
