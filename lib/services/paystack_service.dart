// // import 'package:flutter/material.dart';
// // import 'package:flutter_paystack/flutter_paystack.dart';

// // class PaystackMobileService {
// //   static final PaystackPlugin _plugin = PaystackPlugin();
// //   static bool _initialized = false;

// //   /// Call this once (app startup)
// //   static void initialize(String publicKey) {
// //     if (_initialized) return;
// //     _plugin.initialize(publicKey: publicKey);
// //     _initialized = true;
// //   }

// //   /// This is the POPUP you can call anywhere
// //   static Future<bool> chargeCard({
// //     required BuildContext context,
// //     required String email,
// //     required int amountInKobo,
// //     required String reference,
// //   }) async {
// //     final charge = Charge()
// //       ..amount = amountInKobo
// //       ..email = email
// //       ..reference = reference;

// //     try {
// //       final response = await _plugin.checkout(
// //         context,
// //         charge: charge,
// //         method: CheckoutMethod.card,
// //       );

// //       return response.status == true;
// //     } catch (e) {
// //       debugPrint('Paystack error: $e');
// //       return false;
// //     }
// //   }
// // }

// import 'package:realstore/constant/payment_key.dart';
// import 'package:flutter/material.dart';
// import 'package:pay_with_paystack/pay_with_paystack.dart';

// class PaystackService {
//   static Future<void> startPayment({
//     required BuildContext context,
//     required String email,
//     required String reference,
//     required double amount, // in kobo
//     String currency = "NGN",
//     required Function(Map<String, dynamic>) onSuccess,
//     required Function(String) onError,
//   }) async {
//     try {
//       await PayWithPayStack().now(
//         context: context,
//         secretKey: publicKey, // ✅ mobile uses secretKey for client-side
//         customerEmail: email,
//         reference: reference,
//         currency: currency,
//         amount: amount,
//         callbackUrl: '', // mobile does not require a URL
//         transactionCompleted: (paymentData) {
//           onSuccess(paymentData as Map<String, dynamic>);
//         },
//         transactionNotCompleted: (reason) {
//           onError(reason);
//         },
//       );
//     } catch (e) {
//       onError(e.toString());
//     }
//   }
// }

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pay_with_paystack/pay_with_paystack.dart';
import 'package:realstore/constant/payment_key.dart';

class PaystackService {
  /// Opens the Paystack screen. The returned future completes when that
  /// screen closes. [onSuccess] / [onError] are called from Paystack's
  /// callbacks, and can never throw back into the package.
  static Future<void> startPayment({
    required BuildContext context,
    required String email,
    required String reference,
    required double amount,
    String currency = "NGN",
    required Function(Map<String, dynamic>) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      await PayWithPayStack().now(
        context: context,
        secretKey: publicKey,
        customerEmail: email,
        reference: reference,
        currency: currency,
        amount: amount,
        callbackUrl: '',
        transactionCompleted: (paymentData) {
          // A hard cast here used to throw silently and swallow the success.
          Map<String, dynamic> data = {};
          try {
            final Object? raw = paymentData;
            data = raw is Map
                ? Map<String, dynamic>.from(raw)
                : {'raw': raw.toString()};
          } catch (_) {}

          debugPrint('Paystack: transactionCompleted $reference');
          onSuccess(data);
        },
        transactionNotCompleted: (reason) {
          debugPrint('Paystack: transactionNotCompleted $reason');
          onError(reason.toString());
        },
      );
    } catch (e) {
      debugPrint('Paystack: startPayment error $e');
      onError(e.toString());
    }
  }

  /// Asks Paystack directly whether [reference] was paid.
  /// Returns the status ('success', 'abandoned', 'failed'...) or null when
  /// Paystack could not be reached.
  static Future<String?> verify(String reference) async {
    try {
      final res = await http
          .get(
            Uri.parse('https://api.paystack.co/transaction/verify/$reference'),
            headers: {'Authorization': 'Bearer $publicKey'},
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(res.body);
      if (body is! Map || body['status'] != true) return 'not_found';

      return (body['data']?['status'] ?? '').toString();
    } catch (e) {
      debugPrint('Paystack: verify error $e');
      return null;
    }
  }
}
