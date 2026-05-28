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

  static Future<String> uploadFile({
    required String bucket,
    required File file,
    String fileExtension = ".jpg",
  }) async {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final filePath = '${_generateId().toString()}_$timestamp$fileExtension';
    await supabase.storage
        .from(bucket)
        .upload(
          filePath,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );
    return supabase.storage.from(bucket).getPublicUrl(filePath);
  }
}
