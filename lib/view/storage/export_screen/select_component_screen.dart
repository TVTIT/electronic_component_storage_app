import 'package:electronic_component_storage_app/view/storage/storage_screen.dart';
import 'package:flutter/material.dart';

class SelectComponentScreen extends StatelessWidget {
  const SelectComponentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StorageScreen(isExportScreen: true,);
  }
}