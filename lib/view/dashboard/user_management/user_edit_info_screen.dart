import 'package:electronic_component_storage_app/control/supabase_account_controller.dart';
import 'package:electronic_component_storage_app/model/my_user.dart';
import 'package:electronic_component_storage_app/view/custom_widget.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserEdtiInfoScreen extends StatefulWidget {
  final MyUser user;

  const UserEdtiInfoScreen({super.key, required this.user});

  @override
  State<UserEdtiInfoScreen> createState() => _UserEdtiInfoScreenState();
}

class _UserEdtiInfoScreenState extends State<UserEdtiInfoScreen> {
  late final TextEditingController _nameController;
  late String _selectedRole;

  bool _isDeleting = false;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Cấp phát bộ nhớ cho các controller
    _nameController = TextEditingController(text: widget.user.fullName);
    _selectedRole = widget.user.role;
  }

  @override
  void dispose() {
    // Luôn nhớ free() bộ nhớ để tránh memory leak
    _nameController.dispose();
    super.dispose();
  }

  // Luồng xử lý lưu thông tin
  Future<void> _updateUserData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      final userData = MyUser(
        id: widget.user.id,
        email: widget.user.email,
        fullName: _nameController.text,
        role: _selectedRole,
      );
      await SupabaseAccountController.updateUserDataByOwner(userData);
      await SupabaseAccountController.getAllUserInSystem();

      if (mounted) {
        CustomWidget.showFloatingSnackbar(
          context,
          text: "Lưu thông tin người dùng thành công",
        );
        Navigator.pop(context, true);
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi xác thực: ${e.message}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi hệ thống: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Luồng xử lý xóa người dùng
  Future<void> _deleteUser() async {
    if (widget.user.id == SupabaseAccountController.userCached.id) {
      CustomWidget.showFloatingSnackbar(
        context,
        text: "Bạn không được tự xóa tài khoản của chính mình",
      );
      return;
    }
    // 1. Hiển thị Dialog xác nhận (Hành động phá hủy cần confirm)
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cảnh báo hệ thống'),
        content: Text(
          'Bạn có chắc chắn muốn xóa vĩnh viễn người dùng "${widget.user.fullName}"? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa vĩnh viễn'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await SupabaseAccountController.deleteUser(widget.user.id!);
      await SupabaseAccountController.getAllUserInSystem();
      if (mounted) {
        CustomWidget.showFloatingSnackbar(
          context,
          text: "Xoá người dùng thành công",
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Có lỗi xảy ra $e")));
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: MyAppBar(title: "Thông tin người dùng"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.fullName,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              Chip(
                label: const Text(
                  'TÀI KHOẢN HIỆU LỰC',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.green.shade100,
                labelStyle: TextStyle(color: Colors.green.shade900),
                side: BorderSide.none,
                avatar: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 16,
                ),
              ),
              const SizedBox(height: 32),

              // Khối Metadata Read-Only (System ID, Email, Date)[cite: 2]
              _ReadOnlyMetadataCard(user: widget.user),
              const SizedBox(height: 24),

              // Editable Form Section[cite: 2]
              Text(
                'Chỉnh sửa thông tin tài khoản',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              // _CustomFilledTextField(
              //   label: 'FULL IDENTITY NAME',
              //   controller: _nameController,
              //   icon: Icons.edit,
              // ),
              const Text(
                "Tên người dùng",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(hintText: "Nhập tên người dùng"),
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Tên người dùng là bắt buộc";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const Text(
                "Vai trò",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                initialValue: widget.user.role,
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

              const SizedBox(height: 48),

              // Action Buttons (Xóa bên trái, Hủy & Lưu bên phải)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_isDeleting)
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      ),
                      onPressed: () {},
                      child: const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      ),
                      onPressed: _isLoading ? null : _deleteUser,
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Xoá người dùng'),
                    ),

                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Huỷ'),
                      ),
                      const SizedBox(width: 8),
                      if (_isLoading)
                        FilledButton(
                          onPressed: () {},
                          child: const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                        )
                      else
                        FilledButton(
                          onPressed: _isDeleting ? null : _updateUserData,
                          child: const Text('Lưu'),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32), // Padding đáy cho mobile
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper Widget 1: Tách khối Read-only[cite: 2]
class _ReadOnlyMetadataCard extends StatelessWidget {
  final MyUser user;

  const _ReadOnlyMetadataCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THÔNG TIN TÀI KHOẢN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: AppColor.onsurfaceContainerLow,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoColumn(
            'ID người dùng',
            user.id!,
            isMono: true,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          _buildInfoColumn('Email', user.email),
          const SizedBox(height: 12),
          _buildInfoColumn(
            'Ngày tạo tài khoản',
            DateFormat('dd/MM/yyyy').format(user.createdAt!),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(
    String label,
    String value, {
    bool isMono = false,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColor.onsurfaceContainerLow,
          ),
        ),
        SelectableText(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: isMono ? 'monospace' : null,
            color: color,
          ),
        ),
      ],
    );
  }
}
