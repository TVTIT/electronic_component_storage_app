import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showLoader = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.surfaceColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutCubic,
              onEnd: () {
                setState(() {
                  _showLoader = true;
                });
              },
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (1.2 * value),
                  child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                );
              },
              child: Image.asset(
                'assets/logo2_transparent.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 80),

            AnimatedOpacity(
              opacity: _showLoader ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
