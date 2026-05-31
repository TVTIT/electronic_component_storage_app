import 'package:electronic_component_storage_app/control/supabase_account_controller.dart';

class MyUser {
  MyUser({
    this.id,
    required this.email,
    this.password,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    this.createdAt,
    this.lastSignInAt,
  });

  String? id;
  String email;
  String? password;
  String fullName;
  String role;
  String? avatarUrl;
  DateTime? createdAt;
  DateTime? lastSignInAt;

  String get roleName =>
      SupabaseAccountController.rolesMapCached[role]['name'] ??
      "Nhân viên quản lý";

  factory MyUser.fromMap(Map<String, dynamic> data) {
    return MyUser(
      id: data['id'] as String,
      email: data['email'] as String,
      password: data['password'],
      fullName: data['full_name'] ?? 'Người dùng chưa đặt tên',
      role: data['role'] ?? 'manager',
      avatarUrl: data['avatar_url'],
      createdAt: DateTime.tryParse(data['created_at'] ?? ""),
      lastSignInAt: DateTime.tryParse(data['last_sign_in_at'] ?? ""),
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = {
      "id": id,
      "email": email,
      "password": password,
      "full_name": fullName,
      "role": role,
      "avatar_url": avatarUrl,
      "created_at": createdAt?.toIso8601String(),
      "last_sign_in_at": lastSignInAt?.toIso8601String(),
    };

    result.removeWhere(
      (key, value) => value == null || value.toString().trim().isEmpty,
    );
    return result;
  }
}
