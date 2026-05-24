import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/model/my_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAccountController {
  static const Map<String, String> loginErrorCodeMap = {
    "invalid_credentials": "Sai tài khoản hoặc mật khẩu",
    "same_password": "Mật khẩu mới không được trùng với mật khẩu cũ",
  };

  // static const Map<String, String> userRoleMap = {
  //   "manager": "Nhân viên quản lý",
  //   "admin": "Quản trị viên",
  //   "owner": "Chủ sở hữu",
  // };

  static final supabase = Supabase.instance.client;
  static final supabaseAuth = Supabase.instance.client.auth;

  static Map<String, dynamic> rolesMapCached = {};
  static Future<Map<String, dynamic>> getAllRoles() async {
    final listMap = await supabase.from('roles').select();
    rolesMapCached = SupabaseDatabaseController.normalizeData(listMap);
    return rolesMapCached;
  }

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
      return 'manager';
    }

    final response = await supabase
        .from('user_roles')
        .select('role_id')
        .eq('user_id', user.id)
        .single();

    userRoleCached = response['role_id'] as String;
    return userRoleCached;
  }

  static late MyUser userCached;
  static Future<MyUser> getAllUserData() async {
    if (rolesMapCached.isEmpty) {
      await getAllRoles();
    }
    userCached = MyUser(
      id: userID(),
      email: userEmail(),
      fullName: userName(),
      role: await userRole(),
    );
    return userCached;
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
