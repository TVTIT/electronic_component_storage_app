import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/model/component.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:flutter/material.dart';

class TopComponentsWidget extends StatelessWidget {
  const TopComponentsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final allComponents = SupabaseDatabaseController.listComponentCached
        .where((c) => c.quantity > 0)
        .toList();

    if (allComponents.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sắp xếp giảm dần → lấy top 5 nhiều nhất
    final sortedDesc = List<Component>.from(allComponents)
      ..sort((a, b) => b.quantity.compareTo(a.quantity));
    final topMost = sortedDesc.take(5).toList();

    // Sắp xếp tăng dần → lấy top 5 ít nhất
    final sortedAsc = List<Component>.from(allComponents)
      ..sort((a, b) => a.quantity.compareTo(b.quantity));
    final topLeast = sortedAsc.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 24,
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Tổng quan tồn kho',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.onSurfaceColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildColumn(
                title: 'Nhiều nhất',
                icon: Icons.arrow_upward_rounded,
                iconColor: AppColor.greenSafeColor,
                components: topMost,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildColumn(
                title: 'Ít nhất',
                icon: Icons.arrow_downward_rounded,
                iconColor: AppColor.errorColor,
                components: topLeast,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColumn({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Component> components,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColor.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...components.map((c) => _buildItem(c)),
      ],
    );
  }

  Widget _buildItem(Component component) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColor.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                component.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColor.onSurfaceColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              component.quantity.toString(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColor.primaryDarkColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
