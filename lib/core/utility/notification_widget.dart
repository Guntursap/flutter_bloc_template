// lib/core/utility/notification_widget.dart
import 'package:flutter/material.dart';
// ponytail: context messenger breaks main.dart import cycle; upgrade to GlobalKey only if context unavailable.

void showAppMessage(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
}
