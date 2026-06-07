import 'package:electronic_component_storage_app/control/supabase_account_controller.dart';
import 'package:electronic_component_storage_app/view/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangeUserPasswordScreen extends StatefulWidget {
  const ChangeUserPasswordScreen({super.key});

  @override
  State<ChangeUserPasswordScreen> createState() =>
      _ChangeUserPasswordScreenState();
}

class _ChangeUserPasswordScreenState extends State<ChangeUserPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final _confirmPasswordController = TextEditingController();
  bool _obscureConfirmPassword = true;

  bool _isLoading = false;

  Future<void> _changeUserPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await SupabaseAccountController.updateUserPassword(
          _passwordController.text,
        );
        if (mounted) {
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text("Đổi mật khẩu thành công"),
              content: const Text(
                "Bạn đã đổi mật khẩu thành công",
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      } on AuthException catch (e) {
        if (mounted) {
          CustomWidget.showFloatingSnackbar(
            context,
            text:
                SupabaseAccountController.loginErrorCodeMap[e.code] ??
                e.message,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi hệ thống. Vui lòng thử lại")),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Đổi mật khẩu")),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Mật khẩu mới',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onTapOutside: (event) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: "Nhập mật khẩu mới",
                  prefixIcon: Icon(Icons.lock),

                  suffixIcon: ExcludeFocus(
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: _obscurePassword
                          ? Icon(Icons.visibility_off)
                          : Icon(Icons.visibility),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Mật khẩu mới không được bỏ trống";
                  }

                  if (value.length < 6) {
                    return "Mật khẩu phải chứa ít nhất 6 ký tự";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              const Text(
                'Nhập lại mật khẩu mới',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                onTapOutside: (event) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                onFieldSubmitted: (value) async => await _changeUserPassword(),
                decoration: InputDecoration(
                  hintText: "Nhập lại mật khẩu mới",
                  prefixIcon: Icon(Icons.lock),

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    icon: _obscureConfirmPassword
                        ? Icon(Icons.visibility_off)
                        : Icon(Icons.visibility),
                  ),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return "Mật khẩu mới không khớp";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              FilledButton(
                style: FilledButton.styleFrom(minimumSize: Size.fromHeight(50)),
                onPressed: _isLoading
                    ? () {}
                    : () async => _changeUserPassword(),
                child: _isLoading
                    ? const SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text("Đổi mật khẩu"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
