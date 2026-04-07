import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAccountController {
  static const Map<String, String> loginErrorCodeMap = {
    "invalid_credentials": "Sai tài khoản hoặc mật khẩu",
    "same_password": "Mật khẩu mới không được trùng với mật khẩu cũ",
  };

  static const Map<String, String> userRoleMap = {
    "manager": "Nhân viên quản lý",
    "admin": "Quản trị viên",
    "owner": "Chủ sở hữu",
  };

  static final supabase = Supabase.instance.client;
  static final supabaseAuth = Supabase.instance.client.auth;
  static Map<String, dynamic> userData() {
    return supabaseAuth.currentUser?.userMetadata ?? {};
  }

  static String userName() {
    return supabaseAuth.currentUser?.userMetadata?['full_name'] ??
        'Người dùng chưa đặt tên';
  }

  static String userEmail() {
    return supabaseAuth.currentUser?.email ?? "user@example.com";
  }

  static String userID() {
    return supabaseAuth.currentUser?.id ?? "";
  }

  static String userRoleCached = "";
  //Đặt trong try-catch
  static Future<String> userRole() async {
    final user = supabaseAuth.currentUser;
    if (user == null) {
      return userRoleMap.keys.first;
    }

    final response = await supabase
        .from('user_roles')
        .select('role_id')
        .eq('user_id', user.id)
        .single();

    userRoleCached = response['role_id'] as String;
    return userRoleCached;
  }

  static Future<void> updateUserData(Map<String, dynamic> data) async {
    await supabaseAuth.updateUser(UserAttributes(data: data));
  }

  static Future<void> updateUserName(String newName) async {
    await updateUserData({'full_name': newName.trim()});
  }

  static Future<void> updateUserPassword(String newPassword) async {
    await supabaseAuth.updateUser(UserAttributes(password: newPassword));
  }
}
