import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// =====================================================================
/// MODERATION CONTROLLER
/// ---------------------------------------------------------------------
/// Handles the three App Store safety requirements:
///   1. Report content (flag a status post) — hidden only for the reporter
///   2. Report user / report channel
///   3. Block / unblock user — mutual hiding of posts + disabled chat
///
/// ---------------------------------------------------------------------
/// WHY THIS VERSION IS DIFFERENT FROM BEFORE:
/// The previous version read `Get.find<AuthController>().currentUser`
/// exactly once, inside onInit(). That made WHERE and WHEN this
/// controller got registered matter a lot — if it was created before
/// login happened, it would see a null user, do nothing, and never
/// retry, silently leaving moderation state empty even after the user
/// logged in.
///
/// This version listens directly to FirebaseAuth's own
/// authStateChanges() stream instead. That means it is now completely
/// safe to register ANYWHERE — eagerly at app boot in main.dart's
/// initControllers(), or lazily, or after login — it will always
/// correctly (re)load moderation state the moment a user becomes
/// signed in, and clear it the moment they sign out. No dependency on
/// AuthController at all anymore, which also removes one more
/// cross-controller ordering concern from your app's boot sequence.
///
/// RECOMMENDED REGISTRATION (do this ONCE):
///   In main.dart's initControllers():
///     Get.put(ModerationController(), permanent: true);
///
///   Then REMOVE the Get.put(ModerationController(), permanent: true)
///   calls from both StartupController and AuthController.login() —
///   they're redundant now and just add more moving parts to your
///   already-fragile boot path for no benefit.
/// =====================================================================
class ModerationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Post IDs the current user has flagged — hidden ONLY for them.
  final RxSet<String> flaggedPostIds = <String>{}.obs;

  /// Emails of users the current user has blocked.
  final RxSet<String> blockedEmails = <String>{}.obs;

  /// Emails of users who have blocked the current user.
  final RxSet<String> blockedByEmails = <String>{}.obs;

  /// UIDs of users the current user has blocked (used by chat/profile UI).
  final RxSet<String> blockedUids = <String>{}.obs;

  /// UIDs of users who have blocked the current user.
  final RxSet<String> blockedByUids = <String>{}.obs;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _stateSub;
  StreamSubscription<User?>? _authSub;

  @override
  void onInit() {
    super.onInit();

    // Reacts to login/logout automatically, regardless of registration
    // timing. Fires immediately with the current auth state too.
    _authSub = _firebaseAuth.authStateChanges().listen((user) {
      _stateSub?.cancel();
      _clearState();

      if (user != null) {
        _listenToModerationState(user.uid);
      }
    });
  }

  @override
  void onClose() {
    _stateSub?.cancel();
    _authSub?.cancel();
    super.onClose();
  }

  void _clearState() {
    flaggedPostIds.clear();
    blockedEmails.clear();
    blockedByEmails.clear();
    blockedUids.clear();
    blockedByUids.clear();
  }

  void _listenToModerationState(String uid) {
    _stateSub = _firestore.collection('e-users').doc(uid).snapshots().listen((
      doc,
    ) {
      if (!doc.exists) return;
      final data = doc.data() ?? {};

      flaggedPostIds.assignAll(Set<String>.from(data['flaggedPostIds'] ?? []));
      blockedEmails.assignAll(Set<String>.from(data['blockedEmails'] ?? []));
      blockedByEmails.assignAll(
        Set<String>.from(data['blockedByEmails'] ?? []),
      );
      blockedUids.assignAll(Set<String>.from(data['blockedUids'] ?? []));
      blockedByUids.assignAll(Set<String>.from(data['blockedByUids'] ?? []));
    });
  }

  // =====================================================================
  // 1) REPORT CONTENT — flag a status/post
  // =====================================================================
  Future<void> flagPost({
    required String postId,
    required String postText,
    String? postImageUrl,
    required String postOwnerEmail,
    required String postOwnerName,
    required String reason,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('flaggedPosts').add({
        'postId': postId,
        'postText': postText,
        'postImageUrl': postImageUrl,
        'postOwnerEmail': postOwnerEmail,
        'postOwnerName': postOwnerName,
        'reportedByUid': user.uid,
        'reportedByEmail': user.email ?? '',
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('e-users').doc(user.uid).set({
        'flaggedPostIds': FieldValue.arrayUnion([postId]),
      }, SetOptions(merge: true));

      flaggedPostIds.add(postId);
    } catch (e) {
      print('❌ Error flagging post: $e');
      rethrow;
    }
  }

  // =====================================================================
  // 2) REPORT USER
  // =====================================================================
  Future<void> reportUser({
    required String reportedUid,
    required String reportedName,
    required String reportedEmail,
    required String reason,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('reportedUsers').add({
        'reportedUid': reportedUid,
        'reportedName': reportedName,
        'reportedEmail': reportedEmail,
        'reportedByUid': user.uid,
        'reportedByEmail': user.email ?? '',
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error reporting user: $e');
      rethrow;
    }
  }

  // =====================================================================
  // 3) BLOCK / UNBLOCK USER
  // =====================================================================
  Future<void> blockUser({
    required String targetUid,
    required String targetEmail,
    required String reason,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      final myRef = _firestore.collection('e-users').doc(user.uid);
      final theirRef = _firestore.collection('e-users').doc(targetUid);

      await myRef.set({
        'blockedUids': FieldValue.arrayUnion([targetUid]),
        'blockedEmails': FieldValue.arrayUnion([targetEmail]),
      }, SetOptions(merge: true));

      await theirRef.set({
        'blockedByUids': FieldValue.arrayUnion([user.uid]),
        'blockedByEmails': FieldValue.arrayUnion([user.email ?? '']),
      }, SetOptions(merge: true));

      await _firestore.collection('blockedUsers').add({
        'blockedUid': targetUid,
        'blockedEmail': targetEmail,
        'blockedByUid': user.uid,
        'blockedByEmail': user.email ?? '',
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });

      blockedUids.add(targetUid);
      blockedEmails.add(targetEmail);
    } catch (e) {
      print('❌ Error blocking user: $e');
      rethrow;
    }
  }

  Future<void> unblockUser({
    required String targetUid,
    required String targetEmail,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      final myRef = _firestore.collection('e-users').doc(user.uid);
      final theirRef = _firestore.collection('e-users').doc(targetUid);

      await myRef.set({
        'blockedUids': FieldValue.arrayRemove([targetUid]),
        'blockedEmails': FieldValue.arrayRemove([targetEmail]),
      }, SetOptions(merge: true));

      await theirRef.set({
        'blockedByUids': FieldValue.arrayRemove([user.uid]),
        'blockedByEmails': FieldValue.arrayRemove([user.email ?? '']),
      }, SetOptions(merge: true));

      blockedUids.remove(targetUid);
      blockedEmails.remove(targetEmail);
    } catch (e) {
      print('❌ Error unblocking user: $e');
      rethrow;
    }
  }

  // =====================================================================
  // REPORT CHANNEL
  // =====================================================================
  Future<void> reportChannel({
    required String channelId,
    required String channelName,
    required String reason,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('reportedChannels').add({
        'channelId': channelId,
        'channelName': channelName,
        'reportedByUid': user.uid,
        'reportedByEmail': user.email ?? '',
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error reporting channel: $e');
      rethrow;
    }
  }

  bool isBlockedByMe(String uid) => blockedUids.contains(uid);
  bool hasBlockedMe(String uid) => blockedByUids.contains(uid);
  bool isEitherBlocked(String uid) => isBlockedByMe(uid) || hasBlockedMe(uid);
}
