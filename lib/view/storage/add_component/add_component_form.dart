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

  // Resistor Controllers
  final _resistanceController = TextEditingController();
  final _powerController = TextEditingController();
  final _toleranceController = TextEditingController();
  final _resistorPackageController = TextEditingController();

  // Capacitor Controllers
  final _capacitanceController = TextEditingController();
  final _voltageMaxController = TextEditingController();
  final _capacitorTypeController = TextEditingController();
  final _capacitorPackageController = TextEditingController();

  // IC Controllers
  final _pinsController = TextEditingController();
  final _icPackageController = TextEditingController();
  final _voltageRangeController = TextEditingController();
  final _familyController = TextEditingController();

  // Inductor Controllers
  final _inductanceController = TextEditingController();
  final _currentMaxController = TextEditingController();
  final _inductorTypeController = TextEditingController();

  // Sensor Controllers
  final _interfaceController = TextEditingController();
  final _sensorVoltageInController = TextEditingController();
  final _chipsetController = TextEditingController();

  String? _selectedCategory;
  String? _selectedLocation;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _minQuantityController.dispose();
    _descriptionController.dispose();

    _resistanceController.dispose();
    _powerController.dispose();
    _toleranceController.dispose();
    _resistorPackageController.dispose();

    _capacitanceController.dispose();
    _voltageMaxController.dispose();
    _capacitorTypeController.dispose();
    _capacitorPackageController.dispose();

    _pinsController.dispose();
    _icPackageController.dispose();
    _voltageRangeController.dispose();
    _familyController.dispose();

    _inductanceController.dispose();
    _currentMaxController.dispose();
    _inductorTypeController.dispose();

    _interfaceController.dispose();
    _sensorVoltageInController.dispose();
    _chipsetController.dispose();

    super.dispose();
  }

  Future<void> _addComponent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        Map<String, dynamic> specs = {};

        if (_selectedCategory == "resistor") {
          specs = {
            "resistance": _resistanceController.text,
            "power": _powerController.text,
            "tolerance": _toleranceController.text,
            "package": _resistorPackageController.text,
          };
        } else if (_selectedCategory == "capacitor") {
          specs = {
            "capacitance": _capacitanceController.text,
            "voltage_max": _voltageMaxController.text,
            "type": _capacitorTypeController.text,
            "package": _capacitorPackageController.text,
          };
        } else if (_selectedCategory == "ic") {
          specs = {
            "pins": int.tryParse(_pinsController.text) ?? 0,
            "package": _icPackageController.text,
            "voltage_range": _voltageRangeController.text,
            "family": _familyController.text,
          };
        } else if (_selectedCategory == "inductor") {
          specs = {
            "inductance": _inductanceController.text,
            "current_max": _currentMaxController.text,
            "type": _inductorTypeController.text,
          };
        } else if (_selectedCategory == "sensor") {
          specs = {
            "interface": _interfaceController.text,
            "voltage_in": _sensorVoltageInController.text,
            "chipset": _chipsetController.text,
          };
        }

        // Xoá các giá trị null
        specs.removeWhere((key, value) => value == null || value.toString().trim().isEmpty);

        final newComponent = Component(
          name: _nameController.text,
          quantity: int.parse(_quantityController.text),
          locationID: _selectedLocation!,
          categoryID: _selectedCategory!,
          minThreshold: int.tryParse(_minQuantityController.text) ?? 10,
          specs: specs.isNotEmpty ? specs : null,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(child: const Text("Thêm linh kiện thành công")),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(milliseconds: 1500),
            ),
          );
          Navigator.pop(context, newComponent);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Có lỗi xảy ra: $e')));
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

  Widget _buildTextField(String label, String hint, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }

  Widget _buildResistorSpecsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Giá trị', '10k, 1M, 220R', _resistanceController),
        _buildTextField('Công suất chịu tải', '1/4W, 1W, 5W', _powerController),
        _buildTextField('Sai số', '1%, 5%', _toleranceController),
        _buildTextField('Kiểu chân', 'Chân cắm, SMD', _resistorPackageController),
      ],
    );
  }

  Widget _buildCapacitorSpecsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Loại tụ', 'Tụ hoá, tụ gốm', _capacitorTypeController),
        _buildTextField('Điện dung', '100nF, 22uF', _capacitanceController),
        _buildTextField('Điện áp tối đa', '50V, 16V', _voltageMaxController),
        _buildTextField('Kiểu chân', 'Chân cắm, SMD', _capacitorPackageController),
      ],
    );
  }

  Widget _buildICSpecsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Dòng IC', 'Timer, Op-Amp, MCU', _familyController),
        _buildTextField('Số chân', 'Nhập số chân', _pinsController, keyboardType: TextInputType.number),
        _buildTextField('Kiểu đóng gói', 'DIP-8, SOIC', _icPackageController),
        _buildTextField('Dải điện áp hoạt động', '4.5V - 15V', _voltageRangeController),
      ],
    );
  }

  Widget _buildInductorSpecsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Giá trị cuộn cảm', '10uH, 1mH', _inductanceController),
        _buildTextField('Dòng bão hòa tối đa', '2A, 500mA', _currentMaxController),
        _buildTextField('Loại cuộn cảm', 'Quấn dây, đa lớp', _inductorTypeController),
      ],
    );
  }

  Widget _buildSensorSpecsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Chip cảm biến', 'MPU6050, DHT11', _chipsetController),
        _buildTextField('Giao thức giao tiếp', 'I2C, SPI, Analog', _interfaceController),
        _buildTextField('Điện áp cấp', '3.3V - 5V', _sensorVoltageInController),
      ],
    );
  }

  Widget _buildDynamicSpecsForm() {
    if (_selectedCategory == "resistor") {
      return _buildResistorSpecsForm();
    } else if (_selectedCategory == "capacitor") {
      return _buildCapacitorSpecsForm();
    } else if (_selectedCategory == "inductor") {
      return _buildInductorSpecsForm();
    } else if (_selectedCategory == "ic") {
      return _buildICSpecsForm();
    } else if (_selectedCategory == "sensor") {
      return _buildSensorSpecsForm();
    }

    return const SizedBox.shrink();
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
            const Text(
              'Tên linh kiện',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(hintText: 'Nhập tên linh kiện'),
              validator: (value) => value == null || value.isEmpty
                  ? 'Vui lòng nhập tên linh kiện'
                  : null,
            ),
            const SizedBox(height: 15),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Số lượng',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(hintText: '0'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Nhập số lượng'
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mức báo hết',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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

            const Text(
              'Danh mục',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
              onChanged: (value) {
                setState(() => _selectedCategory = value);
              },
              validator: (value) =>
                  value == null ? 'Vui lòng chọn danh mục' : null,
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
              validator: (value) =>
                  value == null ? 'Vui lòng chọn vị trí' : null,
            ),
            const SizedBox(height: 15),

            _buildDynamicSpecsForm(),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: _isLoading ? null : _addComponent,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
                  : const Text('Thêm linh kiện'),
            ),
          ],
        ),
      ),
    );
  }
}
