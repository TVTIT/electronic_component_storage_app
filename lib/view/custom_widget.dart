import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  static Future<File?> showChooseImageDialog(BuildContext context) async {
    bool? isCamera = false;
    if (context.mounted) {
      isCamera = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt_rounded),
                title: const Text("Camera"),
                onTap: () => Navigator.pop(context, true),
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: const Text("Thư viện ảnh"),
                onTap: () => Navigator.pop(context, false),
              ),
            ],
          ),
        ),
      );
    }
    if (isCamera == null) {
      return null;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 100, // Lấy chất lượng gốc trước để tự nén sau
    );

    if (pickedFile == null) {
      return null;
    }

    return File(pickedFile.path);
  }
}
