import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuantityStepper extends StatefulWidget {
  const QuantityStepper({
    super.key,
    this.minValue = 1,
    this.maxValue = 99999,
    required this.onChanged,
  });
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;

  @override
  State<QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends State<QuantityStepper> {
  late TextEditingController _controller;
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.minValue;
    _controller = TextEditingController(text: _currentValue.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColor.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColor.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.remove),
            color: AppColor.primaryColor,
          ),
          Container(
            width: 50,
            height: double.infinity,
            alignment: Alignment.center,
            color: Colors.white,
            child: TextFormField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                fillColor: Colors.white,
              ),
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.add),
            color: AppColor.primaryColor,
          ),
        ],
      ),
    );
  }
}
