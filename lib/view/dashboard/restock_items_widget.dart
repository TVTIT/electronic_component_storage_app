import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:flutter/material.dart';

class RestockItemsWidget extends StatelessWidget {
  const RestockItemsWidget({super.key});

  Widget _buildRestockItem({
    required IconData icon,
    required String name,
    required String status,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEEEF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF556474)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColor.onSurfaceColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColor.errorColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            style: IconButton.styleFrom(
              backgroundColor: AppColor.primaryContainer,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
            icon: const Icon(Icons.add, size: 20),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
                const Text(
                  "Linh kiện cần bổ sung",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.onSurfaceColor,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "VIEW ALL",
                style: TextStyle(
                  color: AppColor.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColor.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildRestockItem(
                icon: Icons.memory,
                name: "Capacitor 100uF",
                status: "2 / 50 LEFT",
                bgColor: AppColor.surfaceContainerLowest,
              ),
              Divider(height: 1, color: AppColor.outlineVariant.withValues(alpha: 0.2)),
              _buildRestockItem(
                icon: Icons.settings_input_component,
                name: "LM741 Op-Amp",
                status: "5 / 20 LEFT",
                bgColor: AppColor.surfaceContainerLow,
              ),
            ],
          ),
        ),
      ],
    );
  }
}