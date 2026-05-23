import 'package:electronic_component_storage_app/model/cabinet.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/dashboard/cabinet/add_cabinet_dialog.dart';
import 'package:flutter/material.dart';

class CabinetCard extends StatelessWidget {
  const CabinetCard({super.key, required this.cabinet, this.reloadDisplayList});

  final Cabinet cabinet;
  final VoidCallback? reloadDisplayList;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final bool? result = await showDialog<bool>(
          context: context,
          builder: (context) => AddCabinetDialog(cabinet: cabinet,),
        );
        if (result != null && result) {
          reloadDisplayList?.call();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16, bottom: 16),
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColor.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColor.onPrimaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.kitchen,
                color: AppColor.primaryColor,
                size: 20,
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cabinet.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColor.onSurfaceColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${cabinet.totalItem} linh kiện",
                  style: const TextStyle(
                    color: AppColor.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
