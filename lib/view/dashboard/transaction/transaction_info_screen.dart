import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/model/component.dart';
import 'package:electronic_component_storage_app/model/transaction_header.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/dashboard/transaction/transaction_details_card.dart';
import 'package:electronic_component_storage_app/view/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionInfoScreen extends StatefulWidget {
  const TransactionInfoScreen({super.key, required this.transactionHeader});

  final TransactionHeader transactionHeader;

  @override
  State<TransactionInfoScreen> createState() => _TransactionInfoScreenState();
}

class _TransactionInfoScreenState extends State<TransactionInfoScreen> {
  List<Component> _listComponent = [];

  Future<void> _loadListComponent() async {
    final temp = await SupabaseDatabaseController.getTransactionDetails(
      widget.transactionHeader.id,
    );
    setState(() {
      _listComponent = temp;
    });
  }

  @override
  void initState() {
    _loadListComponent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_listComponent.isEmpty) {
      return Scaffold(
        appBar: MyAppBar(
          title:
              "Lịch sử ${widget.transactionHeader.type.displayName.toLowerCase()}",
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: MyAppBar(
        title:
            "Lịch sử ${widget.transactionHeader.type.displayName.toLowerCase()}",
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 15),
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Thông tin giao dịch",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),

                const SizedBox(height: 10),

                _buildSummaryInfo(
                  "Loại giao dịch:",
                  widget.transactionHeader.type.displayName,
                ),
                const SizedBox(height: 5),
                _buildSummaryInfo(
                  "Người thực hiện:",
                  widget.transactionHeader.userName,
                ),
                const SizedBox(height: 5),
                _buildSummaryInfo(
                  "Thời gian:",
                  DateFormat(
                    "HH:mm dd/MM/yyyy",
                  ).format(widget.transactionHeader.createdAt.toLocal()),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "DANH SÁCH LINH KIỆN",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColor.onsurfaceContainerLow,
              fontSize: 16,
            ),
          ),

          Column(
            children: [
              Column(
                children: _listComponent
                    .map(
                      (component) =>
                          TransactionDetailsCard(component: component),
                    )
                    .toList(),
              ),

              const SizedBox(height: 50),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tổng quan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildSummaryInfo(
                        "Tổng số loại linh kiện:",
                        "${widget.transactionHeader.totalComponent} loại",
                      ),
                      const SizedBox(height: 5),
                      _buildSummaryInfo(
                        "Tống số lượng linh kiện:",
                        "${widget.transactionHeader.totalAmount} đơn vị",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryInfo(String title, String detail) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(detail, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
