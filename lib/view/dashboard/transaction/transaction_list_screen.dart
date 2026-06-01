import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/model/transaction_header.dart';
import 'package:electronic_component_storage_app/view/dashboard/transaction/transaction_info_card.dart';
import 'package:electronic_component_storage_app/view/my_app_bar.dart';
import 'package:flutter/material.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final ValueNotifier<List<TransactionHeader>> _displayListNotifier =
      ValueNotifier([]);

  void _changeDisplayList() {
    // if (_searchController.text.isNotEmpty) {
    //   _displayListNotifier.value = SupabaseDatabaseController.listTransactionsCached
    //       .where(
    //         (user) => user.fullName.toUnaccented().toLowerCase().contains(
    //           _searchController.text.toLowerCase().toUnaccented(),
    //         ),
    //       )
    //       .toList();
    // } else {
    //   _displayListNotifier.value = SupabaseDatabaseController.listTransactionsCached;
    // }
    _displayListNotifier.value =
        SupabaseDatabaseController.listTransactionsCached;
  }

  @override
  void initState() {
    _changeDisplayList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Lịch sử xuất/nhập kho",
        icon: Icon(Icons.import_export),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await SupabaseDatabaseController.getAllTransactionHistory();
          _changeDisplayList();
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _displayListNotifier,
                  builder: (context, value, widget) {
                    return ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        return TransactionInfoCard(
                          transactionHeader: value[index],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
