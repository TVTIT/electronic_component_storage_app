import 'package:electronic_component_storage_app/model/component.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:flutter/material.dart';

class TransactionDetailsCard extends StatelessWidget {
  const TransactionDetailsCard({super.key, required this.component});

  final Component component;

  Widget _buildInfoBlock(Component component) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            component.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 5),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColor.surfaceContainerLow,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              component.categoryName ?? "Phân loại đã bị xoá",
              style: TextStyle(
                color: AppColor.onsurfaceContainerLow,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 5),

          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.shelves),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  component.locationName ?? "Ngăn tủ đã bị xoá",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoBlock(component),

            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(text: "x", style: TextStyle(fontSize: 20)),
                  TextSpan(
                    text: component.quantity.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
