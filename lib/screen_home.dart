import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:lebussd/HelperSharedPref.dart';
import 'package:lebussd/colors.dart';
import 'package:lebussd/helper_dialog.dart';
import 'package:lebussd/models/model_bundle.dart';
import 'package:lebussd/singleton.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ussd_service/ussd_service.dart';

import 'helpers.dart';

class ScreenHome extends StatefulWidget {
  @override
  _ScreenHome createState() => _ScreenHome();
}

class _ScreenHome extends State<ScreenHome> {
  double _availableUSSD = 0.0;
  late String? _carrier;

  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;
  late BehaviorSubject<QuerySnapshot> debouncedStream;

  _ScreenHome() {
    HelperSharedPreferences.getString("carrier").then((value) => {
          setState(() {
            _carrier = value;
          })
        });
    // if (Singleton().firebaseAuth.currentUser!.phoneNumber ==
    //     Singleton().serverPhoneNubmer) {
    if (false) {
      // it is the server phone number
      checkUSSD();
      listen();
    } else {
      fetchIfAppIsForcedDisable();
      fetchNumberOfUSSD();
    }
  }

  /// method for client
  /// in firestore there is a field responsible for disabling the app for client, incase there is something wrong,
  /// so listening for changes in this field (enableApp)
  ///
  void fetchIfAppIsForcedDisable() {
    var before = true;
    final collRef = Singleton().db.collection("app");
    collRef.snapshots().delay(const Duration(seconds: 2)).listen((event) async {
      if (event.docs[0].get('enableApp') == false) {
        HelperDialog().showDialogInfo(
            "Attention!",
            "Sorry something is wrong, were working on solving it, please stand by!!",
            context,
            false,
            () {});
        before = false;
      } else {
        if (before == false) {
          Navigator.pop(context);
        }
      }
    }, onError: (error) => print("Listen failed: $error"));
  }

  /// method for server
  /// checking the on device available ussd and set it to firestore, so the client can fetch it
  ///
  void checkUSSD() async {
    int subscriptionId = 1; // sim card subscription ID
    String code = "*220#"; // ussd code payload
    try {
      String ussdResponseMessage = await UssdService.makeRequest(
        subscriptionId,
        code,
        Duration(seconds: 10), // timeout (optional) - default is 10 seconds
      );
      String onDeviceUSSD = ussdResponseMessage.split(" ")[1];
      Singleton()
          .db
          .collection("app")
          .doc("ussd_options")
          .set({'available_ussd': onDeviceUSSD}, SetOptions(merge: true));

      setState(() {
        _availableUSSD = double.parse(onDeviceUSSD);
      });
    } catch (e) {}
  }

  /// method for client side
  /// auto fetch the number of available ussd in the server phone, and set it to the variable _availableussd
  ///
  void fetchNumberOfUSSD() async {
    Singleton()
        .db
        .collection("app")
        .doc('ussd_options')
        .snapshots()
        .listen((event) {
      event.data()!.entries.forEach((element) {
        if (element.key == "available_ussd") {
          setState(() {
            _availableUSSD = double.parse(element.value);
          });
        }
      });
    });
  }

  /// method for server phone
  /// this method is for the server phone that will listen to insertion to docs in firestore in order to
  /// send ussd charge for the user
  ///
  void listen() async {
    Future.delayed(const Duration(seconds: 1), () {
      final collRef = Singleton().db.collection("requests");
      collRef.get().then((value) async {
        if (value.docs.isNotEmpty) {
          _sendSMS(
              message:
                  "${value.docs[0].get("phoneNumber")}t${value.docs[0].get("bundle")}",
              recipients: const ["1199"],
              whenComplete: () async {
                checkUSSD();
                await Singleton().db.runTransaction((transaction) async {
                  transaction.delete(value.docs[0].reference);
                }).then((value) => {listen()});
              },
              whenError: () {
                listen();
              });
          Helpers.logD("data ${value.docs[0].get("phoneNumber")}");
        } else {
          listen();
        }
      }, onError: (e) {
        Helpers.logD("error furestore $e");
        listen();
      });
    });
  }

  /// method for client
  /// executed on pay btn click, send bundle charge request to the server phone through firebase
  ///
  void sendChargeRequest(ModelBundle modelBundle) {
    Map<String, dynamic> data = HashMap();
    data["phoneNumber"] = 76815643;
    data["bundle"] = modelBundle.bundle;
    var collRef = Singleton().db.collection("requests");
    collRef.doc().set(data, SetOptions(merge: true));
  }

  /// method for server
  /// charging the client by sending a message to the client phone number ex: 76815643t1
  ///
  void _sendSMS(
      {required String message,
      required List<String> recipients,
      required Function whenComplete,
      required Function whenError}) async {
    String _result = await sendSMS(
            message: message, recipients: recipients, sendDirect: true)
        .catchError((onError) {
      whenError();
    }).whenComplete(() {
      whenComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    Helpers.logD("value ${_carrier}");
    return Scaffold(
        appBar: AppBar(
            leading: const Icon(Icons.store),
            title: Text('LebUSSD',
                style: Theme.of(context).textTheme.displayLarge)),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: primaryColor,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        FractionallySizedBox(
                            widthFactor: 0.8,
                            alignment: AlignmentDirectional.centerStart,
                            child: Padding(
                                padding: const EdgeInsets.only(right: 80),
                                child: Text(
                                  'Available USSD: $_availableUSSD',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .displayMedium!
                                          .fontSize),
                                ))),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(300),
                                child: const Image(
                                  image: AssetImage('images/img_home.png'),
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.fitWidth,
                                )),
                          ),
                        )
                      ],
                    ),
                  ),
                  Visibility(
                      visible: _carrier == "Alpha",
                      child: const Text(
                        "Alpha devices is currently not supported, but it will be soon. Stay tuned!",
                        style: TextStyle(color: Colors.grey),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Text(
                      'USSD Bundles:',
                      style: Theme.of(context).textTheme.labelMedium,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        item(Singleton().listOfBundle[0]),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: item(Singleton().listOfBundle[1]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: item(Singleton().listOfBundle[2]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: item(Singleton().listOfBundle[3]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: item(Singleton().listOfBundle[4]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: item(Singleton().listOfBundle[5]),
                        ),
                      ],
                    ),
                  )
                ],
              )),
        ));
  }

  Widget item(ModelBundle modelBundle) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: secondaryColor),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image(
                  image: AssetImage(modelBundle.imagePath),
                  fit: BoxFit.fill,
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Text('USSD Bundle: ${modelBundle.bundle}')),
            ElevatedButton(
              onPressed: () async {
                if (_carrier == "Alpha") return;
                if (Singleton().isConnected) {
                  if (await Helpers.requestPermissions(context)) {
                    if (modelBundle.bundle <= _availableUSSD + 0.16) {
                      sendChargeRequest(modelBundle);
                      // todo card can be charged
                    } else {
                      // there is no enough credits to charge
                      if (context.mounted) {
                        HelperDialog().showDialogInfo(
                            "Attention!",
                            "There is no enough USSDs, please try again later, or try lower bundles.",
                            context,
                            true, () {
                          Navigator.pop(context);
                        });
                      }
                    }
                  } else {
                    // no network access found
                    if (context.mounted) {
                      HelperDialog().showDialogInfo(
                          "Attention!",
                          "You don't have network access, please try again when you have network access.",
                          context,
                          true, () {
                        Navigator.pop(context);
                      });
                    }
                  }
                }
              },
              style: _carrier == "Touch"
                  ? ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(primaryColor),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                          ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(50))),
                      minimumSize: MaterialStateProperty.all<Size>(
                          Size(MediaQuery.of(context).size.width - 50, 50)),
                    )
                  : ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.black),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(secondaryColor),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                          ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(50))),
                      minimumSize: MaterialStateProperty.all<Size>(
                          Size(MediaQuery.of(context).size.width - 50, 50)),
                    ),
              child: Text(
                "Pay \$${modelBundle.price} + \$0.16 Transfer Fee",
                style: const TextStyle(fontSize: 15),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    subscription.cancel();
    debouncedStream.close();
    super.dispose();
  }
}
