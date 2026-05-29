import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/model/component.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/custom_widget.dart';
import 'package:electronic_component_storage_app/view/my_app_bar.dart';
import 'package:electronic_component_storage_app/view/storage/add_component/confirm/add_component_confirm_card.dart';
import 'package:flutter/material.dart';

class AddComponentConfirmScreen extends StatefulWidget {
  const AddComponentConfirmScreen({
    super.key,
    required this.displayListNotifier,
    this.isExport = false,
  });

  final ValueNotifier<List<Component>> displayListNotifier;
  final bool isExport;

  @override
  State<AddComponentConfirmScreen> createState() =>
      _AddComponentConfirmScreenState();
}

class _AddComponentConfirmScreenState extends State<AddComponentConfirmScreen> {
  bool _isLoading = false;

  String _appbarTitle = "Xác nhận nhập kho";
  late VoidCallback _onConfirmBtnTap = _addToDatabase;

  Future<void> _addToDatabase() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await SupabaseDatabaseController.addImportQuantityComponent(
        widget.displayListNotifier.value,
      );
      await SupabaseDatabaseController.getAllComponent();
      if (mounted) {
        CustomWidget.showFloatingSnackbar(
          context,
          text:
              "Thêm thành công ${widget.displayListNotifier.value.length} linh kiện",
        );

        Navigator.popUntilWithResult(context, (route) => route.isFirst, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Có lỗi xảy ra: $e')));
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _exportComponent() async {
    if (widget.displayListNotifier.value.isEmpty) {
      CustomWidget.showFloatingSnackbar(
        context,
        text: "Bạn chưa thêm linh kiện nào",
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      await SupabaseDatabaseController.exportBulkComponent(
        widget.displayListNotifier.value,
      );
      await SupabaseDatabaseController.getAllComponent();
      if (mounted) {
        CustomWidget.showFloatingSnackbar(
          context,
          text:
              "Xuất kho thành công ${widget.displayListNotifier.value.length} linh kiện",
        );

        Navigator.popUntilWithResult(context, (route) => route.isFirst, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Có lỗi xảy ra: $e')));
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    if (widget.displayListNotifier.value.isEmpty) {
      throw Exception("displayListNotifier.value is Empty");
    }
    if (widget.isExport) {
      _appbarTitle = "Xác nhận xuất kho";
      _onConfirmBtnTap = _exportComponent;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: _appbarTitle),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 15),
        children: [
          ListTile(
            title: const Text(
              "Vui lòng kiểm tra lại thông tin",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              "Đảm bảo danh sách linh kiện chính xác trước khi lưu vào hệ thống",
            ),
            leading: Icon(Icons.check_circle, color: AppColor.greenSafeColor),
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

          ValueListenableBuilder(
            valueListenable: widget.displayListNotifier,
            builder: (context, value, widget) {
              final int totalUnit = value.fold(
                0,
                (sum, component) => sum + component.quantity,
              );
              //Không dùng ListView.builder vì ở trên là ListView rồi
              return Column(
                children: [
                  Column(
                    children: value
                        .map(
                          (component) =>
                              AddComponentConfirmCard(component: component),
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
                            "${value.length} loại",
                          ),
                          const SizedBox(height: 5),
                          _buildSummaryInfo(
                            "Tống số lượng linh kiện:",
                            "$totalUnit đơn vị",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          if (_isLoading)
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                minimumSize: Size.fromHeight(50),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
            )
          else
            FilledButton.icon(
              onPressed: _onConfirmBtnTap,
              icon: Icon(Icons.check_circle_outline),
              label: const Text("Xác nhận"),
              style: FilledButton.styleFrom(
                minimumSize: Size.fromHeight(50),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
