class ModelPurchaseHistory {
  final int id;
  final double bundle;
  final double price;
  final String date;

  const ModelPurchaseHistory(
      {required this.id,
      required this.bundle,
      required this.price,
      required this.date});

  Map<String, dynamic> toMap(int id) {
    return {'id': id, 'bundle': bundle, 'price': price, 'date': date};
  }

  @override
  String toString() {
    return 'ModelPurchaseHistory{id: $id, bundle: $bundle, price: $price, date: $date}';
  }
}
