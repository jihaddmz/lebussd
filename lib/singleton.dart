import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'models/model_bundle.dart';

class Singleton {
  static final Singleton _instance = Singleton._internal();

  factory Singleton() {
    return _instance;
  }

  Singleton._internal() {
    // initialization logic
  }

  late FirebaseAuth firebaseAuth;
  late FirebaseFirestore db;
  String serverPhoneNubmer = "+96181909560";
  // List<ModelBundle> listOfBundle = [
  //   ModelBundle('images/img_0.5.png', 0.6, 0.5, Colors.grey),
  //   ModelBundle('images/img_1.png', 1.2, 1, Colors.green),
  //   ModelBundle('images/img_1.5.png', 1.8, 1.5, Colors.amber),
  //   ModelBundle('images/img_2.png', 2.4, 2, Colors.deepOrange),
  //   ModelBundle('images/img_2.5.png', 3, 2.5, Colors.deepPurpleAccent),
  //   ModelBundle('images/img_3.png', 3.6, 3, Colors.pinkAccent)
  // ];
  List<ModelBundle> listOfBundle = [
    ModelBundle('images/img_0.5.png', 0.6, 0.5, Color.fromRGBO(49, 0, 61, 1.0)),
    ModelBundle('images/img_1.png', 1.2, 1, Color.fromRGBO(53, 4, 85, 1.0)),
    ModelBundle('images/img_1.5.png', 1.8, 1.5, Color.fromRGBO(42, 8, 92, 1.0)),
    ModelBundle('images/img_2.png', 2.4, 2, Color.fromRGBO(32, 12, 100, 1.0)),
    ModelBundle('images/img_2.5.png', 3, 2.5, Color.fromRGBO(21, 16, 107, 1.0)),
    ModelBundle('images/img_3.png', 3.6, 3, Color.fromRGBO(11, 20, 115, 1.0))
  ];
  late String phoneNumber;
  bool isConnected = true;
}
