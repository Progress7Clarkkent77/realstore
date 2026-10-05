import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:realstore/live/userAuth/authController.dart';

class AvailableBalanceController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _auth = Get.find<AuthController>();

  final RxDouble avlBal = 0.0.obs;

  String get currentUid => _auth.currentUser!.uid;

  @override
  void onInit() {
    super.onInit();
    listenToBalance();
  }

  void listenToBalance() {
    _firestore.collection('e-users').doc(currentUid).snapshots().listen((doc) {
      if (!doc.exists) return;

      avlBal.value = (doc.data()?['available_bal'] ?? 0).toDouble();
    });
  }
}
