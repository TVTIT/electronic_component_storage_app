import 'package:electronic_component_storage_app/control/supabase_account_controller.dart';
import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/dashboard/location_widget.dart';
import 'package:electronic_component_storage_app/view/dashboard/restock_items_widget.dart';
import 'package:electronic_component_storage_app/view/dashboard/storage_stat_widget.dart';
import 'package:electronic_component_storage_app/view/dashboard/top_components_widget.dart';
import 'package:electronic_component_storage_app/view/dashboard/transactions_list_widget.dart';
import 'package:electronic_component_storage_app/view/dashboard/user_list_widget.dart';
import 'package:electronic_component_storage_app/view/my_app_bar.dart';
import 'package:electronic_component_storage_app/view/storage/add_component/add_component_screen.dart';
import 'package:electronic_component_storage_app/view/storage/export_screen/export_component_screen.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

Widget _buildFastActionButton({
  required String title,
  required IconData icon,
  required VoidCallback onPressed,
}) {
  return FilledButton.icon(
    onPressed: onPressed,
    label: Text(title, style: TextStyle(fontSize: 16),),
    icon: Icon(icon, size: 22,),
    style: FilledButton.styleFrom(
      backgroundColor: AppColor.secondaryContainer,
      foregroundColor: AppColor.onSecondaryFixedVariant,
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final userName = SupabaseAccountController.userName();
    final List<Widget> listViewChildren = [
      Text(
        "Xin chào, $userName",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: Color(0xFF00464A),
          letterSpacing: -0.5,
        ),
      ),
      const SizedBox(height: 20),
      StorageStatWidget(),
      const SizedBox(height: 20),
      _buildFastActionButton(
        title: "Nhập kho linh kiện",
        icon: Icons.add_box_outlined,
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => AddComponentScreen())),
      ),
      const SizedBox(height: 15,),
      _buildFastActionButton(
        title: "Xuất kho linh kiện",
        icon: Icons.outbox,
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => ExportComponentScreen())),
      ),

      const SizedBox(height: 40),
      TopComponentsWidget(),
      const SizedBox(height: 20),
      RestockItemsWidget(),
    ];
    if (SupabaseAccountController.userRoleCached == 'owner') {
      listViewChildren.addAll([
        const SizedBox(height: 20),
        TransactionsListWidget(),
      ]);
    }
    if (SupabaseAccountController.userRoleCached == 'admin' ||
        SupabaseAccountController.userRoleCached == 'owner') {
      listViewChildren.addAll([const SizedBox(height: 20), LocationWidget()]);
    }
    if (SupabaseAccountController.userRoleCached == 'owner') {
      listViewChildren.addAll([const SizedBox(height: 20), UserListWidget()]);
    }
    return Scaffold(
      appBar: MyAppBar(icon: Icon(Icons.dashboard), title: "Dashboard"),
      body: RefreshIndicator(
        onRefresh: () async {
          await SupabaseDatabaseController.getInitialData();
          if (SupabaseAccountController.userCached.role == 'owner') {
            await SupabaseAccountController.getAllUserInSystem();
            await SupabaseDatabaseController.getAllTransactionHistory();
          }
          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: listViewChildren,
        ),
      ),
    );
  }
}
