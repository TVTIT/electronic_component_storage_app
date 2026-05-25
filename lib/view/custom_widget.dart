import 'package:flutter/material.dart';

class CustomWidget {
  static void showFloatingSnackbar(
    BuildContext context, {
    required String text,
    EdgeInsetsGeometry margin = const EdgeInsets.only(
      bottom: 40,
      left: 20,
      right: 20,
    ),
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text(text)),
          behavior: SnackBarBehavior.floating,
          margin: margin,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: duration,
        ),
      );
    }
  }
}
