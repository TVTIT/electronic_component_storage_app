import 'package:electronic_component_storage_app/model/transaction_header.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionFilterWidget extends StatefulWidget {
  const TransactionFilterWidget({
    super.key,
    required this.onSelectedTypeChange,
    required this.onSelectedDateRangeChange,
  });

  final Function(TransactionType? value) onSelectedTypeChange;
  final Function(DateTimeRange? value) onSelectedDateRangeChange;

  @override
  State<TransactionFilterWidget> createState() =>
      _TransactionFilterWidgetState();
}

class _TransactionFilterWidgetState extends State<TransactionFilterWidget> {
  TransactionType? _selectedType; // null nghĩa là "Tất cả"
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          //Dropdown menu chọn loại
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Material(
              color: Colors.transparent,
              child: PopupMenuButton<TransactionType?>(
                initialValue: _selectedType,
                position: PopupMenuPosition.under,
                onSelected: (TransactionType? value) {
                  setState(() => _selectedType = value);
                  widget.onSelectedTypeChange(_selectedType);
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<TransactionType?>>[
                      PopupMenuItem<TransactionType?>(
                        value: TransactionType.import,
                        child: Text(TransactionType.import.displayName),
                      ),
                      PopupMenuItem<TransactionType?>(
                        value: TransactionType.export,
                        child: Text(TransactionType.export.displayName),
                      ),
                    ],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedType == null
                        ? AppColor.surfaceContainerLow
                        : AppColor.primaryContainer,
                    borderRadius: BorderRadius.circular(12), // Nút bo tròn
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _dropdownText,
                        style: TextStyle(
                          color: _selectedType == null
                              ? AppColor.onsurfaceContainerLow
                              : Colors.white,
                          fontWeight: _selectedType == null
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),

                      if (_selectedType == null) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                          color: Colors.grey.shade700,
                        ),
                      ] else ...[
                        const SizedBox(width: 6),
                        _removeFilterBtn(() {
                          setState(() {
                            _selectedType = null;
                          });
                          widget.onSelectedTypeChange(_selectedType);
                        }),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          //Nút chọn ngày
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              final DateTimeRange? picked = await showDateRangePicker(
                context: context,
                locale: const Locale('vi', 'VN'),
                initialDateRange: _selectedDateRange,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(colorScheme: Theme.of(context).colorScheme),
                    child: child!,
                  );
                },
              );

              if (picked != null) {
                setState(() => _selectedDateRange = picked);
                widget.onSelectedDateRangeChange(_selectedDateRange);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedDateRange == null
                    ? AppColor.surfaceContainerLow
                    : AppColor.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: _selectedDateRange == null
                        ? AppColor.onsurfaceContainerLow
                        : Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _selectedDateRange == null
                        ? 'Thời gian'
                        : '${_formatDateShort(_selectedDateRange!.start)} - ${_formatDateShort(_selectedDateRange!.end)}',
                    style: TextStyle(
                      color: _selectedDateRange == null
                          ? AppColor.onsurfaceContainerLow
                          : Colors.white,
                      fontWeight: _selectedDateRange == null
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),

                  // Nếu chưa chọn ngày thì hiện mũi tên, nếu đã chọn ngày thì hiện dấu X để xóa nhanh
                  if (_selectedDateRange == null) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: Colors.grey.shade700,
                    ),
                  ] else ...[
                    const SizedBox(width: 6),
                    _removeFilterBtn(() {
                      setState(() {
                        _selectedDateRange = null;
                      });
                      widget.onSelectedDateRangeChange(_selectedDateRange);
                    }),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _removeFilterBtn(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, size: 14, color: Colors.red),
      ),
    );
  }

  String get _dropdownText {
    if (_selectedType == null) {
      return 'Tất cả giao dịch';
    } else {
      return _selectedType!.displayName;
    }
  }

  String _formatDateShort(DateTime datetime) {
    return DateFormat('dd/MM/yyyy').format(datetime);
  }
}
