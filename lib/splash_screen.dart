import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:flutter/material.dart';
// Note: Import file chứa màn hình tiếp theo (Login/Home) của em vào đây

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      backgroundColor: AppColor.surfaceColor, 
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 2.0),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic, // Curve tạo cảm giác mượt, chậm dần ở cuối
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.6 * value), // Scale từ 0.8 lên 2.0
              child: Opacity(
                opacity: value / 2, // Fade từ 0 lên 1
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo2_transparent.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}