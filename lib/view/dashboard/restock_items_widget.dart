import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/model/component.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/dashboard/need_supplement_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RestockItemsWidget extends StatelessWidget {
  const RestockItemsWidget({super.key});

  Widget _buildRestockItem(
    BuildContext context, {
    required Component component,
  }) {
    final String imageUrl = SupabaseDatabaseController
        .categoryMapCached[component.categoryID]['image_url'];
    final name = component.name;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEEEF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.network(imageUrl),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColor.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  component.quantity == 0
                      ? "Hết hàng"
                      : "Còn lại ${component.quantity} sản phẩm",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColor.errorColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Component> displayList = SupabaseDatabaseController.listComponentCached
        .where((item) => item.isLowStock)
        .toList();
    if (displayList.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 6,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF84000D),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "Linh kiện cần bổ sung (${displayList.length})",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.onSurfaceColor,
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NeedSupplementScreen(),
                    ),
                  );
                },
                child: const Text(
                  "XEM TẤT CẢ",
                  style: TextStyle(
                    color: AppColor.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: displayList
              .map(
                (component) => _buildRestockItem(context, component: component),
              )
              .take(2)
              .toList(),
        ),
      ],
    );
  }
}
