import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  final List<String> listOfServerPhoneNumbers = ["70936314", "81503008"];
  // final List<String> listOfServerPhoneNumbers = ["70936314"];
  // final List<String> listOfServerPhoneNumbers = ["81503008"];
  double transferTax = 0.16;
  final String appName = "AlloDolar";

  late FirebaseFirestore db;
  late SharedPreferences sharedPreferences;
  List<ModelBundle> listOfBundle = [];
  final List<String> listOfCarriers = const ["Touch", "Alfa"];
  List<BottomNavigationBarItem> listOfBottomNavItems = [
    const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ""),
    const BottomNavigationBarItem(icon: Icon(Icons.history), label: ""),
    const BottomNavigationBarItem(
        icon: Icon(Icons.leaderboard_outlined), label: ""),
    const BottomNavigationBarItem(
        icon: Icon(Icons.contact_support_outlined), label: ""),
  ];
  List<BottomNavigationBarItem> listOfBottomNavItemsSever = [
    const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
  ];
  List<String> listOfHeaderInformation = [
    "Stay connected anywhere anytime. Never run out of credits again!",
    "Fast charging process. One tap and boooooomm, your charged up!",
    'Secure payment process. Payments are secured by Google!',
    "Charge for yourself and your beloved ones in the same app!",
    "You can pay with credit, debit, or even prepaid cards!"
  ];
  late String phoneNumber;
  bool isConnected = true;
  late Database databaseSqlite;
}
