import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/model/component.dart';
import 'package:electronic_component_storage_app/view/my_app_bar.dart';
import 'package:flutter/material.dart';

class AddComponentForm extends StatefulWidget {
  const AddComponentForm({super.key});

  @override
  State<AddComponentForm> createState() => _AddComponentFormState();
}

class _AddComponentFormState extends State<AddComponentForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minQuantityController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  String? _selectedLocation;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _minQuantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addComponent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final newComponent = {
          'name': _nameController.text.trim(),
          'part_number': '',
          'quantity': int.tryParse(_quantityController.text) ?? 0,
          'min_threshold': int.tryParse(_minQuantityController.text) ?? 0,
          'category_id': _selectedCategory,
          'location_id': _selectedLocation,
        };

        await SupabaseDatabaseController.supabase
            .from('components')
            .insert(newComponent);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thêm linh kiện thành công')),
          );
          // Cập nhật lại list component cache
          await SupabaseDatabaseController.getAllComponent();
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Có lỗi xảy ra: $e')),
          );
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

  @override
  Widget build(BuildContext context) {
    final categories = SupabaseDatabaseController.categoryMapCached;
    final locations = SupabaseDatabaseController.locationMapCached;

    return Scaffold(
      appBar: MyAppBar(title: "Thêm linh kiện mới"),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            const Text('Tên linh kiện', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(hintText: 'Nhập tên linh kiện'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Vui lòng nhập tên linh kiện' : null,
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Số lượng', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(hintText: '0'),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Nhập số lượng' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mức báo hết', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _minQuantityController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(hintText: '0'),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            const Text('Danh mục', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(hintText: 'Chọn danh mục'),
              items: categories.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value['name']?.toString() ?? entry.key),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value),
              validator: (value) => value == null ? 'Vui lòng chọn danh mục' : null,
            ),

            const SizedBox(height: 15),

            const Text('Vị trí', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            DropdownButtonFormField<String>(
              initialValue: _selectedLocation,
              decoration: const InputDecoration(hintText: 'Chọn vị trí'),
              items: locations.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value['name']?.toString() ?? entry.key),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedLocation = value),
              validator: (value) => value == null ? 'Vui lòng chọn vị trí' : null,
            ),
            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: _isLoading ? null : _addComponent,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Thêm linh kiện'),
            ),
          ],
        ),
      ),
    );
  }
}