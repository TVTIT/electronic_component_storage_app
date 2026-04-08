import 'package:electronic_component_storage_app/control/supabase_account_controller.dart';
import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/model/component.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/my_app_bar.dart';
import 'package:electronic_component_storage_app/view/storage/category_filter_widget.dart';
import 'package:electronic_component_storage_app/view/storage/component_info_card.dart';
import 'package:flutter/material.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  List<Component> _listComponent = SupabaseDatabaseController.listComponentCached;
  String _categorySelected = "all";

  bool _showCategoryFilter = true;

  @override
  Widget build(BuildContext context) {
    List<Component> displayList = _categorySelected == "all"
        ? _listComponent
        : _listComponent
              .where((item) => item.categoryID == _categorySelected)
              .toList();
    return Scaffold(
      appBar: MyAppBar(icon: Icon(Icons.inventory), title: "Kho linh kiện"),
      body: Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: Column(
                children: [
                  TextField(
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
                        icon: Icon(
                          Icons.tune,
                          color: AppColor.onGreyInputColor,
                        ),
                      ),
                    ),
                    onTapOutside: (event) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),

                  const SizedBox(height: 10),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.fastOutSlowIn,
                    alignment: Alignment.topCenter,
                    child: _showCategoryFilter
                        ? CategoryFilterWidget(onCategoryChanged: (newKey) => setState(() {
                          _categorySelected = newKey;
                        }))
                        : SizedBox.shrink(),
                  ),

                  SizedBox(height: 10),

                  Expanded(
                    child: ListView.builder(
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        return ComponentInfoCard(
                          component: displayList[index],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
