import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/model/component.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:flutter/material.dart';

class StorageStatWidget extends StatelessWidget {
  const StorageStatWidget({super.key});

  Map<String, int> _componentQuanity() {
    List<Component> listComonent =
        SupabaseDatabaseController.listComponentCached;
    Map<String, int> result = {'all': listComonent.length};

    int restockQuanity = listComonent.where((item) => item.isLowStock).length;
    int outOfStockQuanity = listComonent
        .where((item) => item.quantity == 0)
        .length;

    result['restock'] = restockQuanity;
    result['out_of_stock'] = outOfStockQuanity;

    return result;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, int> componentQuanityMap = _componentQuanity();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _buildStatCard(
            bgColor: AppColor.primaryContainer,
            icon: Icons.storage,
            iconColor: AppColor.onPrimaryContainer,
            label: "Tổng số linh kiện",
            value: "${componentQuanityMap['all']}",
            valueColor: Colors.white,
            badgeColor: AppColor.onPrimaryContainer.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            bgColor: AppColor.warningColor,
            icon: Icons.warning_amber_rounded,
            iconColor: AppColor.errorColor,
            label: "Linh kiện còn ít",
            value: "${componentQuanityMap['restock']}",
            valueColor: AppColor.onSurfaceColor,
            badgeColor: const Color(0xFF3F4949),
            borderColor: AppColor.outlineVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            bgColor: AppColor.tertiaryContainer,
            icon: Icons.error_outline,
            iconColor: Colors.white,
            label: "Linh kiện đã hết",
            value: "${componentQuanityMap['out_of_stock']}",
            valueColor: Colors.white,
            badgeColor: AppColor.onTertiaryContainer,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required Color bgColor,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
    required Color badgeColor,
    Color? borderColor,
  }) {
    return Container(
      width: 260,
      height: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: borderColor != null ? Border.all(color: borderColor) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: iconColor, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: badgeColor, // Reusing badge color for label as per UI
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
