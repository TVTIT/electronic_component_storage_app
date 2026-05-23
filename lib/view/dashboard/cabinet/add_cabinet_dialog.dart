import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/model/cabinet.dart';
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

  late String _title = "Thêm ngăn tủ mới";
  late String _btnText = "Thêm";
  late VoidCallback _onClickBtn = _addCabinet;

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
        await SupabaseDatabaseController.getAllLocation();
        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Có lỗi xảy ra $e")));
        Navigator.of(context).pop(false);
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
        await SupabaseDatabaseController.getAllLocation();
        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Có lỗi xảy ra $e")));
        Navigator.of(context).pop(false);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void initState() {
    if (widget.cabinet != null && widget.cabinet!.id != null && widget.cabinet!.id!.isNotEmpty) {
      _title = "Sửa ngăn tủ";
      _btnText = "Sửa";

      _nameController.text = widget.cabinet!.name;
      _descriptionController.text = widget.cabinet!.description ?? "";

      _onClickBtn = _editCabinet;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(_title),
      content: Form(
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

            const Text("Mô tả", style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _descriptionController,
              keyboardType: TextInputType.multiline,
              minLines: 4,
              maxLines: 4,
              decoration: InputDecoration(hintText: "Nhập mô tả"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text("Huỷ"),
        ),
        _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : TextButton(onPressed: _onClickBtn, child: Text(_btnText)),
      ],
    );
  }
}
