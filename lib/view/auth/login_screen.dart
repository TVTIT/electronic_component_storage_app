import 'dart:async';
import 'dart:io';

import 'package:electronic_component_storage_app/control/supabase_account_controller.dart';
import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/view/home_screen.dart';
import 'package:electronic_component_storage_app/view/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _loginErrorText = "";

  bool _isLoggingIn = false;
  bool _isLoadingData = true;
  bool _obscurePassword = true;

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoggingIn = true);
      try {
        // Gọi API đăng nhập thuần của Supabase
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await _getDataAndNavigateHome();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(child: Text("Đăng nhập thành công")),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(milliseconds: 1500),
            ),
          );
        }
      } on AuthException catch (e) {
        if (mounted) {
          setState(() {
            _loginErrorText =
                SupabaseAccountController.loginErrorCodeMap[e.code] ??
                e.message;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi hệ thống: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoggingIn = false);
        }
      }
    }
  }

  Future<void> _checkLoggedIn() async {
    setState(() {
      _isLoadingData = true;
    });
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && !session.isExpired) {
      try {
        await Supabase.instance.client.auth.getUser();
        await _getDataAndNavigateHome();
      } on AuthException catch (e) {
        await Supabase.instance.client.auth.signOut();
        if (mounted) {
          setState(() {
            _isLoadingData = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: Text(
                  "Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại",
                ),
              ),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingData = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Lỗi hệ thống. Vui lòng thử lại"),
            ),
          );
        }
      }
    } else {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  Future<void> _getDataAndNavigateHome() async {
    await SupabaseAccountController.userRole();
    await SupabaseDatabaseController.getInitialData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  void initState() {
    _checkLoggedIn();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: MyAppBar(title: "Đăng nhập"),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(15.0),
          children: [
            Image.asset('assets/logo2_transparent.png', height: 200),
            SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                hintText: "Nhập email",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(borderSide: BorderSide()),
              ),
              onTapOutside: (event) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Email không được bỏ trống";
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Email không hợp lệ';
                }
                return null;
              },
            ),

            const SizedBox(height: 15),

            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "Mật khẩu",
                hintText: "Nhập mật khẩu",
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  onPressed: () => setState(() {
                    _obscurePassword = !_obscurePassword;
                  }),
                  icon: _obscurePassword
                      ? Icon(Icons.visibility_off)
                      : Icon(Icons.visibility),
                ),
                border: OutlineInputBorder(borderSide: BorderSide()),
              ),
              onTapOutside: (event) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              onFieldSubmitted: (value) async => await _signIn(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Mật khẩu không được bỏ trống';
                }
                return null;
              },
            ),

            //const SizedBox(height: 5,),
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/forgot-password');
                },
                child: Text('Quên mật khẩu?'),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isLoggingIn
                  ? () {}
                  : () async {
                      await _signIn();
                    },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: _isLoggingIn
                  ? const CircularProgressIndicator()
                  : const Text('Đăng nhập'),
            ),

            const SizedBox(height: 50),

            Center(
              child: Text(_loginErrorText, style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
