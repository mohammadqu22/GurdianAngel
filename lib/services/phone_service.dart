import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Initiates a phone call and shows a snackbar if the call cannot be launched.
class PhoneService {
  PhoneService._();

  static Future<void> call(
    String number,
    BuildContext context,
    String errorMessage,
  ) async {
    final uri = Uri(scheme: 'tel', path: number);
    try {
      await launchUrl(uri);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }
}
