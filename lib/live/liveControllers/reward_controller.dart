//import 'package:Textido/CowriexController/e_login_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

// class RewardController extends GetxController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final AuthController authController = Get.find<AuthController>();

//   /// Increment user's available balance by 0.0001
//   Future<void> incrementTinyReward() async {
//     await _incrementBalance(0.00005);
//   }

//   /// Increment user's available balance by 0.007
//   Future<void> incrementSmallReward() async {
//     await _incrementBalance(0.002);
//   }

//   /// Increment user's available balance by 0.005
//   Future<void> incrementMediumReward() async {
//     await _incrementBalance(0.005);
//   }

//   Future<void> incrementRefer() async {
//     await _incrementBalance(0.0006);
//   }

//   Future<void> incrementChatReward() async {
//     await _incrementBalance(0.00005);
//   }

//   /// Generic function to increment user's balance safely
//   Future<void> _incrementBalance(double amount) async {
//     final uid = authController.currentUser?.uid;
//     if (uid == null) return;

//     try {
//       final userRef = _firestore.collection('e-users').doc(uid);
//       final userSnap = await userRef.get();

//       double currentBal = 0.0;
//       if (userSnap.exists) {
//         final data = userSnap.data();
//         final rawBal = data?['available_bal'];
//         if (rawBal is num) currentBal = rawBal.toDouble();
//       }

//       // Update Firestore with new balance
//       await userRef.update({'available_bal': currentBal + amount});
//       print(
//           "Balance incremented by $amount. New balance: ${currentBal + amount}");
//     } catch (e, stack) {
//       print("RewardController Exception: $e");
//       print("StackTrace: $stack");
//     }
//   }
// }

class RewardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Tiny reward (0.00005)
  Future<void> incrementTinyReward({required String uid}) async {
    await _incrementBalance(uid: uid, amount: 0.00005);
  }

  Future<void> incrementMarketReward({required String uid}) async {
    await _incrementBalance(uid: uid, amount: 0.0004);
  }

  Future<void> incrementCommentReward({required String uid}) async {
    await _incrementBalance(uid: uid, amount: 0.00005);
  }

  /// 🔹 Small reward (0.002)
  Future<void> incrementSmallReward({required String uid}) async {
    await _incrementBalance(uid: uid, amount: 0.0002);
  }

  /// 🔹 Medium reward (0.005)
  Future<void> incrementMediumReward({required String uid}) async {
    await _incrementBalance(uid: uid, amount: 0.0005);
  }

  /// 🔹 Referral reward (0.003)
  Future<void> incrementRefer({required String uid}) async {
    await _incrementBalance(uid: uid, amount: 0.0009);
  }

  /// 🔹 Chat reward (0.00005)
  Future<void> incrementChatReward({required String uid}) async {
    await _incrementBalance(uid: uid, amount: 0.00001);
  }

  /// 🔥 Core atomic increment function
  Future<void> _incrementBalance({
    required String uid,
    required double amount,
  }) async {
    try {
      final userRef = _firestore.collection('e-users').doc(uid);

      await userRef.update({
        'available_bal': FieldValue.increment(amount),
      });

      print("💰 Rewarded $uid with $amount");
    } catch (e, stack) {
      print("❌ RewardController Exception: $e");
      print("StackTrace: $stack");
    }
  }
}
