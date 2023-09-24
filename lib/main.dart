import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lebussd/HelperSharedPref.dart';
import 'package:lebussd/helepr_purchases.dart';
import 'package:lebussd/screen_home.dart';
import 'package:lebussd/screen_welcome.dart';
import 'package:lebussd/singleton.dart';
import 'package:lebussd/sqlite_actions.dart';
import 'package:path/path.dart';
import 'package:path_provider_android/path_provider_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'firebase_options.dart';

bool isUserSignedIn() {
  return HelperSharedPreferences.getString("phone_number").isNotEmpty;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Singleton().sharedPreferences = await SharedPreferences.getInstance();
  Singleton().db = FirebaseFirestore.instance;
  HelpersPurchases().initPlatformState();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyApp createState() {
    return _MyApp();
  }
}

class _MyApp extends State<MyApp> {
  Key _key = UniqueKey();

  _MyApp() {
    if (Platform.isAndroid) PathProviderAndroid.registerWith();
    createDatabase();
    checkNetwork();
  }

  Future<void> createDatabase() async {
    await openDatabase(
            // Set the path to the database. Note: Using the `join` function from the
            // `path` package is best practice to ensure the path is correctly
            // constructed for each platform.
            join(await getDatabasesPath(), 'db_app.db'),
            onCreate: (db, version) async {
      await SqliteActions().createPurchaseHistoryTable(db);
    }, version: 1)
        .then((value) {
      Singleton().databaseSqlite = value;
    });
  }

  void checkNetwork() async {
    await Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1), () {
        // Create ping object with desired args
        final ping = Ping('google.com', count: 1);

        // Begin ping process and listen for output
        ping.stream.listen((event) {
          if (event.summary != null) {
            if (event.summary!.received == 1) {
              Singleton().isConnected = true;
            } else {
              Singleton().isConnected = false;
            }
          } else {
            Singleton().isConnected = false;
          }
        });
      });

      return true;
    });
  }

  Future<void> waitToRestartApp() async {
    await Future.delayed(const Duration(seconds: 5), () {
      Singleton().db.collection("app").doc("options").get().then((value) async {
        if (value.get("restartApp")) {
          setState(() {
            _key = UniqueKey();
          });
        }
      }).onError((error, stackTrace) {});
    });

    waitToRestartApp();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
        key: _key,
        child: MaterialApp(
            title: 'LebUSSD',
            theme: ThemeData(
              colorScheme: const ColorScheme(
                  brightness: Brightness.dark,
                  primary: Color.fromARGB(255, 37, 132, 241),
                  onPrimary: Colors.white,
                  secondary: Colors.grey,
                  onSecondary: Color.fromARGB(100, 37, 132, 241),
                  error: Color.fromARGB(160, 167, 7, 7),
                  onError: Colors.white,
                  background: Color.fromARGB(255, 255, 255, 255),
                  onBackground: Colors.black,
                  surface: Color.fromARGB(255, 255, 255, 255),
                  onSurface: Colors.black),
              textTheme: const TextTheme(
                displayLarge:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                displayMedium: TextStyle(fontSize: 18, color: Colors.grey),
                displaySmall: TextStyle(fontSize: 14),
                labelLarge:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                labelMedium:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              // fontFamily: 'Poppins',
              fontFamily: 'Brandmark1 Bold',
              useMaterial3: true,
            ),
            home: isUserSignedIn()
                ? ScreenHome(
                    callbackForWaitToRestart: () {
                      waitToRestartApp();
                    },
                  )
                : ScreenWelcome()));
  }
}
