import 'dart:async';
import 'package:electronic_component_storage_app/control/supabase_account_controller.dart';
import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/model/component.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/my_app_bar.dart';
import 'package:electronic_component_storage_app/view/storage/category_filter_widget.dart';
import 'package:electronic_component_storage_app/view/storage/component_info_card.dart';
import 'package:electronic_component_storage_app/string_extension.dart';
import 'package:flutter/material.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  String _categorySelected = "all";

  bool _showCategoryFilter = true;

  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  List<Component> _searchComponent(String query) {
    final queryTrim = query.toLowerCase().toUnaccented().trim();
    return SupabaseDatabaseController.listComponentCached
        .where(
          (component) =>
              component.searchName.contains(queryTrim) &&
              (_categorySelected == "all" ||
                  component.categoryID == _categorySelected),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Component> listComponent =
        SupabaseDatabaseController.listComponentCached;

    List<Component> displayList;
    if (_searchController.text.isEmpty) {
      displayList = _categorySelected == "all"
          ? listComponent
          : listComponent
                .where((item) => item.categoryID == _categorySelected)
                .toList();
    } else {
      displayList = _searchComponent(_searchController.text);
    }

    return Scaffold(
      appBar: MyAppBar(icon: Icon(Icons.inventory), title: "Kho linh kiện"),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
        child: Column(
          children: [
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Tìm kiếm linh kiện...",
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
                _searchDebounce = Timer(const Duration(milliseconds: 300), () {
                  setState(() {});
                });
              },
            ),

            const SizedBox(height: 10),

            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.fastOutSlowIn,
              alignment: Alignment.topCenter,
              child: _showCategoryFilter
                  ? CategoryFilterWidget(
                      onCategoryChanged: (newKey) => setState(() {
                        _categorySelected = newKey;
                      }),
                    )
                  : SizedBox.shrink(),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await SupabaseDatabaseController.getInitialData();
                  setState(() {});
                },
                child: ListView.builder(
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    return ComponentInfoCard(component: displayList[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
