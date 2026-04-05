import 'package:electronic_component_storage_app/model/Component.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:flutter/material.dart';

class CategoryFilterWidget extends StatefulWidget {
  const CategoryFilterWidget({super.key});

  @override
  State<CategoryFilterWidget> createState() => _CategoryFilterWidgetState();
}

class _CategoryFilterWidgetState extends State<CategoryFilterWidget> {
  final List<String> _categories = [
    'Tất cả',
    'IC',
    'Điện trở',
    'Tụ điện',
    'Cuộn cảm',
    'Cảm biến',
    'Khác',
  ];
  String _selectedKey = Component.categoryMap.keys.first;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: Component.categoryMap.entries
            .map((entry) => _buildFilterItem(entry.key, entry.value))
            .toList(),
      ),
    );
  }

  Widget _buildFilterItem(String key, String value) {
    bool isSelected = key == _selectedKey;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedKey = key;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColor.primaryContainer
                : AppColor.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColor.onsurfaceContainerLow,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
