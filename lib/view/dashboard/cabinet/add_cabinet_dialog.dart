import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/model/cabinet.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:flutter/material.dart';

class AddCabinetDialog extends StatefulWidget {
  const AddCabinetDialog({super.key, this.cabinet});

  final Cabinet? cabinet;

  @override
  State<AddCabinetDialog> createState() => _AddCabinetDialogState();
}

class _AddCabinetDialogState extends State<AddCabinetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  bool _isDeleting = false;
  late String _errorMsg = "";

  late String _title = "Thêm ngăn tủ mới";
  late String _btnText = "Thêm";
  late VoidCallback _onClickBtn = _addCabinet;
  late MainAxisAlignment _actionAlignment = MainAxisAlignment.end;

  Future<void> _addCabinet() async {
    if (_formKey.currentState!.validate()) {
      final newCabinet = Cabinet(
        name: _nameController.text,
        description: _descriptionController.text,
      );
      try {
        setState(() {
          _isLoading = true;
        });
        await SupabaseDatabaseController.addLocation(newCabinet);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(child: Text("Thêm ngăn tủ mới thành công")),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(milliseconds: 1500),
            ),
          );
        }
        await SupabaseDatabaseController.getAllLocation();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Có lỗi xảy ra $e")));
          Navigator.of(context).pop(false);
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _editCabinet() async {
    if (_formKey.currentState!.validate()) {
      widget.cabinet!.name = _nameController.text;
      widget.cabinet!.description = _descriptionController.text;
      try {
        setState(() {
          _isLoading = true;
        });
        await SupabaseDatabaseController.editLocation(widget.cabinet!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(child: Text("Sửa ngăn tủ thành công")),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(milliseconds: 1500),
            ),
          );
        }
        await SupabaseDatabaseController.getAllLocation();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Có lỗi xảy ra $e")));
          Navigator.of(context).pop(false);
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _deleteCabinet() async {
    if (widget.cabinet!.totalItem > 0) {
      setState(() {
        _errorMsg =
            "Ngăn tủ còn linh kiện. Vui lòng xoá hết linh kiện trước khi xoá ngăn tủ.";
      });
      return;
    }
    try {
      setState(() {
        _isDeleting = true;
      });
      await SupabaseDatabaseController.deleteLocation(widget.cabinet!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text("Xoá ngăn tủ thành công")),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
      await SupabaseDatabaseController.getAllLocation();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Có lỗi xảy ra $e")));
        Navigator.of(context).pop(false);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    if (widget.cabinet != null &&
        widget.cabinet!.id != null &&
        widget.cabinet!.id!.isNotEmpty) {
      _title = "Sửa ngăn tủ";
      _btnText = "Sửa";

      _nameController.text = widget.cabinet!.name;
      _descriptionController.text = widget.cabinet!.description ?? "";

      _onClickBtn = _editCabinet;

      _actionAlignment = MainAxisAlignment.spaceBetween;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> action = [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text("Huỷ"),
          ),
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                )
              : TextButton(onPressed: _onClickBtn, child: Text(_btnText)),
        ],
      ),
    ];

    if (widget.cabinet != null) {
      if (_isDeleting) {
        action.insert(
          0,
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColor.errorColor,
            ),
          ),
        );
      } else {
        action.insert(
          0,
          TextButton.icon(
            onPressed: _deleteCabinet,
            label: const Text("Xoá"),
            icon: Icon(Icons.delete_forever_rounded),
            style: TextButton.styleFrom(foregroundColor: AppColor.errorColor),
          ),
        );
      }
    }
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(_title),
      scrollable: true,
      content: SizedBox(
        width: 300,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tên ngăn tủ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Không được bỏ trống";
                  }
                  return null;
                },
                decoration: InputDecoration(hintText: "Nhập tên ngăn tủ"),
              ),
              const SizedBox(height: 10),

              const Text(
                "Mô tả",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _descriptionController,
                keyboardType: TextInputType.multiline,
                minLines: 4,
                maxLines: 4,
                decoration: InputDecoration(hintText: "Nhập mô tả"),
              ),

              const SizedBox(height: 10),

              _errorMsg.isEmpty
                  ? const SizedBox.shrink()
                  : Text(
                      _errorMsg,
                      style: TextStyle(color: AppColor.errorColor),
                    ),
            ],
          ),
        ),
      ),

      actionsAlignment: _actionAlignment,
      actions: action,
    );
  }
}
