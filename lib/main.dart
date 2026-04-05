import 'dart:io';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/auth/forgot_password_screen.dart';
import 'package:electronic_component_storage_app/view/home_screen.dart';
import 'package:electronic_component_storage_app/view/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return MaterialApp(
      title: "Quản lý linh kiện điện tử",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0x00006064)),
        scaffoldBackgroundColor: AppColor.surfaceColor,
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: AppColor.onSurfaceColor,
          fontSizeDelta: 1.0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColor.greyInputColor,
          border: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none
          ),
        )
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: session == null ? '/login' : '/home',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen()
      },
    );
  }
}
