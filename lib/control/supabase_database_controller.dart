import 'package:electronic_component_storage_app/model/component.dart';
import 'package:electronic_component_storage_app/model/cabinet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDatabaseController {
  static final supabase = Supabase.instance.client;

  static List<Component> listComponentCached = [];
  //Lấy toàn bộ danh sách linh kiện chưa xoá
  static Future<List<Component>> getAllComponent() async {
    List<Map> listMap = await supabase
        .from('components')
        .select()
        .eq('deleted', false)
        .order('id', ascending: true);
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
  static List<Cabinet> listCabinetCached = [];
  static Future<Map<String, dynamic>> getAllLocation() async {
    final listMap = await supabase.from('location_stats').select().order('id', ascending: true);
    listCabinetCached = listMap.map((map) => Cabinet.fromMap(map)).toList();
    locationMapCached = normalizeData(listMap);
    return locationMapCached;
  }

  static Future<void> addLocation(Cabinet cabinet) async {
    await supabase.from('locations').insert(cabinet.toMap());
  }

  static Future<void> editLocation(Cabinet cabinet) async {
    if (cabinet.id == null || cabinet.id!.isEmpty) {
      throw Exception("cabinet.id is null or empty");
    }
    await supabase
        .from('locations')
        .update(cabinet.toMap())
        .eq('id', cabinet.id!);
  }

  static Future<void> getInitialData() async {
    await SupabaseDatabaseController.getAllComponent();
    await SupabaseDatabaseController.getAllLocation();
    await SupabaseDatabaseController.getAllCategory();
  }

  static Future<void> addComponent(Component component) async {
    await supabase
        .from('components')
        .insert(component.toMap(addToDatabase: true));
  }

  static Future<void> addBulkComponent(List<Component> components) async {
    await supabase
        .from('components')
        .insert(components.map((e) => e.toMap(addToDatabase: true)).toList());
  }

  static Future<void> addImportQuantityComponent(
    List<Component> components,
  ) async {
    List<Map<String, dynamic>> updateData = components
        .map((component) => component.toMap())
        .toList();
    await supabase.rpc('import_components', params: {'payload': updateData});
  }

  //Quantity trong list là quantity sau khi xuất
  static Future<void> exportBulkComponent(List<Component> components) async {
    List<Map<String, dynamic>> updateData = components
        .map((component) => component.toIdQuantityMap())
        .toList();
    await supabase.rpc('export_components', params: {'payload': updateData});
  }

  static Future<void> updateComponent(Component component) async {
    if (component.id != null) {
      await supabase
          .from('components')
          .update(component.toMap(addToDatabase: true))
          .eq('id', component.id!);
    } else {
      throw Exception("component.id is null");
    }
  }

  static Future<void> softDeleteComponent(Component component) async {
    if (component.id == null) {
      throw Exception("component.id is null");
    }
    await supabase
        .from('components')
        .update({'deleted': true})
        .eq('id', component.id!);
  }

  static Future<void> softBulkDeleteComponent(
    List<Component> listComponents,
  ) async {
    await supabase
        .from('components')
        .update({'deleted': true})
        .inFilter(
          'id',
          listComponents.map((component) => component.id).toList(),
        );
  }
}
