import 'package:electronic_component_storage_app/control/supabase_account_controller.dart';
import 'package:electronic_component_storage_app/control/supabase_database_controller.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/dashboard/restock_items_widget.dart';
import 'package:electronic_component_storage_app/view/dashboard/storage_stat_widget.dart';
import 'package:electronic_component_storage_app/view/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final userName = SupabaseAccountController.userName();
    return Scaffold(
      appBar: MyAppBar(icon: Icon(Icons.dashboard), title: "Dashboard"),
      body: RefreshIndicator(
        onRefresh: () async {
          await SupabaseDatabaseController.getInitialData();
          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
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
            RestockItemsWidget(),
          ],
        ),
      ),
    );
  }
}
