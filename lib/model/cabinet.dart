class Cabinet {
  Cabinet({this.id, required this.name, this.description, this.totalItem = 0});
  String? id;
  String name;
  String? description;
  int totalItem;

  factory Cabinet.fromMap(Map<String, dynamic> data) => Cabinet(
    id: data["id"],
    name: data["name"] ?? "Tủ chưa đặt tên",
    description: data["description"],
    totalItem: data["total_items"],
  );

  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = {
      "id": id,
      "name": name,
      "description": description,
    };
    result.removeWhere(
      (key, value) => value == null || value.toString().trim().isEmpty,
    );
    return result;
  }
}
