import 'package:electronic_component_storage_app/view/storage/storage_screen.dart';
import 'package:flutter/material.dart';

class SelectComponentScreen extends StatelessWidget {
  const SelectComponentScreen({super.key, this.showOutOfStockComponent = false});
  final bool showOutOfStockComponent;

  @override
  Widget build(BuildContext context) {
    return StorageScreen(isSelectScreen: true, showOutOfStockComponentInSelectScreen: showOutOfStockComponent,);
  }
}