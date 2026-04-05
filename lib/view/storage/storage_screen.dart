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
  bool _showCategoryFilter = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(icon: Icon(Icons.inventory), title: "Kho linh kiện"),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm linh kiện...",
                border: OutlineInputBorder( //Dùng outline cho to hơn
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

            SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: Component.listComponentTest.length,
                itemBuilder: (context, index) {
                  return ComponentInfoCard(component: Component.listComponentTest[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
