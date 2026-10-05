// // ignore_for_file: avoid_web_libraries_in_flutter

// import 'dart:js' as js;

// import 'package:Textido/constant/payment_key.dart';

// import '../services/paystack_interop.dart' as paystack;

// class PaystackPopup {
//   static Future<void> openPaystackPopup({
//     required String email,
//     required String amount,
//     required String ref,
//     required void Function() onClosed,
//     required void Function() onSuccess,
//   }) async {
//     js.context.callMethod(
//       paystack.paystackPopUp(
//         publicKey,
//         email,
//         amount,
//         ref,
//         //error
//         //The function 'allowInterop' isn't defined.
// //Try importing the library that defines 'allowInterop', correcting the name to the name of an existing function, or defining a function named 'allowInterop'.
//         js.allowInterop(
//           onClosed,
//         ),
//          //error
//         //The function 'allowInterop' isn't defined.
// //Try importing the library that defines 'allowInterop', correcting the name to the name of an existing function, or defining a function named 'allowInterop'.
//         js.allowInterop(
//           onSuccess,
//         ),
//       ),
//       [],
//     );
//   }
// }

// ignore_for_file: avoid_web_libraries_in_flutter

// import 'dart:js' as js;
// import 'dart:ui';

// import 'package:js/js.dart';
// import 'package:js/js_util.dart' as js_util;

// import 'package:Textido/constant/payment_key.dart';
// import '../services/paystack_interop.dart' as paystack;

// class PaystackPopup {
//   static Future<void> openPaystackPopup({
//     required String email,
//     required String amount,
//     required String ref,
//     required VoidCallback onClosed,
//     required VoidCallback onSuccess,
//   }) async {
//     js.context.callMethod(
//       paystack.paystackPopUp,
//       [
//         publicKey,
//         email,
//         amount,
//         ref,
//         js_util.allowInterop(onClosed),
//         js_util.allowInterop(onSuccess),
//       ],
//     );
//   }
// }

// import 'dart:ui';

// class PaystackPopup {
//   static Future<void> openPaystackPopup({
//     required String email,
//     required String amount,
//     required String ref,
//     required VoidCallback onClosed,
//     required VoidCallback onSuccess,
//   }) async {
//     await openPaystackPopup(
//       email: email,
//       amount: amount,
//       ref: ref,
//       onClosed: onClosed,
//       onSuccess: onSuccess,
//     );
//   }
// }

import 'package:flutter/foundation.dart';

//import 'package:flutter/foundation.dart';

import 'paystack.dart' as impl;

class PaystackPopup {
  static Future<void> openPaystackPopup({
    required String email,
    required String amount,
    required String ref,
    required VoidCallback onClosed,
    required VoidCallback onSuccess,
  }) async {
    await impl.openPaystackPopup(
      email: email,
      amount: amount,
      ref: ref,
      onClosed: onClosed,
      onSuccess: onSuccess,
    );
  }
}
