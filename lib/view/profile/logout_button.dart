import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:electronic_component_storage_app/view/custom_widget.dart';

class LogoutButton extends StatefulWidget {
  const LogoutButton({super.key});

  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  bool _isLoading = false;

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      CustomWidget.showFloatingSnackbar(context, text: "Đăng xuất thành công");
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ElevatedButton(
        onPressed: () {},
        child: const CircularProgressIndicator(),
      );
    }
    
    return ElevatedButton.icon(
      onPressed: () async {
        await _logout();
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        foregroundColor: const Color.fromARGB(255, 172, 74, 67),
      ),
      icon: Icon(Icons.logout),
      label: Text("Đăng xuất"),
    );
  }
}
