import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// =====================================================================
/// TERMS OF USE / EULA GATE — PRE-LOGIN GATE VERSION
/// ---------------------------------------------------------------------
/// Shown as soon as AuthController.login() has verified the entered
/// email/password against Firebase Auth but found that the matching
/// e-users doc does not yet have 'termsAccepted' == true. Login is
/// intentionally left incomplete at that point — no FCM token save, no
/// presence update, no theme/chat setup, no navigation to '/home' — so
/// this screen is the only thing standing between the user and their
/// account.
///
/// On accept: writes 'termsAccepted' + 'termsAcceptedAt' to the user's
/// e-users doc, signs the user back out, and returns to '/login'. The
/// user must then log in again; on that second attempt
/// AuthController.login() will see termsAccepted == true and complete
/// the full login flow normally.
///
/// On decline: signs the user out and returns to '/login' without
/// recording acceptance, so the next login attempt hits this gate again.
///
/// Firestore (not SharedPreferences) is the source of truth here since
/// nothing on this screen runs before Firebase Auth already has a
/// signed-in user — this also means acceptance follows the account
/// across devices/reinstalls.
///
/// Wire-up: called via Get.off(() => const TermsOfUseScreen()) from
/// AuthController.login().
/// =====================================================================
class TermsOfUseScreen extends StatefulWidget {
  const TermsOfUseScreen({super.key});

  @override
  State<TermsOfUseScreen> createState() => _TermsOfUseScreenState();
}

class _TermsOfUseScreenState extends State<TermsOfUseScreen> {
  bool hasReadTerms = false;
  bool hasReadPrivacy = false;
  bool isSaving = false;

  bool get canContinue => hasReadTerms && hasReadPrivacy && !isSaving;

  Future<void> _acceptAndContinue() async {
    setState(() => isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('e-users').doc(user.uid).set({
        'termsAccepted': true,
        'termsAcceptedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    // The user only reached this screen because their prior login attempt
    // was intentionally left incomplete (see AuthController.login()) — no
    // presence/theme/chat setup was ever run for this session. Now that
    // termsAccepted is recorded, sign them back out and send them to the
    // login page so they log in again to actually complete the login flow.
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;
    setState(() => isSaving = false);
    Get.offAllNamed('/login');
  }

  void _decline() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Terms Required',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'You need to accept the Terms of Use to continue using Textido. '
          'You can review the terms again before deciding.',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Review Again'),
          ),
          TextButton(
            onPressed: () async {
              // User already has an account and is signed in at this
              // point, so declining signs them back out rather than
              // force-closing the app.
              await FirebaseAuth.instance.signOut();
              Get.offAllNamed('/login');
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Requirement: white background, black text
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- HEADER ----------------
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Colors.black,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Terms of Use',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Please read and accept before continuing',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Colors.black12),

            // ---------------- SCROLLABLE TERMS TEXT ----------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Text(
                  _termsOfUseText,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            const Divider(height: 1, color: Colors.black12),

            // ---------------- CHECKBOXES + ACTIONS ----------------
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildCheckRow(
                    value: hasReadTerms,
                    label: 'I have read and agree to the Textido Terms of Use.',
                    onChanged: (v) => setState(() => hasReadTerms = v ?? false),
                  ),
                  _buildCheckRow(
                    value: hasReadPrivacy,
                    label: 'I acknowledge that I have also read the Privacy Policy.',
                    onChanged: (v) =>
                        setState(() => hasReadPrivacy = v ?? false),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: canContinue ? _acceptAndContinue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        disabledBackgroundColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Accept & Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _decline,
                    child: Text(
                      'Decline',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckRow({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              activeColor: Colors.black,
              onChanged: onChanged,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 13),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const String _termsOfUseText = '''
RealStore Terms of Use

Last Updated: October 6, 2026

Welcome to RealStore, an e-commerce product discovery and order-request platform operated by AfiaSplendid LTD ("AfiaSplendid," "RealStore," "we," "our," or "us").

The RealStore iOS application allows customers to browse products, view product information, add products to a cart, and submit order requests.

At this time, the RealStore iOS application does not process payments directly within the app. When you submit an order request, the order information is sent to the RealStore administrator through WhatsApp so that payment, order confirmation, delivery arrangements, and other transaction details can be handled outside the application.

By accessing or using RealStore, you acknowledge that you have read, understood, and agree to these Terms of Use. If you do not agree with these Terms, you must not use RealStore.

1. About RealStore

RealStore is operated by AfiaSplendid LTD and provides customers with a convenient way to:

- Browse products offered by RealStore.
- View product descriptions, images, prices, and availability.
- Search for products.
- Add products to a shopping cart.
- Review selected products and quantities.
- Submit an order request.
- Contact RealStore regarding products and orders.
- Receive information about available products and services.

RealStore is not an open marketplace for independent third-party sellers.

Products displayed through RealStore are offered, sourced, or managed by AfiaSplendid LTD unless otherwise stated.

2. Eligibility

You must be at least 18 years of age, or the minimum legal age required to enter into a binding commercial transaction in your jurisdiction, to independently place an order through RealStore.

If you are under the applicable age, you may only use RealStore with the involvement and permission of a parent or legal guardian where permitted by law.

3. Acceptance of These Terms

By accessing RealStore, creating an account, adding products to your cart, submitting an order request, or otherwise using the application, you agree to these Terms of Use and our Privacy Policy and Return & Refund Policy.

4. Product Information

We make reasonable efforts to ensure that product names, descriptions, images, prices, specifications, and availability displayed in RealStore are accurate.

However:

- Product images may differ slightly from the actual product.
- Product packaging may change.
- Product availability may change.
- Product information may occasionally contain errors or omissions.
- Prices may change without prior notice.

We reserve the right to correct errors, update information, change prices, modify product availability, or remove products from RealStore.

5. Shopping Cart

The shopping cart allows you to select products and quantities before submitting an order request.

Adding products to the cart does not reserve or guarantee the availability of those products.

Product availability will be confirmed during the order-processing process.

6. Order Requests

When you tap the checkout or order button in the iOS application, the selected order information may be prepared and sent to the RealStore administrator through WhatsApp.

The information may include:

- Selected products.
- Product quantities.
- Order total or displayed product prices.
- Customer name or account information where available.
- Contact information.
- Delivery information where provided.
- Other information necessary to process the order request.

Submitting an order request does not automatically mean that a final purchase contract has been completed.

The RealStore administrator will communicate with the customer to confirm product availability, final pricing, delivery arrangements, payment instructions, and other applicable transaction details.

7. Payments and Transactions

The RealStore iOS application does not currently process payments directly inside the application.

RealStore does not provide an in-app card payment or checkout system on the iOS version at this time.

After an order request is submitted, payment and transaction arrangements are handled outside the application through communication with the RealStore administrator.

Customers may receive payment instructions through the official communication channel provided by RealStore.

Customers should not send payment information or money to unofficial individuals or accounts claiming to represent RealStore.

A payment should only be made after the customer has confirmed the order and received appropriate payment instructions from RealStore.

8. No In-App Payment Processing

The RealStore iOS application does not intentionally collect or store customers' card numbers, CVV numbers, PINs, passwords, or other sensitive payment credentials for processing purchases inside the app.

Any payment service used outside the application may have its own terms, privacy policy, and security practices.

9. Order Confirmation

An order request submitted through the application is subject to confirmation.

Before completing a transaction, RealStore may confirm:

- Product availability.
- Product quantity.
- Final price.
- Delivery location.
- Delivery charges where applicable.
- Payment method.
- Expected delivery timeframe.
- Other relevant order details.

RealStore reserves the right to decline or modify an order request where a product is unavailable, information is incorrect, pricing has changed, or other circumstances prevent fulfillment.

10. Delivery

Delivery arrangements are handled outside the application after communication with RealStore.

Delivery may be carried out directly by RealStore or through third-party logistics or delivery providers.

Delivery times may vary depending on:

- Product availability.
- Customer location.
- Delivery provider availability.
- Transportation conditions.
- Public holidays.
- Weather.
- Other circumstances outside our reasonable control.

Any delivery timeframe communicated to a customer is an estimate unless expressly stated otherwise.

11. Customer Responsibilities

Customers must provide accurate information when submitting an order request.

Customers must not:

- Submit fraudulent orders.
- Provide false information.
- Attempt unauthorized access to RealStore.
- Abuse order, return, or refund processes.
- Use stolen payment methods.
- Impersonate another person.
- Interfere with the operation or security of RealStore.
- Use RealStore for unlawful purposes.

12. Returns and Refunds

Returns, replacements, and refunds are governed by our Return & Refund Policy.

Customers should contact RealStore through the official contact channel provided if they receive a damaged, defective, incorrect, incomplete, or otherwise qualifying product.

13. Intellectual Property

RealStore, including its name, logo, software, design, graphics, interface, product presentation, and other original materials, is owned by or licensed to AfiaSplendid LTD and is protected by applicable intellectual property laws.

You may not copy, modify, distribute, reverse engineer, reproduce, or commercially exploit any part of RealStore without prior written permission.

14. Third-Party Services

RealStore may use or direct users to third-party services, including WhatsApp, delivery providers, payment providers, hosting services, or other external services.

These services operate independently and may have their own terms and privacy policies.

When you communicate with RealStore through WhatsApp, that communication is subject to WhatsApp's applicable terms and privacy practices.

AfiaSplendid LTD is not responsible for independent third-party services outside its reasonable control.

15. Availability of Service

We aim to keep RealStore available and functional but do not guarantee uninterrupted or error-free operation.

We may temporarily suspend or restrict access for:

- Maintenance.
- Security updates.
- Technical issues.
- Platform improvements.
- Legal or regulatory requirements.
- Other operational reasons.

16. Disclaimer

RealStore is provided on an "as is" and "as available" basis to the fullest extent permitted by applicable law.

We do not guarantee that:

- All products will always be available.
- Product information will always be completely error-free.
- Prices will never change.
- Every order request will be accepted.
- Delivery estimates will always be met.
- The application will always operate without interruption.

17. Limitation of Liability

To the fullest extent permitted by applicable law, AfiaSplendid LTD and RealStore shall not be liable for indirect, incidental, consequential, special, or other damages arising from or related to:

- Use or inability to use RealStore.
- Third-party services.
- Delivery delays outside our reasonable control.
- Communication failures involving third-party services.
- Technical interruptions.
- Unauthorized access caused by circumstances outside our reasonable control.

Nothing in these Terms excludes or limits liability that cannot legally be excluded or limited.

18. Changes to These Terms

We may update these Terms of Use from time to time.

Where significant changes are made, we may notify users through the application or other reasonable communication methods.

Your continued use of RealStore after updated Terms become effective constitutes acceptance of the revised Terms, where permitted by law.

19. Governing Law

These Terms shall be governed by the applicable laws of the jurisdiction in which AfiaSplendid LTD operates, subject to any mandatory consumer rights and protections that may apply.

20. Contact Us

For questions about RealStore, products, orders, payments, delivery, returns, or refunds, please contact:

AfiaSplendid LTD

Email: contact@afiasplendid.co.site

Website: https://afiasplendid.ltd
''';
