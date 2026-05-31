import 'package:cached_network_image/cached_network_image.dart';
import 'package:electronic_component_storage_app/control/supabase_account_controller.dart';
import 'package:electronic_component_storage_app/model/my_user.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/dashboard/user_management/user_edit_info_screen.dart';
import 'package:electronic_component_storage_app/view/dashboard/user_management/user_list_screen.dart';
import 'package:flutter/material.dart';

class UserListWidget extends StatelessWidget {
  const UserListWidget({super.key});

  static const _defaultAvatar = Icon(
    Icons.account_circle,
    size: 48,
    color: AppColor.primaryDarkColor,
  );

  @override
  Widget build(BuildContext context) {
    List<MyUser> listUserDisplay = SupabaseAccountController.allUserList
        .take(3)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColor.primaryDarkColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Danh sách người dùng",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.onSurfaceColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => UserListScreen()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColor.primaryColor,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'XEM TẤT CẢ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Column(
          children: listUserDisplay
              .map((e) => _buildMemberCard(context, e))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildMemberCard(BuildContext context, MyUser user) {
    late Widget avatarWidget;
    if (user.avatarUrl == null || user.avatarUrl!.isEmpty) {
      avatarWidget = _defaultAvatar;
    } else {
      avatarWidget = SizedBox(
        height: 48,
        width: 48,
        child: CachedNetworkImage(
          imageUrl: user.avatarUrl!,
          errorWidget: (context, url, error) => _defaultAvatar,
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),

        border: const Border(
          left: BorderSide(color: AppColor.primaryDarkColor, width: 4),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UserEdtiInfoScreen(user: user),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: avatarWidget,
                ),
                const SizedBox(width: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.onSurfaceColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.roleName,
                      style: const TextStyle(
                        color: AppColor.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColor.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
