import 'package:electronic_component_storage_app/string_extension.dart';

class Component {
  Component({
    required this.id,
    required this.partNumber,
    required this.name,
    required this.quantity,
    this.minThreshold = 10,
    required this.locationID,
    required this.specs,
    required this.imageUrl,
    this.addedViaAI = false,
    required this.createdAt,
    required this.updatedAt,
    required this.categoryID,
  }) : searchName = name.toLowerCase().toUnaccented().trim();

  String id;
  String partNumber;
  String name;
  String searchName;
  int quantity;
  int minThreshold = 10;
  String locationID;
  Map<dynamic, dynamic> specs;
  String imageUrl;
  bool addedViaAI = false;
  DateTime createdAt;
  DateTime updatedAt;
  String categoryID;

  //static const minThreshold = 10;
  static final DateTime _defaultTime = DateTime(2000);

  bool get isLowStock => quantity < minThreshold;

  factory Component.fromMap(Map<dynamic, dynamic> data) {
    final String createdAtStr = data['createdAt'] ?? "";
    final String updatedAtStr = data['updatedAt'] ?? "";
    DateTime createdAt = createdAtStr.isNotEmpty ? DateTime.parse(createdAtStr): _defaultTime;
    DateTime updatedAt = updatedAtStr.isNotEmpty ? DateTime.parse(updatedAtStr): _defaultTime;
    return Component(
      id: data['id'] ?? "",
      partNumber: data['partNumber'] ?? "",
      name: data['name'] ?? "",
      quantity: data['quantity'] ?? "",
      minThreshold: data['min_threshold'] ?? 10,
      locationID: data['location_id'] ?? "",
      specs: data['specs'] ?? {},
      imageUrl: data['image_url'] ?? "",
      addedViaAI: data['added_via_ai'] ?? false,
      createdAt: createdAt,
      updatedAt: updatedAt,
      categoryID: data['category_id'],
    );
  }
}
