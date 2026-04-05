class Component {
  Component({
    required this.name,
    required this.category,
    required this.quantity,
    required this.location
  });
  // String id;
  // String partNumber;
  String name;
  String category;
  // String value;
  int quantity;
  // String description;
  String location;

  static const minThreshold = 10;

  static const Map<String, String> categoryMap = {
    "resistor": "Điện trở",
    "capacitor": "Tụ điện",
    "conductor": "Cuộn cảm",
    "sensor": "Cảm biến",
    "ic": "IC",
    "unknown": "Khác",
  };

  //TODO: Xoá list Component này
  static final List<Component> listComponentTest = [
    Component(name: "Điện trở 1k Ohm 5%", category: "resistor", quantity: 3, location: "Tủ A - Ngăn 1"),
    Component(name: "Tụ hoá 1000uF 25V", category: "capacitor", quantity: 50, location: "Tủ B - Ngăn 2"),
    Component(name: "IC NE555%", category: "ic", quantity: 36, location: "Tủ C - Ngăn 3"),
    Component(name: "IC 7805", category: "ic", quantity: 0, location: "Tủ D - Ngăn 4"),
  ];

  bool get isLowStock => quantity < 10;

  // factory Component.fromMap(Map<dynamic, dynamic> data) {
  //   return Component(
  //     category: data['category'],
  //     value: data['value'],
  //     quantity: data['quantity'],
  //   );
  // }
}
