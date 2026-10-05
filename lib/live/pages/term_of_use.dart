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
Textido Terms of Use

Last Updated: August 3, 2026

Welcome to Textido, a text-first social platform ("Textido," "we," "our," or "us"). By creating an account, accessing, or using Textido, you acknowledge that you have read, understood, and agree to these Terms of Use. If you do not agree with these Terms, you may not register for or use the platform.

1. Eligibility

You must be at least 13 years of age, or the minimum age required by the laws of your country, to use Textido. By using the platform, you represent that you meet these requirements and have the legal capacity to enter into this agreement.

2. Acceptance of These Terms

By selecting "I Agree", registering an account, or continuing to use Textido, you agree to be legally bound by these Terms of Use, our Privacy Policy, Community Guidelines, and any additional policies published within the platform.

3. Purpose of Textido

Textido is a community platform designed to enable users to:

- Share text, images, and other supported content.
- Join and participate in communities.
- Communicate with other users.
- Discover information and opportunities.
- Engage in conversations respectfully.

4. Community Standards

To maintain a safe and respectful environment, every user must:

- Treat others with respect and dignity.
- Share lawful and truthful content.
- Respect the rights and privacy of others.
- Follow all applicable laws.
- Use Textido responsibly.

You are solely responsible for the content you create, upload, or share.

5. Prohibited Conduct

You agree not to:

- Post hate speech or discriminatory content.
- Harass, threaten, bully, or intimidate others.
- Share sexually explicit, exploitative, or illegal content.
- Promote violence, terrorism, or criminal activity.
- Upload viruses or malicious software.
- Impersonate another person or organization.
- Publish fraudulent or misleading information.
- Send spam or unsolicited advertisements.
- Attempt unauthorized access to accounts or systems.
- Interfere with the security or operation of Textido.
- Buy, sell, or transfer accounts without authorization.

Violations may result in immediate enforcement action.

6. Zero-Tolerance Policy

Textido maintains a strict zero-tolerance policy for objectionable content and abusive behavior.

Users must not create, upload, publish, promote, or distribute content that includes, but is not limited to:

- Hate speech or discrimination.
- Harassment, bullying, intimidation, or threats.
- Sexually explicit, exploitative, or abusive material.
- Violence or content encouraging violence.
- Terrorist or extremist content.
- Illegal activities or criminal conduct.
- Fraud, scams, phishing, or impersonation.
- Content intended to exploit, harm, or endanger others.
Any content that violates applicable laws or these Terms of Use.

Any user found violating this policy may have their content removed immediately and may receive warnings, temporary restrictions, account suspension, or permanent account termination without prior notice.

Where required by law, Textido may report unlawful activities to the appropriate authorities.

By accepting these Terms of Use, you acknowledge and agree to comply with this Zero-Tolerance Policy.

7. User-Generated Content

You retain ownership of the content you create.

By posting content on Textido, you grant Textido a worldwide, non-exclusive, royalty-free license to host, display, distribute, process, and transmit your content solely for the purpose of operating, maintaining, and improving the platform.

You represent that:

- You own the content or have permission to share it.
- Your content does not violate the rights of others.
- Your content complies with these Terms of Use.

8. Reporting and Moderation

Textido is committed to maintaining a safe and respectful community.

Users may report posts, channels, comments, or accounts they believe violate these Terms of Use or Community Guidelines.

Reported content may be reviewed by our moderation team, and appropriate action may include:

- Removing content.
- Limiting content visibility.
- Issuing warnings.
- Suspending accounts.
- Permanently terminating accounts.
- Reporting illegal activities to relevant authorities where required by law.

9. Blocking Users

Users may block other users to prevent unwanted interactions.

Blocking may prevent:

- Direct messaging.
- Viewing certain content.
- Future interactions, as determined by platform functionality.

10. Account Suspension and Termination

We reserve the right to suspend or permanently terminate accounts that:

- Violate these Terms of Use.
- Repeatedly receive valid abuse reports.
- Engage in fraudulent or illegal activities.
- Threaten the safety, security, or integrity of the platform or its users.

Serious violations may result in immediate account termination without prior notice.

11. Intellectual Property

The Textido name, logo, software, design, graphics, and platform features are protected by applicable intellectual property laws.

You may not copy, modify, distribute, reverse engineer, or exploit any part of the platform without prior written permission.

12. Privacy

Your use of Textido is also governed by our Privacy Policy, which explains how your information is collected, used, stored, and protected.

13. Availability of Service

We strive to provide reliable service but do not guarantee uninterrupted availability.

We may modify, suspend, or discontinue features to improve the platform, maintain security, or comply with legal requirements.

14. Disclaimer

Textido is provided "as is" and "as available."

We do not guarantee that:

- The platform will always be available.
- All user-generated content is accurate or reliable.
- The platform will always operate without technical issues.

15. Limitation of Liability

To the fullest extent permitted by law, Textido shall not be liable for:

- User-generated content.
- Indirect or consequential damages.
- Loss of data or profits.
- Unauthorized access to user accounts.
- Service interruptions beyond our reasonable control.

16. Changes to These Terms

We may update these Terms of Use from time to time.

When significant changes are made, users may be required to review and accept the updated Terms before continuing to use the platform.

17. Governing Law

These Terms shall be governed by the applicable laws of the jurisdiction in which Textido operates, without regard to conflict of law principles.

18. Contact Us

If you have questions regarding these Terms of Use, please contact us:

Email: progressclarkkent@gmail.com

Website: https://textido.com
''';
