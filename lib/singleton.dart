import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'models/model_bundle.dart';
import 'models/model_cart.dart';

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
  List<ModelBundle> listOfBundle = [
    ModelBundle('images/img_0.5.png', 0.6, 0.5, false),
    ModelBundle('images/img_1.png', 1.2, 1, false),
    ModelBundle('images/img_1.5.png', 1.8, 1.5, false),
    ModelBundle('images/img_2.png', 2.4, 2, false),
    ModelBundle('images/img_2.5.png', 3, 2.5, false),
    ModelBundle('images/img_3.png', 3.6, 3, false)
  ];
  List<BottomNavigationBarItem> listOfBottomNavItems = [
    const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    const BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Cart'),
  ];
  late String phoneNumber;
  List<ModelCart> listOfCart = [];
  bool isConnected = true;
}
