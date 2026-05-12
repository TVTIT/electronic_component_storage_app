import 'dart:async';
import 'package:electronic_component_storage_app/control/supabase_account_controller.dart';
import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/model/component.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/my_app_bar.dart';
import 'package:electronic_component_storage_app/view/storage/add_component/add_component_screen.dart';
import 'package:electronic_component_storage_app/view/storage/category_filter_widget.dart';
import 'package:electronic_component_storage_app/view/storage/component_info_card.dart';
import 'package:electronic_component_storage_app/view/storage/add_component/add_component_form.dart';
import 'package:electronic_component_storage_app/string_extension.dart';
import 'package:electronic_component_storage_app/view/storage/export_screen/export_component_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({
    super.key,
    this.isSelectScreen = false,
    this.showOutOfStockComponentInSelectScreen = false,
    this.showLowAndOutOfStockComponent = false,
  });

  final bool isSelectScreen;
  final bool showOutOfStockComponentInSelectScreen;
  final bool showLowAndOutOfStockComponent;

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  String _title = "Kho linh kiện";
  Icon? _appBarIcon = const Icon(Icons.inventory);

  String _categorySelected = "all";

  bool _showCategoryFilter = true;
  bool _isScrolling = false;
  final _fabKey = GlobalKey<ExpandableFabState>();

  //List<Component> _displayList = [];
  final ValueNotifier<List<Component>> _displayListNotifier = ValueNotifier([]);

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

  void _chanegDisplayList() {
    if (_searchController.text.isNotEmpty) {
      _displayListNotifier.value = _searchComponent(_searchController.text);
    } else {
      if (_categorySelected == 'all') {
        _displayListNotifier.value =
            SupabaseDatabaseController.listComponentCached;
      } else {
        _displayListNotifier.value = SupabaseDatabaseController
            .listComponentCached
            .where((component) => component.categoryID == _categorySelected)
            .toList();
      }
    }

    if (widget.isSelectScreen &&
        !widget.showOutOfStockComponentInSelectScreen) {
      _displayListNotifier.value = List.from(
        _displayListNotifier.value
            .where((component) => component.quantity > 0)
            .toList(),
      );
    }

    if (widget.showLowAndOutOfStockComponent) {
      _displayListNotifier.value = List.from(
        _displayListNotifier.value
            .where((component) => component.quantity < component.minThreshold)
            .toList(),
      );
    }
  }

  @override
  void initState() {
    if (widget.showLowAndOutOfStockComponent &&
        (widget.isSelectScreen ||
            widget.showOutOfStockComponentInSelectScreen)) {
      throw Exception(
        "(widget.showLowAndOutOfStockComponent && (widget.isSelectScreen || widget.showOutOfStockComponentInSelectScreen)) is not false",
      );
    }
    if (widget.isSelectScreen) {
      _title = "Chọn linh kiện";
      _appBarIcon = null;
    } else if (widget.showLowAndOutOfStockComponent) {
      _title = "Linh kiện cần bổ sung";
      _appBarIcon = null;
    }
    _chanegDisplayList();
    super.initState();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _displayListNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(icon: _appBarIcon, title: _title),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton:
          widget.isSelectScreen || widget.showLowAndOutOfStockComponent
          ? null
          : AnimatedOpacity(
              opacity: _isScrolling ? 0.3 : 1,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: ExpandableFab(
                key: _fabKey,
                distance: 70,
                childrenAnimation: ExpandableFabAnimation.none,
                type: ExpandableFabType.up,
                overlayStyle: ExpandableFabOverlayStyle(blur: 8),
                openButtonBuilder: DefaultFloatingActionButtonBuilder(
                  backgroundColor: AppColor.primaryColor,
                  foregroundColor: Colors.white,
                  child: Icon(Icons.menu),
                ),
                closeButtonBuilder: DefaultFloatingActionButtonBuilder(
                  backgroundColor: AppColor.primaryColor,
                  foregroundColor: Colors.white,
                  child: Icon(Icons.close),
                ),
                children: [
                  FloatingActionButton.extended(
                    heroTag: null,
                    backgroundColor: AppColor.primaryColor,
                    foregroundColor: Colors.white,
                    label: const Text("Xuất kho linh kiện"),
                    icon: Icon(Icons.outbox),
                    onPressed: () async {
                      final fabState = _fabKey.currentState;
                      if (fabState != null && fabState.isOpen) {
                        fabState.toggle();
                      }
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ExportComponentScreen(),
                        ),
                      );
                      if (result == true) {
                        _chanegDisplayList();
                      }
                    },
                  ),
                  FloatingActionButton.extended(
                    heroTag: null,
                    backgroundColor: AppColor.primaryColor,
                    foregroundColor: Colors.white,
                    label: const Text("Nhập kho linh kiện"),
                    icon: Icon(Icons.add_box_outlined),
                    onPressed: () async {
                      final fabState = _fabKey.currentState;
                      if (fabState != null && fabState.isOpen) {
                        fabState.toggle();
                      }
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddComponentScreen(),
                        ),
                      );
                      if (result == true) {
                        _chanegDisplayList();
                      }
                    },
                  ),
                ],
              ),
            ),
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
                  _chanegDisplayList();
                });
              },
              onFieldSubmitted: (value) {
                if (_searchDebounce?.isActive ?? false) {
                  _searchDebounce!.cancel();
                }
                _chanegDisplayList();
              },
            ),

            const SizedBox(height: 10),

            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.fastOutSlowIn,
              alignment: Alignment.topCenter,
              child: _showCategoryFilter
                  ? CategoryFilterWidget(
                      selectedCategory: _categorySelected,
                      onCategoryChanged: (newKey) => setState(() {
                        _categorySelected = newKey;
                        _chanegDisplayList();
                      }),
                    )
                  : SizedBox.shrink(),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await SupabaseDatabaseController.getInitialData();
                  _chanegDisplayList();
                },
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollStartNotification ||
                        notification is ScrollUpdateNotification) {
                      setState(() {
                        _isScrolling = true;
                      });
                    } else if (notification is ScrollEndNotification) {
                      setState(() {
                        _isScrolling = false;
                      });
                    }
                    return false;
                  },
                  child: ValueListenableBuilder(
                    valueListenable: _displayListNotifier,
                    builder: (builder, value, child) {
                      return ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return ComponentInfoCard(
                            component: value[index],
                            onTap: (component) async {
                              if (widget.isSelectScreen) {
                                Navigator.of(context).pop(component);
                              } else {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AddComponentForm(
                                      component: component,
                                      isFromStogareScreen: true,
                                    ),
                                  ),
                                );
                                if (result != null && result) {
                                  _chanegDisplayList();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Center(
                                          child: Text(
                                            "Cập nhật thông tin thành công",
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
