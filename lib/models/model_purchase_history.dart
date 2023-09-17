class ModelPurchaseHistory {
  final int id;
  final double bundle;
  final double price;
  final String phoneNumber;
  final String date;
  final String color;
  final int isTouch;

  const ModelPurchaseHistory(
      {required this.id,
      required this.bundle,
      required this.price,
      required this.date,
      required this.color,
      required this.phoneNumber,
      required this.isTouch});

  Map<String, dynamic> toMap(int id) {
    return {
      'id': id,
      'bundle': bundle,
      'price': price,
      'date': date,
      'color': color,
      'phoneNumber': phoneNumber,
      'isTouch': isTouch
    };
  }

  @override
  String toString() {
    return 'ModelPurchaseHistory{id: $id, bundle: $bundle, price: $price, date: $date, color: $color, phoneNumber: $phoneNumber, isTouch: $isTouch}';
  }
}
