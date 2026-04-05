import 'package:electronic_component_storage_app/view/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;

  Future<void> _resetPassword(String email) async {
    setState(() {
      _isLoading = true;
    });
    await Supabase.instance.client.auth.resetPasswordForEmail(email.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Chúng tôi đã gửi một liên kết để đặt lại mật khẩu. Hãy kiểm tra email của bạn",
          ),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Quên mật khẩu"),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                onTapOutside: (event) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
                decoration: InputDecoration(
                  labelText: "Email",
                  hintText: "Nhập email",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderSide: BorderSide()
                  )
                ),
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

              SizedBox(height: 20,),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _resetPassword(_emailController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Đặt lại mật khẩu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
