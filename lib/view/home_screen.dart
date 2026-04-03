import 'package:electronic_component_storage_app/view/add_component_screen.dart';
import 'package:electronic_component_storage_app/view/dashboard_screen.dart';
import 'package:electronic_component_storage_app/view/notification_screen.dart';
import 'package:electronic_component_storage_app/view/profile/profile_screen.dart';
import 'package:electronic_component_storage_app/view/storage_screen.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _currentStack = 0;

//   final List<Widget> indexedStackChildren = [
//     const DashboardScreen(),
//     const StorageScreen(),
//     const AddComponentScreen(),
//     const NotificationScreen(),
//     const SettingScreen()
//   ];

//   final List<BottomNavigationBarItem> bottomItems = [
//     const BottomNavigationBarItem(
//       icon: Icon(Icons.dashboard),
//       label: 'Dashboard',
//     ),
//     const BottomNavigationBarItem(
//       icon: Icon(Icons.inventory),
//       label: 'Tài khoản',
//     ),
//     const BottomNavigationBarItem(
//       icon: Icon(Icons.add),

//     )
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ,
//     );
//   }
// }

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  ItemConfig _itemConfigBuilder({required Icon icon, String? title, Color? activeForegroundColor, Color? inactiveForegroundColor}) {
    return ItemConfig(
      icon: icon,
      title: title ?? "",
      activeForegroundColor: activeForegroundColor ?? Color(0xFF006064),
      inactiveForegroundColor: inactiveForegroundColor ?? Colors.grey
    );
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      tabs: [
        PersistentTabConfig(
          screen: const DashboardScreen(),
          // item: ItemConfig(
          //   icon: Icon(Icons.dashboard),
          //   title: "Dashboard",
          //   activeForegroundColor: Color.fromARGB(255, 0, 97, 100),
          //   inactiveForegroundColor: Colors.grey
          // ),
          item: _itemConfigBuilder(
            icon: Icon(Icons.dashboard),
            title: "Dashboard",
          ),
        ),
        PersistentTabConfig(
          screen: const StorageScreen(),
          item: _itemConfigBuilder(
            icon: Icon(Icons.inventory),
            title: "Kho linh kiện",
          ),
        ),
        PersistentTabConfig(
          screen: const AddComponentScreen(),
          item: _itemConfigBuilder(icon: Icon(Icons.add), inactiveForegroundColor: Colors.white),
          //item: ItemConfig(icon: Icon(Icons.add), inactiveForegroundColor: Colors.white, activeForegroundColor: Color(0xFF006064))
        ),
        PersistentTabConfig(
          screen: const NotificationScreen(),
          item: _itemConfigBuilder(icon: Icon(Icons.notifications), title: "Thông báo"),
        ),
        PersistentTabConfig(
          screen: const ProfileScreen(),
          item: _itemConfigBuilder(icon: Icon(Icons.person), title: "Tài khoản"),
        ),
      ],

      navBarBuilder: (navBarConfig) => Style14BottomNavBar(
        navBarConfig: navBarConfig,
        navBarDecoration: NavBarDecoration(
          padding: EdgeInsets.only(bottom: 10),
        ),
      ),
    );
  }
}
