import 'package:electronic_component_storage_app/control/supabase_account_controller.dart';

class MyUser {
  MyUser({
    this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.createdAt,
    this.lastSignInAt,
  }) : roleName =
           SupabaseAccountController.rolesMapCached[role]['name'] ??
           "Nhân viên quản lý";

  final String? id;
  final String email;
  final String fullName;
  final String role;
  final String? roleName;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;

  factory MyUser.fromMap(Map<String, dynamic> data) {
    return MyUser(
      id: data['id'] as String,
      email: data['email'] as String,
      fullName: data['full_name'] ?? 'Người dùng chưa đặt tên',
      role: data['role'] ?? 'manager',
      createdAt: DateTime.tryParse(data['created_at']),
      lastSignInAt: DateTime.tryParse(data['last_sign_in_at']),
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = {
      "id": id,
      "email": email,
      "full_name": fullName,
      "role": role,
      "created_at": createdAt?.toIso8601String(),
      "last_sign_in_at": lastSignInAt?.toIso8601String(),
    };

    result.removeWhere(
      (key, value) => value == null || value.toString().trim().isEmpty,
    );
    return result;
  }
}
