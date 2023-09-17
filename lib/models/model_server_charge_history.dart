class ModelServerChargeHistory {
  final int id;
  final double bundle;
  final String phoneNumber;
  final String date;
  final int isTouch;

  ModelServerChargeHistory(this.id, this.bundle, this.phoneNumber, this.isTouch, this.date);

  Map<String, dynamic> toMap(int id) {
    return {
      'id': id,
      'bundle': bundle,
      'phoneNumber': phoneNumber,
      'date': date,
      'isTouch': isTouch
    };
  }
}