import 'dart:io';

import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/control/supabase_storage_controller.dart';
import 'package:electronic_component_storage_app/model/component.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/my_app_bar.dart';
import 'package:electronic_component_storage_app/view/custom_widget.dart';
import 'package:electronic_component_storage_app/view/storage/add_component/resistor_scanner_screen.dart';
import 'package:electronic_component_storage_app/view/storage/export_screen/select_component_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:validators/validators.dart';

class AddComponentForm extends StatefulWidget {
  const AddComponentForm({
    super.key,
    this.component,
    this.isFromStogareScreen = false,
  });

  final Component? component;
  final bool isFromStogareScreen;

  @override
  State<AddComponentForm> createState() => _AddComponentFormState();
}

class _AddComponentFormState extends State<AddComponentForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: "10");
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

  final _datasheetLinkKey = GlobalKey<FormFieldState>();
  final _datasheetLinkController = TextEditingController();

  String? _selectedCategory;
  String? _selectedLocation;
  bool _isLoading = false;
  bool _isDeleting = false;

  late String _title = "Thêm linh kiện mới";
  //late String _buttonText = "Thêm linh kiện";
  late String _snackBarText = "Thêm linh kiện thành công";

  File? _imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.isFromStogareScreen && widget.component == null) {
      throw Exception(
        '(component == null && isFromStogareScreen == true) is not false',
      );
    }
    if (widget.component != null) {
      _autoFillForm(widget.component!);
      _title = "Sửa linh kiện";
      //_buttonText = "Lưu lại";
      _snackBarText = "Sửa linh kiện thành công";
    }
  }

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

    _datasheetLinkController.dispose();

    super.dispose();
  }

  void _autoFillForm(Component component) {
    _nameController.text = component.name;
    _quantityController.text = component.quantity.toString();
    _minQuantityController.text = component.minThreshold.toString();

    _selectedCategory = component.categoryID;
    _selectedLocation = component.locationID;

    if (component.specs != null) {
      final Map<dynamic, dynamic> specs = component.specs!;
      if (_selectedCategory == "resistor") {
        _resistanceController.text = specs['resistance']?.toString() ?? '';
        _powerController.text = specs['power']?.toString() ?? '';
        _toleranceController.text = specs['tolerance']?.toString() ?? '';
        _resistorPackageController.text = specs['package']?.toString() ?? '';
      } else if (_selectedCategory == "capacitor") {
        _capacitanceController.text = specs['capacitance']?.toString() ?? '';
        _voltageMaxController.text = specs['voltage_max']?.toString() ?? '';
        _capacitorTypeController.text = specs['type']?.toString() ?? '';
        _capacitorPackageController.text = specs['package']?.toString() ?? '';
      } else if (_selectedCategory == "ic") {
        _pinsController.text = specs['pins']?.toString() ?? '';
        _icPackageController.text = specs['package']?.toString() ?? '';
        _voltageRangeController.text = specs['voltage_range']?.toString() ?? '';
        _familyController.text = specs['family']?.toString() ?? '';
      } else if (_selectedCategory == "inductor") {
        _inductanceController.text = specs['inductance']?.toString() ?? '';
        _currentMaxController.text = specs['current_max']?.toString() ?? '';
        _inductorTypeController.text = specs['type']?.toString() ?? '';
      } else if (_selectedCategory == "sensor") {
        _interfaceController.text = specs['interface']?.toString() ?? '';
        _sensorVoltageInController.text = specs['voltage_in']?.toString() ?? '';
        _chipsetController.text = specs['chipset']?.toString() ?? '';
      }
    }

    if (component.datasheetUrl != null && component.datasheetUrl!.isNotEmpty) {
      _datasheetLinkController.text = component.datasheetUrl!;
    }
  }

  Future<void> _deleteComponent() async {
    if (widget.component!.quantity > 0) {
      CustomWidget.showFloatingSnackbar(
        context,
        text: "Bạn không được xoá linh kiện còn hàng",
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xoá linh kiện'),
        content: Text(
          'Bạn có chắc chắn muốn xóa linh kiện "${widget.component!.name}"? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColor.errorColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await SupabaseDatabaseController.softDeleteComponent(widget.component!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Có lỗi xảy ra $e")));
        return;
      }
    }

    if (mounted) {
      CustomWidget.showFloatingSnackbar(
        context,
        text: "Xoá linh kiện thành công",
      );
      setState(() {
        _isDeleting = false;
      });
      Navigator.of(context).pop();
    }
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
        specs.removeWhere(
          (key, value) => value == null || value.toString().trim().isEmpty,
        );

        final newComponent = Component(
          name: _nameController.text,
          quantity: int.parse(_quantityController.text),
          locationID: _selectedLocation!,
          categoryID: _selectedCategory!,
          minThreshold: int.tryParse(_minQuantityController.text) ?? 10,
          specs: specs.isNotEmpty ? specs : null,
          imageUrl: await _uploadImage(),
          datasheetUrl: _datasheetLinkController.text.isNotEmpty
              ? _datasheetLinkController.text
              : null,
        );

        if (widget.isFromStogareScreen) {
          newComponent.id = widget.component!.id;
          await SupabaseDatabaseController.updateComponent(newComponent);
          await SupabaseDatabaseController.getAllComponent();
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          if (mounted) {
            CustomWidget.showFloatingSnackbar(context, text: _snackBarText);
            Navigator.pop(context, newComponent);
          }
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

  Future<void> _selectComponentImage() async {
    final File? originalFile = await CustomWidget.showChooseImageDialog(
      context,
    );

    if (originalFile == null) {
      return;
    }

    // Tạo đường dẫn file tạm (temp) để lưu ảnh nén
    final Directory tempDir = await getTemporaryDirectory();
    final String targetPath =
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final XFile? compressedXFile =
        await FlutterImageCompress.compressAndGetFile(
          originalFile.absolute.path,
          targetPath,
          quality: 70, // Giảm chất lượng xuống 70% (mắt thường khó phân biệt)
          minWidth: 1024, // Resize chiều ngang tối đa 1024px
          minHeight: 1024, // Resize chiều dọc tối đa 1024px
          format: CompressFormat.jpeg, // Ép chuẩn định dạng ảnh nhẹ nhất
        );

    if (compressedXFile == null) {
      throw Exception('Lỗi hệ thống: Không thể nén ảnh.');
    }

    setState(() {
      _imageFile = File(compressedXFile.path);
    });
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) {
      if (widget.component != null &&
          widget.component!.imageUrl != null &&
          widget.component!.imageUrl!.isNotEmpty) {
        return widget.component!.imageUrl!;
      }
      return null;
    }
    final result = await SupabaseStorageController.uploadFile(
      bucket: 'component_image',
      file: _imageFile!,
    );

    if (_imageFile!.existsSync()) {
      _imageFile!.deleteSync();
    }

    return result;
  }

  Future<void> _openDataSheetLink() async {
    String urlString = _datasheetLinkController.text.trim();
    if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
      urlString = 'https://$urlString';
    }
    _datasheetLinkController.text = urlString;

    if (!_datasheetLinkKey.currentState!.validate()) {
      return;
    }

    final Uri url = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          CustomWidget.showFloatingSnackbar(context, text: "Không thể mở URL");
        }
      }
    } catch (e) {
      if (mounted) {
        CustomWidget.showFloatingSnackbar(context, text: "Có lỗi xảy ra $e");
      }
    }
  }

  Future<void> _onScanResistorBtnTap() async {
    final imageFile = await CustomWidget.showChooseImageDialog(context);
    if (imageFile == null || !mounted) {
      return;
    }
    final Map<String, dynamic>? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResistorScannerScreen(imageFile: imageFile),
      ),
    );

    if (result != null) {
      _resistanceController.text = result['resistor_value'] ?? "";
      _toleranceController.text = result['resistor_tolerance'] ?? "";
    }
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    GlobalKey<FormFieldState>? key,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String? value)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextFormField(
            key: key,
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(hintText: hint, suffixIcon: suffixIcon),
            onTapOutside: (event) => FocusScope.of(context).unfocus(),
            validator: validator,
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

        // Nút quét giá trị điện trở bằng Camera AI, có badge "Mới"
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Badge(
            label: const Text('Mới'),
            padding: const EdgeInsets.symmetric(horizontal: 5),

            backgroundColor: AppColor.tertiaryContainer,
            offset: const Offset(-5, -5),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _onScanResistorBtnTap,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Quét giá trị điện trở vạch'),
                style: FilledButton.styleFrom(
                  foregroundColor: Colors.white,
                  //side: const BorderSide(color: AppColor.primaryColor, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ),

        _buildTextField('Công suất chịu tải', '1/4W, 1W, 5W', _powerController),
        _buildTextField('Sai số', '1%, 5%', _toleranceController),
        _buildTextField(
          'Kiểu chân',
          'Chân cắm, SMD',
          _resistorPackageController,
        ),
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
        _buildTextField(
          'Kiểu chân',
          'Chân cắm, SMD',
          _capacitorPackageController,
        ),
      ],
    );
  }

  Widget _buildICSpecsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Dòng IC', 'Timer, Op-Amp, MCU', _familyController),
        _buildTextField(
          'Số chân',
          'Nhập số chân',
          _pinsController,
          keyboardType: TextInputType.number,
        ),
        _buildTextField('Kiểu đóng gói', 'DIP-8, SOIC', _icPackageController),
        _buildTextField(
          'Dải điện áp hoạt động',
          '4.5V - 15V',
          _voltageRangeController,
        ),
      ],
    );
  }

  Widget _buildInductorSpecsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Giá trị cuộn cảm', '10uH, 1mH', _inductanceController),
        _buildTextField(
          'Dòng bão hòa tối đa',
          '2A, 500mA',
          _currentMaxController,
        ),
        _buildTextField(
          'Loại cuộn cảm',
          'Quấn dây, đa lớp',
          _inductorTypeController,
        ),
      ],
    );
  }

  Widget _buildSensorSpecsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Chip cảm biến', 'MPU6050, DHT11', _chipsetController),
        _buildTextField(
          'Giao thức giao tiếp',
          'I2C, SPI, Analog',
          _interfaceController,
        ),
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

  Widget _buildDatasheetLinkField() {
    return _buildTextField(
      "Link datasheet",
      "Nhập link datasheet",
      _datasheetLinkController,
      key: _datasheetLinkKey,
      keyboardType: TextInputType.url,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null;
        }
        if (!isURL(value)) {
          return "URL không hợp lệ";
        }
        return null;
      },
      suffixIcon: IconButton(
        onPressed: _openDataSheetLink,
        icon: Icon(Icons.open_in_new),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = SupabaseDatabaseController.categoryMapCached;
    final locations = SupabaseDatabaseController.locationMapCached;

    final showSelectExistComponent = widget.component == null;

    Widget inkWellChild = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon Camera Circle
        Container(
          margin: const EdgeInsets.only(top: 10),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColor.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.add_photo_alternate_rounded,
            color: AppColor.onSurfaceVariant,
            size: 24,
          ),
        ),
        const SizedBox(height: 12),

        // Main Text
        const Text(
          'Chọn ảnh',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColor.primaryColor,
          ),
        ),
      ],
    );
    if (_imageFile != null) {
      inkWellChild = InstaImageViewer(
        child: ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(10),
          child: Image.file(
            _imageFile!,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
      );
    } else if (widget.component != null &&
        widget.component!.imageUrl != null &&
        widget.component!.imageUrl!.isNotEmpty) {
      inkWellChild = InstaImageViewer(
        child: ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(10),
          child: Image.network(
            widget.component!.imageUrl!,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: MyAppBar(title: _title),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            const Text(
              "Ảnh linh kiện",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.outlineVariant, width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: (inkWellChild.runtimeType == InstaImageViewer)
                    ? null
                    : _selectComponentImage,
                onLongPress: _selectComponentImage,
                child: inkWellChild,
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tên linh kiện',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                showSelectExistComponent
                    ? TextButton(
                        onPressed: () async {
                          final Component? result = await Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SelectComponentScreen(
                                        showOutOfStockComponent: true,
                                      ),
                                ),
                              );

                          if (result != null) {
                            final newComponent = Component.from(result);
                            newComponent.quantity = 1;
                            if (context.mounted) {
                              Navigator.of(context).pop(newComponent);
                            }
                          }
                        },
                        child: const Text("CHỌN LINH KIỆN CÓ SẴN"),
                      )
                    : const SizedBox(height: 30),
              ],
            ),
            //const SizedBox(height: 5),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(hintText: 'Nhập tên linh kiện'),
              validator: (value) => value == null || value.isEmpty
                  ? 'Vui lòng nhập tên linh kiện'
                  : null,
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
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
                        readOnly: widget.isFromStogareScreen,
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(hintText: '0'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Nhập số lượng'
                            : null,
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
                        onTap: () {
                          if (widget.isFromStogareScreen) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Bạn chỉ có thể thay đổi số lượng bằng tính năng Nhập/Xuất linh kiện",
                                ),
                              ),
                            );
                          }
                        },
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(hintText: '10'),
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
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

            _buildDatasheetLinkField(),

            const SizedBox(height: 15),

            widget.component == null
                ? FilledButton(
                    onPressed: _isLoading ? () {} : _addComponent,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text("Thêm linh kiện"),
                  )
                :
                  // Action Buttons (Xóa bên trái, Hủy & Lưu bên phải)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_isDeleting)
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColor.errorColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {},
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
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColor.errorColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _isLoading ? null : _deleteComponent,
                          icon: const Icon(Icons.delete_forever),
                          label: const Text('Xoá linh kiện'),
                        ),

                      Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Huỷ'),
                          ),
                          const SizedBox(width: 8),
                          if (_isLoading)
                            FilledButton(
                              onPressed: () {},
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
                            FilledButton(
                              onPressed: _isDeleting ? null : _addComponent,
                              child: const Text('Lưu'),
                            ),
                        ],
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
