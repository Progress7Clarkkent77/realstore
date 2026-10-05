import 'dart:async';
import 'dart:math';

import 'package:realstore/live/liveControllers/reward_controller.dart';
import 'package:realstore/live/liveControllers/storeConfig.dart';
import 'package:realstore/live/liveControllers/theme_controller.dart';
import 'package:realstore/live/pages/adminDashboard.dart';
import 'package:realstore/live/pages/ecommerceHomePage.dart';
import 'package:realstore/live/pages/term_of_use.dart';
import 'package:realstore/live/userAuth/authpages.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'dart:io' show Platform;

import 'package:realstore/widgets/loading_dialogue.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthController();

  User? get currentUser => _auth.currentUser;

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  RxBool isVerified = false.obs;

  /// True when the signed-in user is the store admin
  /// (see [StoreConfig.adminEmail]). UI convenience only; real access
  /// control is enforced by Firestore security rules.
  final RxBool isAdmin = false.obs;

  final RxBool _isAuthenticated = false.obs;

  /// Reactive: reading this inside an Obx() rebuilds the widget whenever the
  /// user signs in or out.
  bool get isAuthenticated => _isAuthenticated.value;

  StreamSubscription<User?>? _authSub;

  @override
  void onInit() {
    super.onInit();

    // Keep isAdmin in sync on app start, login, logout and account switch.
    isAdmin.value = StoreConfig.isAdminEmail(_auth.currentUser?.email);
    _isAuthenticated.value = _auth.currentUser != null;
    _authSub = _auth.authStateChanges().listen((user) {
      isAdmin.value = StoreConfig.isAdminEmail(user?.email);
      _isAuthenticated.value = user != null;
    });

    fetchVerificationStatus();

    // 🔔 Save FCM token if user already logged in
    _saveFcmToken();

    // 🔁 Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('e-users').doc(user.uid).set({
        'fcmToken': newToken,
        'fcmUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  @override
  void onClose() {
    _authSub?.cancel();
    super.onClose();
  }

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Login Error", "Please fill in all fields");
      return;
    }

    isLoading.value = true;

    // Show loading dialog
    Get.dialog(LoadingDialog(), barrierDismissible: false);

    try {
      // Step 1: verify the credentials against Firebase Auth. This is the
      // "use Firebase to know the email" step — we need a successful sign-in
      // to know which e-users doc belongs to this email before we can check
      // its termsAccepted flag.
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user?.uid ?? '';

      // 🔹 Fetch user from e-users
      DocumentSnapshot eUserDoc = await _firestore
          .collection('e-users')
          .doc(userId)
          .get();

      // 🔹 If user does NOT exist in e-users, create account
      if (!eUserDoc.exists) {
        DocumentSnapshot sUserDoc = await _firestore
            .collection('s-users')
            .doc(userId)
            .get();

        if (sUserDoc.exists) {
          var userData = sUserDoc.data() as Map<String, dynamic>;

          // Create e-users record
          await _firestore.collection('e-users').doc(userId).set({
            'name': userData['name'],
            'email': userData['email'],
            'firstLogin': true,
          });
        }
      }

      // 🔢 Every logged-in user gets a referCode — this also backfills
      // accounts created before this feature existed. No-ops if the
      // field is already set.
      try {
        await ensureReferCode(userId);
      } catch (_) {
        // Never let referCode backfill block a successful login.
      }

      // Step 2: check the Terms of Use acceptance status BEFORE we do
      // anything that constitutes "being logged in" (FCM token, presence,
      // theme, chat listeners). Re-fetch so we see the doc we may have just
      // created above.
      final termsCheckDoc = await _firestore
          .collection('e-users')
          .doc(userId)
          .get();
      final termsData = termsCheckDoc.data();
      final bool hasAcceptedTerms =
          termsData != null && termsData['termsAccepted'] == true;

      if (!hasAcceptedTerms) {
        // Close loading dialog
        if (Get.isDialogOpen == true) Get.back();

        // The credentials were valid, but the account has not accepted the
        // current Terms of Use yet, so the login is intentionally left
        // incomplete here — no FCM token save, no presence update, no
        // theme/chat setup, and no navigation to '/home'. The user stays
        // signed in to Firebase Auth only long enough for the Terms of Use
        // screen to record acceptance against their uid; that screen signs
        // them back out and returns them to the login page once they
        // accept (or decline), so they must log in again to actually enter
        // the app.
        Get.off(() => const TermsOfUseScreen());
        return;
      }

      // Terms already accepted — proceed with completing the login.

      // 🔔 SAVE FCM TOKEN HERE
      // IMPORTANT: this must NEVER be able to throw out into this try block.
      // On iOS, FirebaseMessaging.getToken() can throw if the APNs token
      // isn't ready yet, which was previously caught below and shown to the
      // user as "Incorrect Email or Password" — even though auth had already
      // succeeded. _saveFcmToken() now swallows its own errors internally,
      // but we also guard the call site as a second safety net.
      try {
        await _saveFcmToken();
      } catch (_) {
        // Never let a push-notification issue block a successful login.
      }

      // Close loading dialog
      if (Get.isDialogOpen == true) Get.back();

      //Get.put(ModerationController(), permanent: true);

      final themeCtrl = Get.put(ThemeController());
      await themeCtrl.loadTheme();

      // Route by role: the store admin lands on the dashboard,
      // everyone else goes to the storefront.
      isAdmin.value = StoreConfig.isAdminEmail(userCredential.user?.email);

      if (isAdmin.value) {
        Get.offAll(() => EcommerceAdminDashboardPage());
      } else {
        Get.offNamed('/onboarding');
      }
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      Get.snackbar(
        "Login Error",
        "Incorrect Email or Password & check your internet connection",
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyPassword(String email, String password) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await _auth.currentUser!.reauthenticateWithCredential(credential);
      return true; // Password is correct
    } catch (e) {
      return false; // Password is incorrect
    }
  }

  Future<void> logout() async {
    try {
      // Show loading dialog
      Get.dialog(
        LoadingDialog(),
        barrierDismissible: false, // Prevents manual closing
      );

      // Wait for a moment so the dialog is visible
      await Future.delayed(Duration(seconds: 6));

      await _auth.signOut(); // Firebase logout

      // Close dialog after delay and logout
      Get.back();

      // Navigate to login screen & clear history
      Get.offAllNamed('/home');
    } catch (e) {
      Get.back(); // Close dialog if there's an error
      Get.snackbar("Logout Error", "Failed to log out. Please try again.");
    }
  }

  Future<void> signup(
    String name,
    String email,
    String password, {
    String? referralCode,
  }) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar("Signup Error", "Please fill in all fields");
      return;
    }

    isLoading.value = true;
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String userId = userCredential.user?.uid ?? '';

      // 🔔 Save FCM token after signup
      // Same reasoning as in login(): this must never throw back into this
      // try block, or a successful signup gets reported as a "network issue".
      try {
        await _saveFcmToken();
      } catch (_) {
        // Never let a push-notification issue block a successful signup.
      }

      // 🔢 Every new user gets their own referCode right away.
      final myReferCode = await _generateUniqueReferCode();

      final Map<String, dynamic> userData = {
        'name': name,
        'email': email,
        'available_bal': 0.025, // Set initial available balance
        'referCode': myReferCode,
      };

      // 🔗 Optional referral code entered at signup — best-effort link to
      // whoever owns it. Invalid/unknown codes are silently ignored so a
      // typo never blocks account creation; self-referral is ignored too.
      final enteredCode = referralCode?.trim();
      if (enteredCode != null && enteredCode.isNotEmpty) {
        try {
          final referrerQuery = await _firestore
              .collection('e-users')
              .where('referCode', isEqualTo: enteredCode)
              .limit(1)
              .get();

          if (referrerQuery.docs.isNotEmpty) {
            final referrerUid = referrerQuery.docs.first.id;
            if (referrerUid != userId) {
              userData['referredBy'] = referrerUid;
              userData['referredByCode'] = enteredCode;
            }
          }
        } catch (_) {
          // Referral lookup failing must never block signup.
        }
      }

      // Save user details to Firestore with `available_bal`
      await _firestore.collection('e-users').doc(userId).set(userData);

      Get.offAllNamed('/login');
    } catch (e) {
      if (e.toString().contains("email-already-in-use")) {
        Get.snackbar(
          "Signup Error",
          "The Email is already registered. Please try logging in.",
        );
      } else {
        Get.snackbar(
          "Signup Error",
          "Network or service issue. Please try again.",
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendVerificationEmail() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      // 🔎 Step 1: Check if `verify` field is already true in Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection("e-users")
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data() as Map<String, dynamic>;
        if (data['verify'] == true) {
          Get.snackbar("Already Verified", "Your email is already verified.");
          isVerified.value = true;
          return;
        }
      }

      // 📧 Step 2: Send verification email
      await user.sendEmailVerification();

      // 🪟 Step 3: Show dialog confirmation
      Get.defaultDialog(
        title: "Email Sent",
        titleStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        middleText:
            "Verification email has been sent. Please check your inbox.",
        middleTextStyle: TextStyle(color: Colors.black, fontSize: 12),
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: Text(
            "OK",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      );

      // ⏱️ Step 4: Wait 10 seconds
      await Future.delayed(Duration(seconds: 10));

      // ✅ Step 5: Set verify field to true in Firestore
      await _firestore.collection("e-users").doc(user.uid).set({
        "verify": true,
      }, SetOptions(merge: true));

      // ✅ Step 6: Update reactive state
      isVerified.value = true;

      // 🎁 Step 7: Reward whoever referred this user — only fires the
      // first time this user's `verify` field becomes true (this method
      // already returned early above if it was already true).
      await _rewardReferrerIfNeeded(user.uid, userDoc);
    } catch (e) {
      Get.snackbar("Error", "Failed to send verification email");
    }
  }

  // Fetch verification status from Firestore
  Future<void> fetchVerificationStatus() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot doc = await _firestore
          .collection("e-users")
          .doc(user.uid)
          .get();
      bool verified = doc.exists && doc["verify"] == true;

      // Update UI
      isVerified.value = verified;
    } catch (e) {
      //   Get.snackbar("Error", "Failed to fetch verification status: $e");
    }
  }

  Future<void> checkEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      isVerified.value = user.emailVerified; // ✅ Correct usage of RxBool
    } else {
      Get.snackbar("Error", "No user is currently signed in.");
    }
  }

  Future<String?> getMnemonicForUser(String email) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('wallets')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['mnemonic'];
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching mnemonic: $e");
      return null;
    }
  }

  Future<void> changePassword(String newPassword) async {
    isLoading.value = true;
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      Get.snackbar("Success", "Password changed successfully.");
      Get.toNamed('/login');
    } catch (e) {
      Get.snackbar("Change Password Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    isLoading.value = true;

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());

      Get.snackbar(
        "Email Sent",
        "Check your inbox (and spam folder) for password reset.",
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Reset Failed", e.message ?? "Something went wrong");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendWithdrawVerificationEmail() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('e-users').doc(user.uid).get();

    if (doc.exists && doc.data()?['withdraw_verify'] == true) {
      isVerified.value = true;
      return;
    }

    if (!user.emailVerified) {
      await user.sendEmailVerification();

      Get.defaultDialog(
        title: "Verify your email",
        middleText: "A verification email has been sent.\n\nPlease check your inbox or spam folder.",
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text("OK"),
        ),
      );
    }
  }

  Future<bool> checkWithdrawVerification() async {
    User? user = _auth.currentUser;
    if (user == null) return false;

    await user.reload();

    if (!user.emailVerified) return false;

    final docRef = _firestore.collection('e-users').doc(user.uid);

    // 🔎 Read first — this tells us whether this call is the actual
    // false→true transition (so we don't reward twice), and gives us the
    // `referredBy` field before we write below.
    final userDoc = await docRef.get();
    final wasAlreadyVerified =
        (userDoc.data() as Map<String, dynamic>?)?['withdraw_verify'] == true;

    await docRef.set({'withdraw_verify': true}, SetOptions(merge: true));

    isVerified.value = true;

    // 🎁 Reward whoever referred this user — only on the transition into
    // verified. This is the real verification path (backed by Firebase
    // Auth's emailVerified), unlike the timer-based one in
    // sendVerificationEmail() above.
    if (!wasAlreadyVerified) {
      await _rewardReferrerIfNeeded(user.uid, userDoc);
    }

    return true;
  }

  // =====================================================================
  // FCM TOKEN HANDLING
  // ---------------------------------------------------------------------
  // Root cause of the iOS bug: on iOS, FirebaseMessaging.getToken() can
  // throw (or return null after a long delay) if the APNs token has not
  // yet been assigned by the OS — this is normal on iOS and is NOT an
  // error condition for auth. Android has no such precondition, which is
  // why this never showed up on Android.
  //
  // Previously this whole method's exception propagated up into
  // login()/signup()'s try block and was shown to the user as
  // "Incorrect Email/Password" or "Network issue" — even though the
  // actual Firebase Auth call had already succeeded.
  //
  // Fix: this method now NEVER throws. It also waits for the APNs token
  // on iOS before requesting the FCM token.
  // =====================================================================
  Future<void> _saveFcmToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // ---------------- iOS-specific handling ----------------
      // Uncomment this block if targeting iOS. Waits for APNs token to
      // be assigned before requesting the FCM token, with a short
      // timeout so we never hang the login/signup flow.
      if (Platform.isIOS) {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        int attempts = 0;
        while (apnsToken == null && attempts < 5) {
          await Future.delayed(const Duration(milliseconds: 500));
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          attempts++;
        }
        if (apnsToken == null) {
          // APNs token still not available (e.g. simulator, permissions
          // not granted, or provisioning profile lacks push capability).
          // Skip FCM token save for this session rather than throwing.
          return;
        }
      }
      // ---------------------------------------------------------------

      // ---------------- Android-only shortcut ----------------
      // Android does not need to wait for an APNs token. If you ever
      // want to hard-disable the iOS wait above (e.g. building Android
      // only), you can comment out the `if (Platform.isIOS) { ... }`
      // block above and this method behaves exactly as it did before.
      // ---------------------------------------------------------------

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      await _firestore.collection('e-users').doc(user.uid).set({
        'fcmToken': token,
        'fcmUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Swallow all errors here. FCM token saving must never break
      // login, signup, or app startup on any platform.
      print("FCM token save skipped: $e");
    }
  }

  Future<bool> _verifyEmailExists(String email, String password) async {
    try {
      UserCredential tempUser = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await tempUser.user!.sendEmailVerification();

      await tempUser.user!.delete();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return false;
      }
      if (e.code == 'email-already-in-use') {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // =====================================================================
  // REFERRAL SYSTEM
  // ---------------------------------------------------------------------
  // Every user gets a random 6-digit `referCode` on their e-users doc
  // (generated on signup, and backfilled on login for accounts that
  // predate this feature). A new user can optionally enter someone
  // else's code at signup, which links `referredBy` on their own doc.
  // The referrer is only rewarded once — the first time the new user's
  // `verify` field flips to true in sendVerificationEmail() above.
  // =====================================================================

  /// 🔢 Returns this user's referCode, generating and saving a unique
  /// 6-digit one if their e-users doc doesn't have one yet. Safe to call
  /// repeatedly — it's a no-op once the field is set.
  Future<String> ensureReferCode(String uid) async {
    final docRef = _firestore.collection('e-users').doc(uid);
    final doc = await docRef.get();

    final existing = doc.data() != null
        ? (doc.data() as Map<String, dynamic>)['referCode'] as String?
        : null;

    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final code = await _generateUniqueReferCode();

    await docRef.set({'referCode': code}, SetOptions(merge: true));

    return code;
  }

  /// 🔢 Generates a random 6-digit code (100000–999999) that no other
  /// user already has.
  Future<String> _generateUniqueReferCode() async {
    final random = Random();

    while (true) {
      final code = (100000 + random.nextInt(900000)).toString();

      final existing = await _firestore
          .collection('e-users')
          .where('referCode', isEqualTo: code)
          .limit(1)
          .get();

      if (existing.docs.isEmpty) {
        return code;
      }
    }
  }

  /// 🎁 Rewards whoever referred this user (via `referredBy` on their
  /// own doc), but only once — guarded by `referralRewardGiven` in case
  /// this ever runs more than once for the same user.
  Future<void> _rewardReferrerIfNeeded(
    String newUserUid,
    DocumentSnapshot userDoc,
  ) async {
    try {
      final data = userDoc.data() as Map<String, dynamic>?;
      final referrerUid = data?['referredBy'] as String?;

      if (referrerUid == null || referrerUid.isEmpty) return;
      if (data?['referralRewardGiven'] == true) return;

      final rewardCtrl = Get.find<RewardController>();
      await rewardCtrl.incrementRefer(uid: referrerUid);

      await _firestore.collection('e-users').doc(newUserUid).set({
        'referralRewardGiven': true,
      }, SetOptions(merge: true));

      print("💰 Rewarded referrer $referrerUid for verified signup");
    } catch (e) {
      print("❌ Error rewarding referrer: $e");
    }
  }
}
