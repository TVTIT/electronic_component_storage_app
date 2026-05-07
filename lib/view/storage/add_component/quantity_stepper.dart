import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuantityStepper extends StatefulWidget {
  const QuantityStepper({
    super.key,
    required this.initialValue,
    this.minValue = 1,
    this.maxValue = 99999,
    required this.onChanged,
  });
  final int minValue;
  final int maxValue;
  final int initialValue;
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
    _controller = TextEditingController(text: widget.initialValue.toString());
    _currentValue = widget.initialValue;
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
            onPressed: () {
              setState(() {
                _currentValue--;
                if (_currentValue < widget.minValue) {
                  _currentValue = widget.minValue;
                }
                _controller.text = _currentValue.toString();
                widget.onChanged(_currentValue);
              });
            },
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
            onPressed: () {
              setState(() {
                _currentValue++;
                if (_currentValue > widget.maxValue) {
                  _currentValue = widget.maxValue;
                }
                _controller.text = _currentValue.toString();
                widget.onChanged(_currentValue);
              });
            },
            icon: Icon(Icons.add),
            color: AppColor.primaryColor,
          ),
        ],
      ),
    );
  }
}
