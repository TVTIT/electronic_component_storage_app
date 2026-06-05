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
    this.datasheetUrl,
    this.categoryName,
    this.locationName,
  });

  String? id;
  String name;
  int quantity;
  int minThreshold = 10;
  String locationID;
  Map<dynamic, dynamic>? specs;
  String? imageUrl;
  bool addedViaAI = false;
  DateTime? createdAt;
  DateTime? updatedAt;
  String categoryID;
  String? datasheetUrl;
  String? categoryName;
  String? locationName;

  //static const minThreshold = 10;
  //static final DateTime _defaultTime = DateTime(2000);

  String get searchName => name.toLowerCase().toUnaccented().trim();

  bool get isLowStock => quantity < minThreshold;

  factory Component.from(Component other) {
    return Component(
      id: other.id,
      name: other.name,
      quantity: other.quantity,
      minThreshold: other.minThreshold,
      locationID: other.locationID,
      specs: other.specs != null ? Map<dynamic, dynamic>.from(other.specs!) : null,
      imageUrl: other.imageUrl,
      addedViaAI: other.addedViaAI,
      createdAt: other.createdAt,
      updatedAt: other.updatedAt,
      categoryID: other.categoryID,
      datasheetUrl: other.datasheetUrl
    );
  }

  factory Component.fromMap(Map<dynamic, dynamic> data) {
    final String createdAtStr = data['createdAt'] ?? "";
    final String updatedAtStr = data['updatedAt'] ?? "";
    DateTime? createdAt = DateTime.tryParse(createdAtStr);
    DateTime? updatedAt = DateTime.tryParse(updatedAtStr);
    return Component(
      id: data['id'] ?? "",
      name: data['name'] ?? "",
      quantity: data['quantity'] ?? 0,
      minThreshold: data['min_threshold'] ?? 10,
      locationID: data['location_id'] ?? "",
      specs: data['specs'] ?? {},
      imageUrl: data['image_url'] ?? "",
      addedViaAI: data['added_via_ai'] ?? false,
      createdAt: createdAt,
      updatedAt: updatedAt,
      categoryID: data['category_id'],
      datasheetUrl: data['datasheet_url'],
      categoryName: data['category_name'],
      locationName: data['location_name'],
    );
  }

  Map<String, dynamic> toMap({bool addToDatabase = false}) {
    Map<String, dynamic> result = {
      'id': id,
      'name': name,
      'quantity': quantity,
      'min_threshold': minThreshold,
      'location_id': locationID,
      'category_id': categoryID,
      'specs': specs,
      'image_url': imageUrl,
      'added_via_ai': addedViaAI,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'datasheet_url': datasheetUrl,
      'category_name': categoryName ?? "",
      'location_name': locationName ?? "", //Để bị xoá khi null
    };

    // Xoá các giá trị null
    result.removeWhere((key, value) => value.toString().trim().isEmpty);

    return result;
  }

  Map<String, dynamic> toIdQuantityMap() {
    return {'id': id, 'quantity': quantity};
  }
}
