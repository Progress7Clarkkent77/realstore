import 'package:flutter/material.dart';

/// =====================================================================
/// Reason lists — exactly as specified for each moderation action.
/// =====================================================================
const List<String> kFlagPostReasons = [
  'Spam or Misleading Content',
  'Hate Speech or Harassment',
  'Violence or Dangerous Content',
  'Sexual or Inappropriate Content',
  'False Information',
  'Other',
];

const List<String> kReportUserReasons = [
  'Harassment or Bullying',
  'Fake Account or Impersonation',
  'Spam or Scam',
  'Posting Inappropriate Content',
  'Other Violation',
];

const List<String> kBlockUserReasons = [
  'Unwanted Messages',
  'Harassment or Abuse',
  'Spam or Scam',
  'Privacy or Safety Concern',
  'Other Personal Reason',
];

const List<String> kReportChannelReasons = [
  'Spam or Misleading Content',
  'Hate Speech or Harassment',
  'Violence or Dangerous Content',
  'Sexual or Inappropriate Content',
  'Impersonation or Fake Channel',
  'Other',
];

/// =====================================================================
/// REPORT REASON DIALOG
/// ---------------------------------------------------------------------
/// A single, reusable "premium" white dialog used for:
///   - Flagging a post
///   - Reporting a user
///   - Blocking a user
///
/// Usage:
///   ReportReasonDialog.show(
///     context: context,
///     title: 'Report this post',
///     reasons: kFlagPostReasons,
///     confirmLabel: 'Report Post',
///     onConfirm: (reason) async { ... },
///   );
/// =====================================================================
class ReportReasonDialog extends StatefulWidget {
  final String title;
  final List<String> reasons;
  final String confirmLabel;
  final Future<void> Function(String reason) onConfirm;
  final Color confirmColor;

  const ReportReasonDialog({
    super.key,
    required this.title,
    required this.reasons,
    required this.confirmLabel,
    required this.onConfirm,
    this.confirmColor = Colors.red,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<String> reasons,
    required String confirmLabel,
    required Future<void> Function(String reason) onConfirm,
    Color confirmColor = Colors.red,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ReportReasonDialog(
        title: title,
        reasons: reasons,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
        confirmColor: confirmColor,
      ),
    );
  }

  @override
  State<ReportReasonDialog> createState() => _ReportReasonDialogState();
}

class _ReportReasonDialogState extends State<ReportReasonDialog> {
  String? selectedReason;
  bool isSubmitting = false;
  String? errorMessage;

  Future<void> _submit() async {
    if (selectedReason == null || isSubmitting) return;

    setState(() {
      isSubmitting = true;
      errorMessage = null;
    });

    try {
      await widget.onConfirm(selectedReason!);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          isSubmitting = false;
          errorMessage = 'Something went wrong. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // ✅ Requirement: white background dialog
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select a reason',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            ...widget.reasons.map(
              (reason) => RadioListTile<String>(
                value: reason,
                groupValue: selectedReason,
                activeColor: Colors.black,
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  reason,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                onChanged: isSubmitting
                    ? null
                    : (v) => setState(() => selectedReason = v),
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                errorMessage!,
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.confirmColor,
                      disabledBackgroundColor: widget.confirmColor.withOpacity(
                        0.4,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: selectedReason == null || isSubmitting
                        ? null
                        : _submit,
                    child: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            widget.confirmLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
