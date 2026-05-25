import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/model/component.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/custom_widget.dart';
import 'package:electronic_component_storage_app/view/my_app_bar.dart';
import 'package:electronic_component_storage_app/view/storage/add_component/add_component_info_card.dart';
import 'package:electronic_component_storage_app/view/storage/export_screen/select_component_screen.dart';
import 'package:flutter/material.dart';

class ExportComponentScreen extends StatefulWidget {
  const ExportComponentScreen({super.key});

  @override
  State<ExportComponentScreen> createState() => _ExportComponentScreenState();
}

class _ExportComponentScreenState extends State<ExportComponentScreen> {
  final ValueNotifier<List<Component>> _listExportListen = ValueNotifier([]);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _listExportListen.dispose();
  }

  void _deleteComponent(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                const TextSpan(text: "Bạn có chắc chắn muốn xóa linh kiện "),
                TextSpan(
                  text: _listExportListen.value[index].name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text: " không?\nBạn không thể hoàn tác hành động này.",
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                final List<Component> tempList = List.from(
                  _listExportListen.value,
                );
                tempList.removeAt(index);
                _listExportListen.value = tempList;
                Navigator.pop(context);
              },
              child: const Text("Xác nhận"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportComponent() async {
    if (_listExportListen.value.isEmpty) {
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
      await SupabaseDatabaseController.exportBulkComponent(_listExportListen.value);
      await SupabaseDatabaseController.getAllComponent();
      if (mounted) {
        CustomWidget.showFloatingSnackbar(
          context,
          text:
              "Xuất kho thành công ${_listExportListen.value.length} linh kiện",
        );

        Navigator.pop(context, true);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Xuất kho linh kiện"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _listExportListen,
                builder: (builder, value, child) {
                  return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      return AddComponentInfoCard(
                        key: ObjectKey(value[index]), //Đánh dấu key bằng component đang hiện
                        isExportScreen: true,
                        component: value[index],
                        onQuantityChanged: (value) {
                          _listExportListen.value[index].quantity = value;
                        },
                        onDelete: () => _deleteComponent(index),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  ValueListenableBuilder(
                    valueListenable: _listExportListen,
                    builder: (context, value, child) {
                      return RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            const TextSpan(text: "Tổng cộng: "),
                            TextSpan(
                              text: value.length.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: " linh kiện"),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SelectComponentScreen()
                              ),
                            );
                            if (result != null) {
                              _listExportListen.value = [
                                ..._listExportListen.value,
                                result,
                              ];
                            }
                          },
                          label: const Text("Thêm linh kiện"),
                          icon: const Icon(Icons.add_circle_outline),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColor.secondaryContainer,
                            foregroundColor: AppColor.onSecondaryFixedVariant,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 5),

                      Expanded(
                        child: _isLoading
                            ? FilledButton(
                                onPressed: () {},
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const SizedBox(
                                  //Dùng SizedBox để lock lại kích thước cho giống nút khi không load
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : FilledButton.icon(
                                onPressed: () async {
                                  await _exportComponent();
                                },
                                label: const Text(
                                  "Xác nhận xuất kho",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                icon: const Icon(Icons.check_circle_outline),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
