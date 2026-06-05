import 'dart:io';
import 'package:electronic_component_storage_app/control/api_controller.dart';
import 'package:flutter/material.dart';

class ResistorScannerScreen extends StatefulWidget {
  final File imageFile;

  const ResistorScannerScreen({super.key, required this.imageFile});

  @override
  State<ResistorScannerScreen> createState() => _ResistorScannerScreenState();
}

// Thêm SingleTickerProviderStateMixin để dùng Animation
class _ResistorScannerScreenState extends State<ResistorScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this);

    _processImageAndCallApi();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Hàm mô phỏng gọi API
  Future<void> _processImageAndCallApi() async {
    try {
      final Map<String, dynamic> apiResponse =
          await ApiController.callResistorColorBandApi(widget.imageFile);

      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        _animationController.stop();
        _showResultPopup(apiResponse);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        _animationController.stop();
        _showResultPopup({
          "error_code": -1,
          "message": "Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.",
        });
      }
    }
  }

  void _popWithResult(BuildContext dialogContext, Map<dynamic, dynamic> result) {
    Navigator.of(dialogContext).pop();
    Navigator.of(context).popUntilWithResult(
      (route) => route.settings.name == "add_component_form",
      result,
    );
  }

  void _popWithoutResult(BuildContext dialogContext) {
    Navigator.of(dialogContext).pop();
    Navigator.of(
      context,
    ).popUntil((route) => route.settings.name == "add_component_form");
  }

  void _showResultPopup(Map<String, dynamic> response) {
    final int errorCode = response['error_code'] as int;
    final String message = response['message'] as String;
    final Map<String, dynamic>? data = response['data'] as Map<String, dynamic>?;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Nhận diện thành công
        if (errorCode == 0 && data != null && data['value'] != null) {
          final String resistorValue = data['value'] as String;
          final String? resistorTolerance = data['tolerance'] as String?;

          String displayValue = resistorValue;

          if (resistorTolerance != null) {
            displayValue += "±$resistorTolerance";
          }
          displayValue += " Ω";
          
          final Map<String, dynamic> result = {
            'resistor_value': resistorValue,
            'resistor_tolerance': resistorTolerance,
          };

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Nhận diện thành công',
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 16),
                Text(
                  displayValue,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bạn có muốn nhập giá trị này vào không?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 12),
                Text(
                  'Kết quả từ AI có thể mắc sai sót. '
                  'Hãy kiểm tra lại trước khi quyết định.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => _popWithoutResult(dialogContext),
                child: const Text('Huỷ'),
              ),
              FilledButton(
                onPressed: () => _popWithResult(dialogContext, result),
                child: const Text('OK'),
              ),
            ],
          );
        }

        // Lỗi không nhận diện được
        if (errorCode == 1) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Không thể nhận diện',
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning, color: Colors.amber, size: 60),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 12),
                Text(
                  'Mẹo: Hãy đảm bảo hình ảnh đủ sáng, các vạch màu của '
                  'điện trở hiện rõ trong ảnh và đặt điện trở nằm ngang '
                  'để cho kết quả chính xác nhất.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              Center(
                child: FilledButton(
                  onPressed: () => _popWithoutResult(dialogContext),
                  child: const Text('OK'),
                ),
              ),
            ],
          );
        }

        // Lỗi API hoặc các trường hợp khác
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Lỗi hệ thống', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cancel, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
          actions: [
            Center(
              child: FilledButton(
                onPressed: () => _popWithoutResult(dialogContext),
                child: const Text('OK'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Để nền đen cho đẹp
      appBar: AppBar(
        title: const Text('Đang phân tích điện trở...'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Image.file(
                  widget.imageFile,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),

                // Nếu đang quét thì hiện laser đỏ
                if (_isScanning)
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // 1. Tốc độ mong muốn
                        const double speedPerSecond = 300;

                        // 2. Tính toán Duration: (Chiều cao / Tốc độ) * 1000 mili-giây
                        if (constraints.maxHeight != 0) {
                          final int calculatedDurationMs =
                              ((constraints.maxHeight / speedPerSecond) * 1000)
                                  .toInt();

                          // 3. Nếu duration thay đổi (hoặc mới chạy lần đầu), ta cập nhật lại cho Controller
                          if (_animationController.duration?.inMilliseconds !=
                              calculatedDurationMs) {
                            // addPostFrameCallback giúp an toàn cập nhật Animation
                            // MÀ KHÔNG làm crash quá trình render UI của Flutter
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                _animationController.duration = Duration(
                                  milliseconds: calculatedDurationMs,
                                );
                                // Bắt đầu chạy hiệu ứng
                                if (_isScanning &&
                                    !_animationController.isAnimating) {
                                  _animationController.repeat(reverse: true);
                                }
                              }
                            });
                          }
                        }

                        // Chiều cao vạch sáng đỏ là 3px
                        const laserHeight = 3.0;

                        // Tọa độ cực đại: Đáy bức ảnh trừ đi độ dày của vạch sáng
                        final maxTop = constraints.maxHeight - laserHeight;

                        return Stack(
                          // Cắt bỏ phần đuôi 40px nếu nó trôi ra khỏi đáy ảnh
                          clipBehavior: Clip.hardEdge,
                          children: [
                            AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Positioned(
                                  // Chạy CHÍNH XÁC từ mép trên (0) xuống mép dưới (maxTop)
                                  top: _animationController.value * maxTop,
                                  left: 0,
                                  right: 0,
                                  child: child!,
                                );
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Vạch tia laser chính (3px)
                                  Container(
                                    height: laserHeight,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withValues(
                                            alpha: 0.8,
                                          ),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Quầng sáng mờ đuổi theo (40px)
                                  Container(
                                    height: 40,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.red.withValues(alpha: 0.3),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
