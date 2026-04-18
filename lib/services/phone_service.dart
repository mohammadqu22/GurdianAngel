import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Initiates a phone call and shows a snackbar if the call cannot be launched.
class PhoneService {
  PhoneService._();

  /// Dials [number] and shows a snackbar with [errorMessage] on failure.
  ///
  /// [duration] overrides the default SnackBar display duration.
  static Future<void> call(
    String number,
    BuildContext context,
    String errorMessage, {
    Duration? duration,
  }) async {
    final uri = Uri(scheme: 'tel', path: number);
    bool failed = false;
    try {
      failed = !await launchUrl(uri);
    } catch (_) {
      failed = true;
    }
    if (failed && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: duration ?? const Duration(milliseconds: 4000),
        ),
      );
    }
  }
}
