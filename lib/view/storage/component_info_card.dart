import 'package:electronic_component_storage_app/model/component.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:flutter/material.dart';

class ComponentInfoCard extends StatelessWidget {
  const ComponentInfoCard({super.key, required this.component});

  final Component component;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoBlock(
                  label: "Phân loại: ${Component.categoryMap[component.category] ?? "Khác"}",
                  value: component.name,
                ),
                _buildWarningBadge(),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoBlock(label: "Vị trí", value: component.location),
                _buildInfoBlock(
                  label: "Số lượng",
                  value: component.quantity.toString(),
                  valueSize: 32,
                  valueColor: component.isLowStock ? AppColor.errorColor: AppColor.greenSafeColor,
                  alignment: CrossAxisAlignment.end,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBlock({
    required String label,
    required String value,
    double valueSize = 20,
    Color? valueColor,
    CrossAxisAlignment alignment = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColor.onsurfaceContainerLow,
            fontSize: 14,
            // fontWeight:
            //     FontWeight.w300,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColor.onsurfaceContainerLow,
            fontSize: valueSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWarningBadge() {
    if (!component.isLowStock) {
      return SizedBox.shrink();
    }

    String text;
    Color backgroundColor, foregroundColor;
    if (component.quantity == 0) {
      text = "Hết hàng";
      backgroundColor = AppColor.errorColor;
      foregroundColor = Colors.white;
    }
    else {
      text = "Còn ít";
      backgroundColor = AppColor.warningColor;
      foregroundColor = AppColor.onWarningColorLow;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: foregroundColor, size: 18),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
