import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _githubUrl =
      'https://github.com/TVTIT/electronic_component_storage_app';

  Future<void> _openGithub(BuildContext context) async {
    final Uri url = Uri.parse(_githubUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Về chúng tôi'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          // Header
          const Text(
            'Nhóm phát triển',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColor.primaryDarkColor,
            ),
          ),

          const SizedBox(height: 25),

          // Team members
          _buildMemberItem(
            name: 'Trần Vĩnh Trung',
            imagePath: 'assets/developer/trung.jpg',
          ),
          _buildMemberItem(
            name: 'Nguyễn Quý Bách',
            imagePath: 'assets/developer/bach.jpg',
          ),
          _buildMemberItem(
            name: 'Đỗ Minh Hiếu',
            imagePath: 'assets/developer/hieu.jpg',
          ),

          const SizedBox(height: 32),

          // GitHub section
          Container(
            decoration: BoxDecoration(
              color: AppColor.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsetsGeometry.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mã nguồn mở',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColor.primaryDarkColor,
                    ),
                  ),
                  const Text("Đóng góp cho dự án của chúng tôi"),

                  const SizedBox(height: 15),

                  Center(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await _openGithub(context);
                      },
                      label: const Text("Xem mã nguồn trên Github"),
                      icon: Icon(Icons.open_in_new_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberItem({required String name, required String? imagePath}) {
    return Column(
      children: [
        // Ảnh thành viên — tỉ lệ 2:3, chiếm full width cột
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: FractionallySizedBox(
            widthFactor: 0.5,
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Container(
                color: AppColor.surfaceContainerLow,
                child: imagePath != null
                    ? Image.asset(imagePath, fit: BoxFit.cover)
                    : const Icon(
                        Icons.person,
                        size: 40,
                        color: AppColor.onSurfaceVariant,
                      ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Tên
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColor.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 15),

        // Vai trò
        // Text(
        //   role,
        //   textAlign: TextAlign.center,
        //   style: const TextStyle(
        //     fontSize: 12,
        //     color: AppColor.onSurfaceVariant,
        //   ),
        // ),
      ],
    );
  }
}
