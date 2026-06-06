import 'package:electronic_component_storage_app/control/supabase_account_controller.dart';
import 'package:electronic_component_storage_app/model/my_user.dart';
import 'package:electronic_component_storage_app/view/my_app_bar.dart';
import 'package:electronic_component_storage_app/view/profile/change_user_password_screen.dart';
import 'package:electronic_component_storage_app/view/profile/editable_user_display_name.dart';
import 'package:electronic_component_storage_app/view/profile/logout_button.dart';
import 'package:electronic_component_storage_app/view/profile/user_avatar_widget.dart';
import 'package:electronic_component_storage_app/view/profile/version_info_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MyUser currentUser = SupabaseAccountController.userCached;

    return Scaffold(
      appBar: MyAppBar(icon: Icon(Icons.person), title: "Tài khoản"),
      body: ListView(
        padding: const EdgeInsets.all(15.0),
        children: [
          const UserAvatarWidget(),

          const Center(child: EditableUserDisplayName()),

          const SizedBox(height: 10),

          const Text('Vai trò', style: TextStyle(fontWeight: FontWeight.bold)),

          TextFormField(readOnly: true, initialValue: currentUser.roleName),

          const SizedBox(height: 15),

          const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),

          TextFormField(readOnly: true, initialValue: currentUser.email),

          const SizedBox(height: 15),

          const Text('Mật khẩu', style: TextStyle(fontWeight: FontWeight.bold)),

          TextFormField(
            readOnly: true,
            obscureText: true,
            initialValue: "aaaaaaaaaa",
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeUserPasswordScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.lock_reset),
              ),
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'ID người dùng',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          TextFormField(
            readOnly: true,
            textAlignVertical: TextAlignVertical.center,
            initialValue: currentUser.id,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: currentUser.id ?? ""),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã copy ID người dùng vào clipboard'),
                      ),
                    );
                  }
                },
                icon: Icon(Icons.copy),
              ),
            ),
          ),

          const SizedBox(height: 30),

          LogoutButton(),

          const SizedBox(height: 30,),

          VersionInfoWidget(),
        ],
      ),
    );
  }
}
