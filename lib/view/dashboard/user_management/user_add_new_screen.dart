import 'package:electronic_component_storage_app/control/supabase_account_controller.dart';
import 'package:electronic_component_storage_app/model/my_user.dart';
import 'package:electronic_component_storage_app/view/custom_widget.dart';
import 'package:electronic_component_storage_app/view/my_app_bar.dart';
import 'package:flutter/material.dart';

class UserAddNewScreen extends StatefulWidget {
  const UserAddNewScreen({super.key});

  @override
  State<UserAddNewScreen> createState() => _UserAddNewScreenState();
}

class _UserAddNewScreenState extends State<UserAddNewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  //Role mặc định thấp nhất
  String _selectedRole = SupabaseAccountController.rolesMapCached.keys.first;

  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _addUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final newUser = MyUser(
      email: _emailController.text,
      password: _passwordController.text,
      fullName: _nameController.text,
      role: _selectedRole,
    );
    setState(() {
      _isLoading = true;
    });
    try {
      await SupabaseAccountController.createNewUserByOwner(newUser);
      await SupabaseAccountController.getAllUserInSystem();
      if (mounted) {
        CustomWidget.showFloatingSnackbar(context, text: "Tạo tài khoản thành công");
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Có lỗi xảy ra $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Thêm người dùng mới",
        icon: Icon(Icons.person_add),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            const Text(
              "Tên người dùng",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(hintText: "Nhập tên người dùng"),
              textInputAction: TextInputAction.next,
              onTapOutside: (event) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Tên người dùng là bắt buộc";
                }
                return null;
              },
            ),

            const SizedBox(height: 10),

            const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: "Nhập email",
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
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

            const SizedBox(height: 10),

            const Text(
              "Mật khẩu",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              obscureText: _obscurePassword,
              controller: _passwordController,
              onTapOutside: (event) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              decoration: InputDecoration(
                hintText: "Nhập mật khẩu",
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Mật khẩu là bắt buộc";
                }
                if (value.length < 6) {
                  return "Mật khẩu phải dài hơn 6 ký tự";
                }
                return null;
              },
            ),

            const SizedBox(height: 10),

            const Text(
              "Vai trò",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              decoration: const InputDecoration(hintText: 'Chọn vai trò'),
              items: SupabaseAccountController.rolesMapCached.entries
                  .map(
                    (entry) => DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value['name']),
                    ),
                  )
                  .toList(),
              onChanged: (value) => _selectedRole = value ?? 'manager',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Vai trò không được bỏ trống";
                }
                return null;
              },
            ),

            const SizedBox(height: 30),

            if (_isLoading)
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const SizedBox(
                  //Dùng SizedBox để lock lại kích thước cho giống nút khi không load
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              )
            else
              FilledButton.icon(
                onPressed: _addUser,
                label: const Text(
                  "Tạo tài khoản",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                icon: const Icon(Icons.person_add_outlined),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
