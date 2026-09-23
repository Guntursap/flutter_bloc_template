// lib/core/utility/notification_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/main.dart'
    show scaffoldMessengerKey;

void showAppMessage(String message, {bool isError = false}) {
  scaffoldMessengerKey.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
}
