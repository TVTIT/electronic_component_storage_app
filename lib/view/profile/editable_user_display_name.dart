//Copy từ EditableUserDisplayName của FirebaseUI
import 'package:electronic_component_storage_app/control/supabase_account_controller.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditableUserDisplayName extends StatefulWidget {
  const EditableUserDisplayName({super.key});

  @override
  State<EditableUserDisplayName> createState() =>
      _EditableUserDisplayNameState();
}

class _EditableUserDisplayNameState extends State<EditableUserDisplayName> {
  late TextEditingController ctrl;
  String? displayName;
  late bool _editing = displayName == null;
  bool _isLoading = false;

  void _onEdit() {
    setState(() {
      _editing = true;
    });
  }

  Future<void> _finishEditing(String newDisplayName) async {
    try {
      if (displayName == newDisplayName) return;

      setState(() {
        _isLoading = true;
      });

      //final previousDisplayName = displayName;
      displayName = newDisplayName;
      //await FirebaseAccountController.setUserDisplayName(newDisplayName);
      SupabaseAccountController.updateUserName(newDisplayName);

      // FirebaseUIAction.ofType<DisplayNameChangedAction>(
      //   context,
      // )?.callback(context, previousDisplayName, newDisplayName);
    } finally {
      setState(() {
        _editing = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _getUserDisplayName() async {
    String result = SupabaseAccountController.userName();

    if (!mounted) {
      return;
    }

    setState(() {
      displayName = result;
      ctrl.text = result;
    });
  }

  @override
  void initState() {
    super.initState();
    ctrl = TextEditingController();
    _getUserDisplayName();
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (displayName == null) {
      return const CircularProgressIndicator();
    }

    Widget iconButton = IconButton(
      icon: Icon(_editing ? Icons.check : Icons.edit),
      color: theme.colorScheme.secondary,
      onPressed: _editing ? () => _finishEditing(ctrl.text) : _onEdit,
    );

    if (!_editing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.5),
        child: IntrinsicWidth(
          child: Row(
            children: [
              Text(
                displayName ?? 'Người dùng chưa đặt tên',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              iconButton,
            ],
          ),
        ),
      );
    }

    Widget textField = Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: const Text(
            'Tên',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        TextField(
          autofocus: true,
          controller: ctrl,
          decoration: InputDecoration(hintText: 'Nhập tên của bạn'),
          onSubmitted: (_) => _finishEditing(ctrl.text),
        ),
      ],
    );

    return Row(
      children: [
        Expanded(child: textField),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          height: 32,
          child: Stack(
            children: [
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Align(alignment: Alignment.topLeft, child: iconButton),
            ],
          ),
        ),
      ],
    );
  }
}
