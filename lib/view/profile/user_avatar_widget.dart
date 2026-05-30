import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:electronic_component_storage_app/control/supabase_account_controller.dart';
import 'package:electronic_component_storage_app/control/supabase_storage_controller.dart';
import 'package:electronic_component_storage_app/view/app_color.dart';
import 'package:electronic_component_storage_app/view/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

class UserAvatarWidget extends StatefulWidget {
  const UserAvatarWidget({super.key});

  @override
  State<UserAvatarWidget> createState() => _UserAvatarWidgetState();
}

class _UserAvatarWidgetState extends State<UserAvatarWidget> {
  final Widget _defaultAvatar = Icon(
    Icons.account_circle,
    size: 120,
    color: Colors.grey,
  );
  late Widget _inkWellChild = _defaultAvatar;

  String? _avatarUrl;

  Future<void> _getAvatarLink() async {
    final temp = await SupabaseStorageController.createSignedUrl(
      bucket: 'user_avatar',
      filePath: '${SupabaseAccountController.userCached.id}.jpg',
    );
    setState(() {
      _avatarUrl = temp;
    });
  }

  @override
  void initState() {
    if (SupabaseAccountController.userCached.isAvatarAvail) {
      _getAvatarLink();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      _inkWellChild = CachedNetworkImage(
        imageUrl: _avatarUrl!,
        progressIndicatorBuilder: (context, url, downloadProgress) => SizedBox(
          height: 60,
          width: 60,
          child: Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
        ),
        errorWidget: (context, url, error) => _defaultAvatar,
      );
    }
    return SizedBox(
      height: 120,
      width: 120,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () async {
            try {
              //Chọn ảnh
              File? pickedFile = await CustomWidget.showChooseImageDialog(
                context,
              );
              if (pickedFile == null) return;

              //Crop ảnh thành ảnh vuông
              final CroppedFile? croppedFile = await ImageCropper().cropImage(
                sourcePath: pickedFile.path,
                aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
                uiSettings: [
                  AndroidUiSettings(
                    toolbarTitle: 'Chỉnh sửa ảnh đại diện',
                    toolbarColor: AppColor.primaryColor,
                    toolbarWidgetColor: Colors.white,
                    initAspectRatio: CropAspectRatioPreset.square,
                    lockAspectRatio: true,
                    hideBottomControls: true,
                  ),
                  IOSUiSettings(
                    title: 'Chỉnh sửa ảnh đại diện',
                    cancelButtonTitle: 'Huỷ',
                    doneButtonTitle: 'Xong',
                    aspectRatioLockEnabled: true,
                    resetAspectRatioEnabled: false,
                  ),
                ],
              );

              if (croppedFile == null) {
                return;
              }

              //Lưu ra temp và nén ảnh
              final Directory tempDir = await getTemporaryDirectory();
              final String targetPath = '${tempDir.path}/avatar_temp.jpg';

              final XFile? compressedXFile =
                  await FlutterImageCompress.compressAndGetFile(
                    croppedFile.path,
                    targetPath,
                    quality: 80,
                    minWidth: 512,
                    minHeight: 512,
                    format: CompressFormat.jpeg,
                  );

              if (compressedXFile == null) {
                throw Exception("Không thể nén ảnh");
              }
              final File finalAvatarFile = File(compressedXFile.path);

              final newAvatarLink = await SupabaseStorageController.uploadFile(
                bucket: 'user_avatar',
                customFilePath:
                    '${SupabaseAccountController.userCached.id}.jpg',
                file: finalAvatarFile,
                isPrivateBucket: true,
              );

              setState(() {
                _avatarUrl = newAvatarLink;
              });

              SupabaseAccountController.updateUserAvatarAvail(true);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Có lỗi xảy ra $e")));
              }
            }
          },
          child: _inkWellChild,
        ),
      ),
    );
  }
}
