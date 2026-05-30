import 'dart:io';
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageController {
  static final supabase = Supabase.instance.client;

  static String _generateId({int length = 32}) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  static Future<String> createSignedUrl({
    required String bucket,
    required String filePath,
    int signedUrlExpriesIn = 3600,
  }) async {
    return await supabase.storage
        .from(bucket)
        .createSignedUrl(filePath, signedUrlExpriesIn);
  }

  static Future<String> uploadFile({
    required String bucket,
    required File file,
    String? customFilePath,
    String fileExtension = ".jpg",
    bool isPrivateBucket = false,
    int signedUrlExpriesIn = 3600,
  }) async {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    late String filePath;
    if (customFilePath == null || customFilePath.isEmpty) {
      filePath = '${_generateId().toString()}_$timestamp$fileExtension';
    } else {
      filePath = customFilePath;
    }
    await supabase.storage
        .from(bucket)
        .upload(
          filePath,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );
    if (isPrivateBucket) {
      return await createSignedUrl(
        bucket: bucket,
        filePath: filePath,
        signedUrlExpriesIn: signedUrlExpriesIn,
      );
    } else {
      return supabase.storage.from(bucket).getPublicUrl(filePath);
    }
  }
}
