import 'package:electronic_component_storage_app/view/profile/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionInfoWidget extends StatelessWidget {
  const VersionInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final packageInfo = snapshot.data!;
          return Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => AboutScreen()));
              },
              child: Text(
                'Component Vault version ${packageInfo.version} build ${packageInfo.buildNumber}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          );
        }
        //return rỗng khi chưa có data
        return SizedBox.shrink();
      },
    );
  }
}
