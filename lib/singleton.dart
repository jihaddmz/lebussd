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
  List<ModelBundle> listOfBundle = [];
  List<BottomNavigationBarItem> listOfBottomNavItems = [
    const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
    const BottomNavigationBarItem(
        icon: Icon(Icons.contact_support_outlined), label: 'Contact Us'),
  ];
  List<BottomNavigationBarItem> listOfBottomNavItemsSever = [
    const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
  ];
  late String phoneNumber;
  bool isConnected = true;
  late Database databaseSqlite;
}
