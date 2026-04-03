import 'package:electronic_component_storage_app/control/supabase_account_controller.dart';
import 'package:electronic_component_storage_app/view/profile/change_user_password_screen.dart';
import 'package:electronic_component_storage_app/view/profile/editable_user_display_name.dart';
import 'package:electronic_component_storage_app/view/profile/logout_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userID = SupabaseAccountController.userID();
    return Scaffold(
      appBar: AppBar(title: Text("Tài khoản")),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            const SizedBox(
              height: 120,
              width: 120,
              child: ClipPath(
                clipper: ShapeBorderClipper(shape: CircleBorder()),
                clipBehavior: Clip.hardEdge,
                child: Center(
                  child: Icon(
                    Icons.account_circle,
                    size: 120,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            const Center(child: EditableUserDisplayName()),

            const SizedBox(height: 10),

            const Text(
              'Vai trò',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            TextFormField(
              readOnly: true,
              initialValue: "Người dùng", //TODO: thêm hàm lấy userRole
            ),

            const SizedBox(height: 10),

            const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),

            TextFormField(
              readOnly: true,
              initialValue: SupabaseAccountController.userEmail(),
            ),

            const SizedBox(height: 10),

            const Text(
              'Mật khẩu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

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

            const SizedBox(height: 10),

            const Text(
              'ID người dùng',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            TextFormField(
              readOnly: true,
              initialValue: userID,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: userID));
                    const snackBar = SnackBar(
                      content: Text('Đã copy ID người dùng vào clipboard'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  icon: Icon(Icons.copy),
                ),
              ),
            ),

            const SizedBox(height: 30),

            LogoutButton(),
          ],
        ),
      ),
    );
  }
}
