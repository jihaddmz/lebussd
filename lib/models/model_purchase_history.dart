import 'dart:ui';

class ModelPurchaseHistory {
  final int id;
  final double bundle;
  final double price;
  final String date;
  final String color;

  const ModelPurchaseHistory(
      {required this.id,
      required this.bundle,
      required this.price,
      required this.date,
      required this.color});

  Map<String, dynamic> toMap(int id) {
    return {'id': id, 'bundle': bundle, 'price': price, 'date': date, 'color': color};
  }

  @override
  String toString() {
    return 'ModelPurchaseHistory{id: $id, bundle: $bundle, price: $price, date: $date, color: $color}';
  }
}
