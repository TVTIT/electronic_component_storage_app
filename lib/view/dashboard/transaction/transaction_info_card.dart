import 'package:electronic_component_storage_app/model/transaction_header.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/dashboard/transaction/transaction_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionInfoCard extends StatelessWidget {
  final TransactionHeader transactionHeader;

  const TransactionInfoCard({super.key, required this.transactionHeader});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 15),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColor.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  TransactionInfoScreen(transactionHeader: transactionHeader),
            ),
          );
        },
        child: Row(
          children: [
            Icon(
              transactionHeader.type.icon,
              color: transactionHeader.type.color,
              size: 56,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transactionHeader.type.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      color: AppColor.onSurfaceColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 14,
                        color: Color(0xFF6F7979),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          transactionHeader.userName,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            color: AppColor.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        size: 14,
                        color: Color(0xFF6F7979),
                      ),

                      const SizedBox(width: 4),

                      Expanded(
                        child: Text(
                          DateFormat(
                            "HH:mm dd/MM/yyyy",
                          ).format(transactionHeader.createdAt.toLocal()),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            color: AppColor.onSurfaceVariant,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            const Icon(Icons.chevron_right, color: Color(0xFF6F7979), size: 24),
          ],
        ),
      ),
    );
  }
}
