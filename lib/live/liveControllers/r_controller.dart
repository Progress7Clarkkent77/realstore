//import 'package:Textido/CowriexController/e_login_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class RController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Tiny R (0.00005)
  Future<void> incrementTinyR({required String uid}) async {
    await _incrementBalance(uid: uid, amount: 0.00005);
  }

  Future<void> incrementMarketR({required String uid}) async {
    await _incrementBalance(uid: uid, amount: 0.0004);
  }

  Future<void> incrementCommentR({required String uid}) async {
    await _incrementBalance(uid: uid, amount: 0.00005);
  }

  /// 🔹 Small R (0.002)
  Future<void> incrementSmallR({required String uid}) async {
    await _incrementBalance(uid: uid, amount: 0.0002);
  }

  /// 🔹 Medium R (0.005)
  Future<void> incrementMediumR({required String uid}) async {
    await _incrementBalance(uid: uid, amount: 0.0005);
  }

  /// 🔹 Referral R (0.003)
  Future<void> incrementRefer({required String uid}) async {
    await _incrementBalance(uid: uid, amount: 0.0009);
  }

  /// 🔥 Core atomic increment function
  Future<void> _incrementBalance({
    required String uid,
    required double amount,
  }) async {
    try {
      final userRef = _firestore.collection('e-users').doc(uid);

      await userRef.update({'available_bal': FieldValue.increment(amount)});

      print("💰 Red $uid with $amount");
    } catch (e, stack) {
      print("❌ RController Exception: $e");
      print("StackTrace: $stack");
    }
  }
}
