import 'dart:io';

import 'package:electronic_component_storage_app/control/supabase_account_controller.dart';
import 'package:dio/dio.dart';

class ApiController {
  static final dio = Dio(
    BaseOptions(
      baseUrl:
          'https://api.componentvault.shop',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  static Future<Map<String, dynamic>> callResistorColorBandApi(File resistorImage) async {
    final accessToken = SupabaseAccountController.userAccessToken();
    final FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        resistorImage.path,
        filename: resistorImage.path.split('/').last,
      ),
    });
    final response = await dio.post(
      '/scan-resistor',
      data: formData,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception("Lỗi server: ${response.statusCode}");
    }
  }
}
