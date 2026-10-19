import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:realstore/live/liveControllers/moderation_controller.dart';
import 'package:realstore/live/liveControllers/r_controller.dart';
import 'package:realstore/live/liveControllers/theme_controller.dart';
import 'package:realstore/live/userAuth/account_controller.dart';
import 'package:realstore/live/userAuth/authController.dart';

//============================================================================//

class StatusController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _auth = Get.find<AuthController>();
  //final Blockchain _blockchain = Blockchain();
  final RController _RCtrl = Get.find<RController>();
  //final ModerationController _moderation = Get.find<ModerationController>();
  ModerationController get _moderation => Get.find<ModerationController>();

  final RxString searchQuery = ''.obs;
  final RxList<DocumentSnapshot> statuses = <DocumentSnapshot>[].obs;
  final Rx<DateTime?> lastStatusPostAt = Rx<DateTime?>(null);
  final RxMap<String, String?> _avatarCache = <String, String?>{}.obs;
  // final Rx<Uint8List?> selectedImageBytes = Rx<Uint8List?>(null);
  // final ImagePicker _picker = ImagePicker();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();
  final RxInt visibleCount = 8.obs;
  final RxBool isLoadingMore = false.obs;
  final int maxLimit = 300;

  /// 🔹 Mirrors ChatController.isSending — lets the comment send button
  /// switch to a spinner and stops double taps from firing two posts.
  final RxBool isPostingComment = false.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToStatuses();
    _loadLastPostDate();
    startProductLikesListener();
  }

  @override
  void onClose() {
    _likedProductsSub?.cancel();
    super.onClose();
  }

  // Future<void> loadMore() async {
  //   if (isLoadingMore.value) return;

  //   if (visibleCount.value >= statuses.length) return;

  //   if (visibleCount.value >= maxLimit) return;

  //   isLoadingMore.value = true;

  //   await Future.delayed(
  //       const Duration(milliseconds: 500)); // simulate smooth loading

  //   visibleCount.value += 10;

  //   if (visibleCount.value > maxLimit) {
  //     visibleCount.value = maxLimit;
  //   }

  //   if (visibleCount.value > statuses.length) {
  //     visibleCount.value = statuses.length;
  //   }

  //   isLoadingMore.value = false;
  // }

  Future<void> loadMore() async {
    if (isLoadingMore.value) return;

    isLoadingMore.value = true;

    await Future.delayed(const Duration(milliseconds: 500));

    visibleCount.value += 10;

    if (visibleCount.value > maxLimit) {
      visibleCount.value = maxLimit;
    }

    isLoadingMore.value = false;
  }

  /// 🔹 Real-time listener for statuses
  // void _listenToStatuses() {
  //   _firestore
  //       .collection('status')
  //       .orderBy('timestamp', descending: true)
  //       .snapshots()
  //       .listen((snapshot) async {
  //     statuses.value = snapshot.docs;

  //     // Preload verified statuses for all emails
  //     for (var doc in snapshot.docs) {
  //       final email = (doc.data())['email'] ?? '';
  //       if (email.isNotEmpty && !_verifiedCache.containsKey(email)) {
  //         final verified = await fetchUserVerifiedStatus(email);
  //         _verifiedCache[email] = verified;
  //       }
  //     }
  //   });
  // }

  void _listenToStatuses() {
    _firestore
        .collection('status')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .listen((snapshot) async {
          statuses.value = snapshot.docs;

          for (var doc in snapshot.docs) {
            final email = (doc.data())['email'] ?? '';

            if (email.isEmpty) continue;

            /// ✅ VERIFIED CACHE
            if (!_verifiedCache.containsKey(email)) {
              final verified = await fetchUserVerifiedStatus(email);
              _verifiedCache[email] = verified;
            }

            /// ✅ AVATAR CACHE
            if (!_avatarCache.containsKey(email)) {
              final avatar = await fetchStatusUserAvatarName(email);
              _avatarCache[email] = avatar;
            }
          }
        });
  }

  String? getCachedAvatar(String email) {
    return _avatarCache[email];
  }

  bool getCachedVerified(String email) {
    return _verifiedCache[email] ?? false;
  }

  void _loadLastPostDate() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('e-users').doc(user.uid).get();

    final ts = doc.data()?['lastStatusPostAt'] as Timestamp?;
    lastStatusPostAt.value = ts?.toDate();
  }

  Future<void> pickImageFromDevice() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (picked != null) {
        selectedImage.value = File(picked.path);
      }
    } catch (e) {
      print("❌ Error picking image: $e");
    }
  }

  // ───────────────────── PRODUCT LIKES ─────────────────────
  // Same "likes: [uid, ...]" pattern as toggleLike() above, applied to product
  // documents so the store reuses this controller (no new controller).

  /// Firestore collection that holds your products. Change if yours differs.
  static const String _productsCollection = 'products';

  /// Product ids the signed-in user has liked (drives the heart on each card).
  final RxSet<String> likedProductIds = <String>{}.obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _likedProductsSub;
  String? _likedListenerUid;

  /// Safe to call many times: only re-subscribes when the signed-in user changes.
  Future<void> startProductLikesListener() async {
    final user = _auth.currentUser;

    if (user == null) {
      _likedProductsSub?.cancel();
      _likedProductsSub = null;
      _likedListenerUid = null;
      likedProductIds.clear();
      return;
    }

    if (_likedListenerUid == user.uid && _likedProductsSub != null) return;

    _likedProductsSub?.cancel();
    _likedListenerUid = user.uid;

    _likedProductsSub = _firestore
        .collection(_productsCollection)
        .where('likes', arrayContains: user.uid)
        .snapshots()
        .listen(
          (snap) => likedProductIds.assignAll(snap.docs.map((d) => d.id)),
          onError: (e) => print('❌ Error listening to liked products: $e'),
        );
  }

  bool isProductLiked(String productId) => likedProductIds.contains(productId);

  Future<void> toggleProductLike(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await startProductLikesListener();

    final uid = user.uid;
    final docRef = _firestore.collection(_productsCollection).doc(productId);

    final wasLiked = likedProductIds.contains(productId);

    // Optimistic UI
    if (wasLiked) {
      likedProductIds.remove(productId);
    } else {
      likedProductIds.add(productId);
    }

    try {
      await docRef.update({
        'likes': wasLiked
            ? FieldValue.arrayRemove([uid])
            : FieldValue.arrayUnion([uid]),
      });

      // No R is given when unliking.
      if (!wasLiked) {
        await handleProductLikeR(productId: productId, userUid: uid);
      }
    } catch (e) {
      // Roll back if the write failed
      if (wasLiked) {
        likedProductIds.add(productId);
      } else {
        likedProductIds.remove(productId);
      }

      print('❌ Error toggling product like: $e');

      Get.snackbar(
        'Could not update like',
        'Please check your connection and try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Each user can receive this R only once per product.
  Future<void> handleProductLikeR({
    required String productId,
    required String userUid,
  }) async {
    try {
      final RRef = _firestore
          .collection('productRs')
          .doc(userUid)
          .collection('productLikes')
          .doc(productId);

      // 🛑 Prevent Ring the same user twice for the same product.
      final RSnap = await RRef.get();

      if (RSnap.exists) {
        print("ℹ️ Product like r already given to $userUid for $productId");
        return;
      }

      await _RCtrl.incrementTinyR(uid: userUid);

      await RRef.set({
        'Red': true,
        'productId': productId,
        'userUid': userUid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("R $userUid for liking product $productId");
    } catch (e) {
      print("❌ Error r product like: $e");
    }
  }

  /// 🔹 Copy a status text
  void copyStatus(String text) {
    Clipboard.setData(ClipboardData(text: text));

    final ThemeController themeCtrl = Get.find<ThemeController>();
    final bool isDark = themeCtrl.isDarkMode.value;

    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      titleText: Text(
        'Copied',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      messageText: Text(
        'Status copied to clipboard',
        style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.black87),
      ),
      duration: const Duration(seconds: 2),
    );
  }

  /// 🔹 Filtered and sorted statuses
  List<DocumentSnapshot> get filteredStatuses {
    final query = searchQuery.value.toLowerCase();

    //Step 1: Filter by search query
    List<DocumentSnapshot> list = statuses.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final name = (data['name'] ?? '').toString().toLowerCase();
      return query.isEmpty || name.contains(query);
    }).toList();

    list.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;

      final aTs =
          (aData['timestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);
      final bTs =
          (bData['timestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);

      // 1️⃣ Sort by day (most recent day first)
      final aDay = DateTime(aTs.year, aTs.month, aTs.day);
      final bDay = DateTime(bTs.year, bTs.month, bTs.day);
      final dayCompare = bDay.compareTo(aDay);
      if (dayCompare != 0) return dayCompare;

      // 2️⃣ Determine user rank
      int rankFor(Map<String, dynamic> data) {
        final name = (data['name'] ?? '').toString().trim().toLowerCase();
        final email = data['email'] ?? '';
        final isVerified = _verifiedCache[email] ?? false;

        if (isVerified) return 0; // ✅ verified first
        if (name.isEmpty || name == 'unknown' || name == 'anonymous user') {
          return 2; // 🕵️ anonymous last
        }
        return 1; // 👤 normal user
      }

      final rankCompare = rankFor(aData).compareTo(rankFor(bData));
      if (rankCompare != 0) return rankCompare;

      // 3️⃣ Same tier → newest first
      return bTs.compareTo(aTs);
    });

    return list.take(visibleCount.value).toList();
  }

  /// 🔹 Stream comments for a particular status
  Stream<QuerySnapshot> commentStream(String statusId) {
    return _firestore
        .collection('status')
        .doc(statusId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  /// 🔹 Format timestamp like Facebook / X
  String formatPostTime(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final DateTime postTime = timestamp.toDate();
    final DateTime now = DateTime.now();
    final Duration diff = now.difference(postTime);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      final weeks = (diff.inDays / 7).floor();
      return '${weeks}w ago';
    }
  }

  /// 🔹 Fetch the avatar asset name of the user who owns a particular status
  Future<String?> fetchStatusUserAvatarName(String email) async {
    try {
      final query = await _firestore
          .collection('e-users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final userData = query.docs.first.data();
      final avatarName = userData['avatar'] as String?;

      return (avatarName != null && avatarName.isNotEmpty) ? avatarName : null;
    } catch (e) {
      print('Error fetching avatar for $email: $e');
      return null;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 🔹 Check if a status owner is verified
  Future<bool> isUserVerifiedByEmail(String email) async {
    try {
      final query = await _firestore
          .collection('e-users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return false;

      return query.docs.first.data()['verified'] == true;
    } catch (e) {
      print('❌ Error checking verification: $e');
      return false;
    }
  }

  /// 🔹 Fetch verified status of a user by email
  Future<bool> fetchUserVerifiedStatus(String email) async {
    try {
      final query = await _firestore
          .collection('e-users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return false;

      return query.docs.first.data()['verified'] == true;
    } catch (e) {
      print("❌ Error fetching verified status for $email: $e");
      return false;
    }
  }

  /// Cache verified status to avoid multiple Firestore calls
  final RxMap<String, bool> _verifiedCache = <String, bool>{}.obs;

  /// 🔹 Fetch verified status for a user and cache it
  Future<bool> getVerifiedStatus(String email) async {
    if (_verifiedCache.containsKey(email)) {
      return _verifiedCache[email]!;
    }
    final verified = await fetchUserVerifiedStatus(email);
    _verifiedCache[email] = verified;
    return verified;
  }

  Future<void> flagPostAction({
    required DocumentSnapshot doc,
    required String postText,
    required String postEmail,
    required String postName,
    required String reason,
  }) async {
    final data = doc.data() as Map<String, dynamic>;
    await _moderation.flagPost(
      postId: doc.id,
      postText: postText,
      postImageUrl: data['imageUrl'],
      postOwnerEmail: postEmail,
      postOwnerName: postName,
      reason: reason,
    );
  }

  List<DocumentSnapshot> get paginatedStatuses {
    final list = filteredStatuses;

    final end = visibleCount.value > list.length
        ? list.length
        : visibleCount.value;

    return list.take(end).toList();
  }
}

//============================================================================//
