import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/model/component.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/custom_widget.dart';
import 'package:electronic_component_storage_app/view/my_app_bar.dart';
import 'package:electronic_component_storage_app/view/storage/add_component/add_component_form.dart';
import 'package:electronic_component_storage_app/view/storage/add_component/add_component_info_card.dart';
import 'package:flutter/material.dart';

class AddComponentScreen extends StatefulWidget {
  const AddComponentScreen({super.key});

  @override
  State<AddComponentScreen> createState() => _AddComponentScreenState();
}

class _AddComponentScreenState extends State<AddComponentScreen> {
  final ValueNotifier<List<Component>> _listAddListen = ValueNotifier([]);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _listAddListen.dispose();
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
                  text: _listAddListen.value[index].name,
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
                  _listAddListen.value,
                );
                tempList.removeAt(index);
                _listAddListen.value = tempList;
                Navigator.pop(context);
              },
              child: const Text("Xác nhận"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addToDatabase() async {
    if (_listAddListen.value.isEmpty) {
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
      await SupabaseDatabaseController.addImportQuantityComponent(
        _listAddListen.value,
      );
      await SupabaseDatabaseController.getAllComponent();
      if (mounted) {
        CustomWidget.showFloatingSnackbar(
          context,
          text: "Thêm thành công ${_listAddListen.value.length} linh kiện",
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
      appBar: MyAppBar(title: "Nhập kho linh kiện"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _listAddListen,
                builder: (builder, value, child) {
                  return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      return AddComponentInfoCard(
                        key: ObjectKey(
                          value[index],
                        ), //Đánh dấu key bằng component đang hiện
                        component: value[index],
                        onQuantityChanged: (value) {
                          _listAddListen.value[index].quantity = value;
                        },
                        onDelete: () => _deleteComponent(index),
                        onTap: () async {
                          if (value[index].id != null) {
                            CustomWidget.showFloatingSnackbar(
                              context,
                              text: "Bạn không được sửa linh kiện có sẵn",
                            );
                          } else {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddComponentForm(component: value[index]),
                              ),
                            );
                            if (result != null) {
                              List<Component> temp = List.from(
                                _listAddListen.value,
                              );
                              temp[index] = result;
                              _listAddListen.value = temp;
                            }
                          }
                        },
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
                    valueListenable: _listAddListen,
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
                                builder: (context) => const AddComponentForm(),
                              ),
                            );
                            if (result != null) {
                              _listAddListen.value = [
                                ..._listAddListen.value,
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
                                  await _addToDatabase();
                                },
                                label: const Text(
                                  "Xác nhận nhập kho",
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
