import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key, this.icon, required this.title});

  final Icon? icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    Text titleText = Text(
      title,
      style: TextStyle(
        color: AppColor.primaryColor,
        fontWeight: FontWeight.bold,
      ),
    );
    if (icon == null) {
      return AppBar(title: titleText);
    }
    return AppBar(
      title: Row(
        children: [
          Icon(icon!.icon, color: AppColor.primaryColor, size: 28),

          SizedBox(width: 15),

          titleText
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
