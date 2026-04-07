import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/model/Component.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:flutter/material.dart';

class CategoryFilterWidget extends StatefulWidget {
  const CategoryFilterWidget({super.key});

  @override
  State<CategoryFilterWidget> createState() => _CategoryFilterWidgetState();
}

class _CategoryFilterWidgetState extends State<CategoryFilterWidget> {
  String _selectedKey = "all";

  @override
  Widget build(BuildContext context) {
    final categoryMap = SupabaseDatabaseController.categoryMapCached;
    final Map categoryMapWithAll = {
      'all': {'name': "Tất cả"},
      ...categoryMap,
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categoryMapWithAll.entries
            .map((entry) => _buildFilterItem(entry.key, entry.value['name']))
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
