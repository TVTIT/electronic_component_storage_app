import 'package:electronic_component_storage_app/model/component.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDatabaseController {
  static final supabase = Supabase.instance.client;

  static List<Component> listComponentCached = [];
  static Future<List<Component>> getAllComponent() async {
    List<Map> listMap = await supabase.from('components').select();
    listComponentCached = listMap.map((map) => Component.fromMap(map)).toList();
    return listComponentCached;
  }

  //Chuyển list map từ database trả về thành 1 map có các id làm key
  static Map<String, Map<String, dynamic>> normalizeData(
    List<Map<String, dynamic>> inputList,
  ) {
    final Map<String, Map<String, dynamic>> normalizedMap = {};

    for (final item in inputList) {
      if (!item.containsKey('id') || item['id'] == null) {
        continue;
      }
      //Chuyển id về string cho chắc
      final String id = item['id'].toString();

      //Backup data sang 1 map khác rồi xoá id đi
      final Map<String, dynamic> itemData = Map<String, dynamic>.from(item);
      itemData.remove('id');

      //Gán dữ liệu của key chứa id vào map tổng
      normalizedMap[id] = itemData;
    }

    return normalizedMap;
  }

  static Map<String, dynamic> categoryMapCached = {};
  static Future<Map<String, dynamic>> getAllCategory() async {
    final listMap = await supabase.from('categories').select();
    categoryMapCached = normalizeData(listMap);
    return categoryMapCached;
  }

  static Map<String, dynamic> locationMapCached = {};
  static Future<Map<String, dynamic>> getAllLocation() async {
    final listMap = await supabase.from('locations').select();
    locationMapCached = normalizeData(listMap);
    return locationMapCached;
  }

  static Future<void> getInitialData() async {
    await SupabaseDatabaseController.getAllComponent();
    await SupabaseDatabaseController.getAllLocation();
    await SupabaseDatabaseController.getAllCategory();
  }
}
