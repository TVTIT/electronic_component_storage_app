import 'dart:async';
import 'dart:io';

import 'package:electronic_component_storage_app/control/supabase_account_controller.dart';
import 'package:electronic_component_storage_app/view/home_screen.dart';
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

  late final StreamSubscription<AuthState> _authSubscription;

  String _loginErrorText = "";

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Gọi API đăng nhập thuần của Supabase
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

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
            const SnackBar(content: Text('Lỗi hệ thống. Vui lòng thử lại')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _setupAuthListener() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      if (data.session != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        });
      }
    });
  }

  @override
  void initState() {
    _setupAuthListener();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _authSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Đăng nhập")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(15.0),
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
              onPressed: _isLoading
                  ? () {}
                  : () async {
                      await _signIn();
                    },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: _isLoading
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
