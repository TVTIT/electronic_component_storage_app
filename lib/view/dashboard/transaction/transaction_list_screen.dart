import 'dart:async';

import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/model/transaction_header.dart';
import 'package:electronic_component_storage_app/string_extension.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/dashboard/transaction/transaction_filter_widget.dart';
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
    if (_searchController.text.isNotEmpty ||
        _selectedType != null ||
        _selectedDateRange != null) {
      _displayListNotifier
          .value = SupabaseDatabaseController.listTransactionsCached.where((
        transaction,
      ) {
        final bool typeCondition =
            _selectedType == null || transaction.type == _selectedType;
        final bool dateRangeCondition =
            _selectedDateRange == null ||
            (transaction.createdAt.isAfter(_selectedDateRange!.start) &&
                transaction.createdAt.isBefore(
                  _selectedDateRange!.end.add(const Duration(days: 1)),
                )); //ngày bắt đầu từ 0h00 nên phải thêm 1 ngày để lấy toàn bộ của ngày đó
        return typeCondition &&
            dateRangeCondition &&
            transaction.userName.toUnaccented().toLowerCase().contains(
              _searchController.text.toLowerCase().toUnaccented(),
            );
      }).toList();
    } else {
      _displayListNotifier.value =
          SupabaseDatabaseController.listTransactionsCached;
    }
  }

  final _searchController = TextEditingController();
  bool _showCategoryFilter = true;
  Timer? _searchDebounce;

  TransactionType? _selectedType;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    _changeDisplayList();
    super.initState();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
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
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
          child: Column(
            children: [
              TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Tìm theo tên người thực hiện...",
                  border: OutlineInputBorder(
                    //Dùng outline cho to hơn
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColor.onGreyInputColor,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _showCategoryFilter = !_showCategoryFilter;
                      });
                    },
                    icon: Icon(Icons.tune, color: AppColor.onGreyInputColor),
                  ),
                ),
                onTapOutside: (event) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                onChanged: (value) {
                  if (_searchDebounce?.isActive ?? false) {
                    _searchDebounce!.cancel();
                  }

                  // Đặt timer mới, nếu sau 300ms mà không gõ thêm chữ nào thì mới chạy search
                  _searchDebounce = Timer(
                    const Duration(milliseconds: 300),
                    () {
                      _changeDisplayList();
                    },
                  );
                },
                onFieldSubmitted: (value) {
                  if (_searchDebounce?.isActive ?? false) {
                    _searchDebounce!.cancel();
                  }
                  _changeDisplayList();
                },
              ),

              const SizedBox(height: 10),

              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.fastOutSlowIn,
                alignment: Alignment.topCenter,
                child: _showCategoryFilter
                    ? TransactionFilterWidget(
                        onSelectedTypeChange: (value) {
                          _selectedType = value;
                          _changeDisplayList();
                        },
                        onSelectedDateRangeChange: (value) {
                          _selectedDateRange = value;
                          _changeDisplayList();
                        },
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 10),

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
