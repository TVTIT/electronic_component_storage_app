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
  List<Component> _listComponent = [];
  Map<String, dynamic> _categoryMap = {};
  Map<String, dynamic> _locationMap = {};

  bool _isLoading = true;

  bool _showCategoryFilter = true;

  Future<void> _getDataRequired() async {
    setState(() {
      _isLoading = true;
    });
    _listComponent = await SupabaseDatabaseController.getAllComponent();
    _categoryMap = await SupabaseDatabaseController.getAllCategory();
    _locationMap = await SupabaseDatabaseController.getAllLocation();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _getDataRequired();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  icon: Icon(Icons.tune, color: AppColor.onGreyInputColor),
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
                  ? CategoryFilterWidget()
                  : SizedBox.shrink(),
            ),

            SizedBox(height: 10),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: _listComponent.length,
                      itemBuilder: (context, index) {
                        return ComponentInfoCard(
                          component: _listComponent[index],
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
