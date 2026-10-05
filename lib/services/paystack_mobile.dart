import 'package:flutter/foundation.dart';

// Future<void> openPaystackPopup({
//   required String email,
//   required String amount,
//   required String ref,
//   required VoidCallback onClosed,
//   required VoidCallback onSuccess,
// }) async {
//   // You can later replace this with Paystack SDK or WebView
//   throw UnsupportedError(
//     'Paystack popup is only supported on Web',
//   );
// }

//import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constant/payment_key.dart';

Future<void> openPaystackPopup({
  required String email,
  required String amount,
  required String ref,
  required VoidCallback onClosed,
  required VoidCallback onSuccess,
}) async {
  // 🔑 Paystack MOBILE = redirect flow
  final Uri paystackUrl = Uri.parse(
    'https://checkout.paystack.com/'
    '?email=$email'
    '&amount=$amount'
    '&reference=$ref'
    '&key=$publicKey',
  );

  if (!await canLaunchUrl(paystackUrl)) {
    throw Exception('Could not launch Paystack');
  }

  await launchUrl(
    paystackUrl,
    mode: LaunchMode.externalApplication,
  );

  // ❗ No popup callbacks on mobile
  // Payment MUST be verified server-side
}
