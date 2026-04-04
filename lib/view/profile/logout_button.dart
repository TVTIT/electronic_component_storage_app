import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text("Đăng xuất thành công")),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(milliseconds: 1500),
        ),
      );
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
