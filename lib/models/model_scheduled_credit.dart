import 'package:cloud_firestore/cloud_firestore.dart';

class ModelScheduledCredit {
  final int id;
  final DocumentReference documentReference;
  final double bundle;
  final String phoneNumber;
  final String date;
  final int isTouch;

  ModelScheduledCredit(
      this.id, this.documentReference, this.bundle, this.phoneNumber, this.isTouch, this.date);

  Map<String, dynamic> toMap(String id) {
    return {
      'id': id,
      'bundle': bundle,
      'phoneNumber': phoneNumber,
      'date': date,
      'isTouch': isTouch
    };
  }
}
