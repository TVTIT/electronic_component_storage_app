import 'dart:async';

import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/model/cabinet.dart';
import 'package:electronic_component_storage_app/string_extension.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/dashboard/cabinet/add_cabinet_dialog.dart';
import 'package:electronic_component_storage_app/view/dashboard/cabinet/cabinet_card.dart';
import 'package:electronic_component_storage_app/view/my_app_bar.dart';
import 'package:flutter/material.dart';

class CabinetManagementScreen extends StatefulWidget {
  const CabinetManagementScreen({super.key});

  @override
  State<CabinetManagementScreen> createState() =>
      _CabinetManagementScreenState();
}

class _CabinetManagementScreenState extends State<CabinetManagementScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  final ValueNotifier<List<Cabinet>> _displayListNotifier = ValueNotifier([]);

  void _changeDisplayList() {
    if (_searchController.text.isNotEmpty) {
      _displayListNotifier.value = SupabaseDatabaseController.listCabinetCached
          .where(
            (cabinet) => cabinet.name.toUnaccented().toLowerCase().contains(
              _searchController.text.toLowerCase().toUnaccented(),
            ),
          )
          .toList();
    } else {
      _displayListNotifier.value = SupabaseDatabaseController.listCabinetCached;
    }
  }

  @override
  void initState() {
    _changeDisplayList();
    super.initState();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _displayListNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 600 ? 4 : 2;
    return Scaffold(
      appBar: MyAppBar(
        title: "Quản lý ngăn tủ",
        icon: Icon(Icons.kitchen_outlined),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.primaryContainer,
        foregroundColor: Colors.white,
        onPressed: () async {
          final bool? result = await showDialog<bool>(
            context: context,
            builder: (context) => AddCabinetDialog(),
          );
          if (result != null && result) {
            _changeDisplayList();
          }
        },
        child: Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await SupabaseDatabaseController.getAllLocation();
          _changeDisplayList();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
          child: Column(
            children: [
              TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Tìm kiếm ngăn tủ...",
                  border: OutlineInputBorder(
                    //Dùng outline cho to hơn
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColor.onGreyInputColor,
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

              const SizedBox(height: 20),

              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _displayListNotifier,
                  builder: (context, value, child) {
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 1,
                      ),
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        return CabinetCard(cabinet: value[index], reloadDisplayList: _changeDisplayList,);
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
