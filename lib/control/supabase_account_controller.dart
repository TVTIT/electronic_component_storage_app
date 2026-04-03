import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAccountController {
  static const Map<String, String> loginErrorCodeMap = {
    "invalid_credentials": "Sai tài khoản hoặc mật khẩu",
    "same_password": "Mật khẩu mới không được trùng với mật khẩu cũ",
  };

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
