import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/dashboard/transaction/transaction_info_card.dart';
import 'package:electronic_component_storage_app/view/dashboard/transaction/transaction_list_screen.dart';
import 'package:flutter/material.dart';

class TransactionsListWidget extends StatelessWidget {
  const TransactionsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final listTransactionDisplay = SupabaseDatabaseController
        .listTransactionsCached
        .take(3);
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
                    color: AppColor.primaryDarkColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Lịch sử xuất/nhập kho",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.onSurfaceColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => TransactionListScreen()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColor.primaryColor,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'XEM TẤT CẢ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Column(
          children: listTransactionDisplay
              .map(
                (e) => TransactionInfoCard(transactionHeader: e,),
              )
              .toList(),
        ),
      ],
    );
  }
}
