import 'package:electronic_component_storage_app/control/supabase_account_controller.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/dashboard/restock_items_widget.dart';
import 'package:electronic_component_storage_app/view/dashboard/storage_stat_widget.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = SupabaseAccountController.userName();
    return Scaffold(
      backgroundColor: AppColor.surfaceColor,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.dashboard, color: AppColor.primaryColor, size: 28),

            SizedBox(width: 15),

            Text(
              "Dashboard",
              style: TextStyle(
                color: AppColor.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
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
    );
  }
}
