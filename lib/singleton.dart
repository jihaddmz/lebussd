import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'models/model_bundle.dart';

class Singleton {
  static final Singleton _instance = Singleton._internal();

  factory Singleton() {
    return _instance;
  }

  Singleton._internal() {
    // initialization logic
  }

  final String serverPhoneNumber = "+96181909560";
  final double transferTax = 0.16;


  late FirebaseAuth firebaseAuth;
  late FirebaseFirestore db;
  List<ModelBundle> listOfBundle = [
    // ModelBundle(0.6, 0.5, "0xffFFCC00"),
    // ModelBundle(1.2, 1, "0xffFF3B30"),
    // ModelBundle(1.8, 1.5, "0xffFF9500"),
    // ModelBundle(2.4, 2, "0xff4CD964"),
    // ModelBundle(3, 2.5, "0xff5AC8FA"),
    // ModelBundle(3.6, 3, "0xff5856D6")
  ];
  List<BottomNavigationBarItem> listOfBottomNavItems = [
    const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
  ];
  late String phoneNumber;
  bool isConnected = true;
  late Database databaseSqlite;
}
