import 'package:electronic_component_storage_app/string_extension.dart';

class Component {
  Component({
    this.id,
    required this.name,
    required this.quantity,
    this.minThreshold = 10,
    required this.locationID,
    this.specs,
    this.imageUrl,
    this.addedViaAI = false,
    this.createdAt,
    this.updatedAt,
    required this.categoryID,
  }) : searchName = name.toLowerCase().toUnaccented().trim();

  String? id;
  String name;
  String searchName;
  int quantity;
  int minThreshold = 10;
  String locationID;
  Map<dynamic, dynamic>? specs;
  String? imageUrl;
  bool addedViaAI = false;
  DateTime? createdAt;
  DateTime? updatedAt;
  String categoryID;

  //static const minThreshold = 10;
  static final DateTime _defaultTime = DateTime(2000);

  bool get isLowStock => quantity < minThreshold;

  factory Component.fromMap(Map<dynamic, dynamic> data) {
    final String createdAtStr = data['createdAt'] ?? "";
    final String updatedAtStr = data['updatedAt'] ?? "";
    DateTime? createdAt = DateTime.tryParse(createdAtStr);
    DateTime? updatedAt = DateTime.tryParse(updatedAtStr);
    return Component(
      id: data['id'] ?? "",
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
