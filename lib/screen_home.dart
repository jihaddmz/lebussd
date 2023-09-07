import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:lebussd/HelperSharedPref.dart';
import 'package:lebussd/colors.dart';
import 'package:lebussd/components/item_recharge_card.dart';
import 'package:lebussd/helper_dialog.dart';
import 'package:lebussd/models/model_bundle.dart';
import 'package:lebussd/models/model_purchase_history.dart';
import 'package:lebussd/screen_purchasehistory.dart';
import 'package:lebussd/screen_welcome.dart';
import 'package:lebussd/singleton.dart';
import 'package:lebussd/sqlite_actions.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ussd_service/ussd_service.dart';

import 'helepr_purchases.dart';
import 'helpers.dart';

class ScreenHome extends StatefulWidget {
  @override
  _ScreenHome createState() => _ScreenHome();
}

class _ScreenHome extends State<ScreenHome> {
  double _availableUSSD = 0.0;
  String _carrier = "Touch";
  String _error = "";
  int _selectedIndex = 0;
  List<int> _listOfInts = [1];
  TextEditingController _controllerOtherPhoneNumber = TextEditingController();
  List<ModelBundle> _listOfBundle = [];
  late List<Package> listOfPackages;

  _ScreenHome() {
    if (!isClientPhone()) {
      // if (false) {
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
  void checkUSSD(
      {Function(String)? onResponseResult, Function? onResponseError}) async {
    int subscriptionId = 1; // sim card subscription ID
    String code = "*220#"; // ussd code payload
    try {
      String ussdResponseMessage = await UssdService.makeRequest(
        subscriptionId,
        code,
        const Duration(
            seconds: 10), // timeout (optional) - default is 10 seconds
      );
      if (onResponseResult != null) onResponseResult(ussdResponseMessage);
      String onDeviceUSSD = ussdResponseMessage.split(" ")[1];
      Singleton()
          .db
          .collection("app")
          .doc("ussd_options")
          .set({'available_ussd': onDeviceUSSD}, SetOptions(merge: true));

      setState(() {
        _availableUSSD = double.parse(onDeviceUSSD);
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      if (onResponseError != null) onResponseError();
    }
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
    Future.delayed(const Duration(seconds: 5), () {
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
              whenError: (onError) {
                setState(() {
                  _error = onError.toString();
                });
                listen();
              });
        } else {
          listen();
        }
      }, onError: (e) {
        setState(() {
          _error = e.toString();
        });
        listen();
      });
    });
  }

  /// method for client
  /// executed on pay btn click, send bundle charge request to the server phone through firebase
  ///
  void sendChargeRequest(
      ModelBundle modelBundle, int phoneNumber, Function whenComplete) {
    Map<String, dynamic> data = HashMap();
    data["phoneNumber"] = phoneNumber;
    data["bundle"] = modelBundle.bundle;
    var collRef = Singleton().db.collection("requests");
    collRef
        .doc()
        .set(data, SetOptions(merge: true))
        .whenComplete(() => whenComplete());
  }

  /// method for server
  /// charging the client by sending a message to the client phone number ex: 76815643t1
  ///
  void _sendSMS(
      {required String message,
      required List<String> recipients,
      required Function whenComplete,
      required Function(dynamic) whenError}) async {
    String _result = await sendSMS(
            message: message, recipients: recipients, sendDirect: true)
        .catchError((onError) {
      whenError(onError);
    }).whenComplete(() {
      whenComplete();
    });
  }

  ///
  /// method to check if this device is a client or the server phone
  ///
  bool isClientPhone() {
    // return Singleton().firebaseAuth.currentUser!.phoneNumber !=
    //     Singleton().serverPhoneNumber;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    HelperSharedPreferences.getString("carrier").then((value) => {
          setState(() {
            _carrier = value ?? "";
          })
        });

    HelpersPurchases().setProducts(onOfferingsGetComplete: (offering) {
      listOfPackages = offering.availablePackages;
      setState(() {
        _listOfBundle = [
          ModelBundle(offering.getPackage("ussd_0.5")!.storeProduct.price, 0.5,
              "0xffFFCC00"),
          ModelBundle(offering.getPackage("ussd_1")!.storeProduct.price, 1,
              "0xffFF3B30"),
          ModelBundle(offering.getPackage("ussd_1.5")!.storeProduct.price, 1.5,
              "0xffFF9500"),
          ModelBundle(offering.getPackage("ussd_2")!.storeProduct.price, 2,
              "0xff4CD964"),
          ModelBundle(offering.getPackage("ussd_2.5")!.storeProduct.price, 2.5,
              "0xff5AC8FA"),
          ModelBundle(offering.getPackage("ussd_3")!.storeProduct.price, 3,
              "0xff5856D6"),
        ];
      });
    });

    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              if (_selectedIndex != index) {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  if (index == 0) {
                    return ScreenHome();
                  } else {
                    return ScreenPurchaseHistory();
                  }
                }));
              }
            });
          },
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.black,
          items: Singleton().listOfBottomNavItems,
          currentIndex: _selectedIndex,
        ),
        appBar: AppBar(
          leading: const Icon(Icons.store),
          title:
              Text('LebUSSD', style: Theme.of(context).textTheme.displayLarge),
          actions: [
            IconButton(
                onPressed: () {
                  HelperDialog().showDialogAffirmation(
                      context, "Attention", "Are you sure you want to logout?",
                      () {
                    Singleton().firebaseAuth.signOut();
                    Navigator.pop(context);
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => ScreenWelcome()),
                        (route) => false);
                  }, () {
                    Navigator.pop(context);
                  });
                },
                icon: const Icon(Icons.logout)),
          ],
        ),
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
                                child: GestureDetector(
                                  onTap: () async {
                                    if (await Helpers.requestPhonePermission(
                                        context)) {
                                      if (context.mounted) {
                                        HelperDialog()
                                            .showLoaderDialog(context);
                                        checkUSSD(onResponseResult: (result) {
                                          Navigator.pop(context);
                                          HelperDialog().showDialogInfo(
                                              null, result, context, true, () {
                                            Navigator.pop(context);
                                          });
                                        }, onResponseError: () {
                                          Navigator.pop(context);
                                        });
                                      }
                                    }
                                  },
                                  child: Text(
                                    'Check Balance',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.white,
                                        color: Colors.white,
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .fontSize),
                                  ),
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
                      visible: _carrier != "Touch",
                      child: const Text(
                        "Alpha devices is currently not supported, but it will be soon. Stay tuned!",
                        style: TextStyle(color: Colors.grey),
                      )),
                  Visibility(
                      visible: !isClientPhone(),
                      child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: Center(
                              child: Text(
                            _error,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayLarge,
                          )))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text("For Me"),
                          Checkbox(
                              value: _listOfInts.contains(1),
                              onChanged: (value) {
                                setState(() {
                                  _listOfInts.removeLast();
                                  _listOfInts.add(1);
                                });
                              }),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("For Other"),
                          Checkbox(
                              value: _listOfInts.contains(2),
                              onChanged: (value) {
                                setState(() {
                                  _listOfInts.removeLast();
                                  _listOfInts.add(2);
                                });
                              })
                        ],
                      )
                    ],
                  ),
                  Visibility(
                    visible: _listOfInts.contains(2),
                    maintainAnimation: true,
                    maintainState: true,
                    child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.fastOutSlowIn,
                        opacity: _listOfInts.contains(2) ? 1 : 0,
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              enabled: _listOfInts.contains(2),
                              controller: _controllerOtherPhoneNumber,
                              decoration: const InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1,
                                          color: Colors.grey,
                                          style: BorderStyle.solid),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  labelText: 'Phone Number ex 81909560',
                                  helperText:
                                      "Phone number you wish to charge for.",
                                  labelStyle: TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                  helperStyle: TextStyle(
                                      color: Colors.grey, fontSize: 13)),
                            ))),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Visibility(
                          visible: isClientPhone(),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: Text(
                              'USSD Bundles:',
                              style: Theme.of(context).textTheme.labelMedium,
                              textAlign: TextAlign.left,
                            ),
                          )),
                      Visibility(
                          visible: _listOfBundle.isEmpty,
                          child: const Padding(
                            padding: EdgeInsets.only(top: 50),
                            child: Text("Loading Cards..."),
                          ))
                    ],
                  ),
                  Visibility(
                      visible: isClientPhone(),
                      child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Visibility(
                              visible: _listOfBundle.isNotEmpty,
                              child: Column(
                                children: listOfCards(),
                              )))),
                ],
              )),
        ));
  }

  List<Widget> listOfCards() {
    List<Widget> list = [];
    for (int i = 0; i < _listOfBundle.length; i++) {
      list.add(Padding(
        padding: const EdgeInsets.only(top: 30),
        child: item(_listOfBundle[i]),
      ));
    }
    return list;
  }

  Widget item(ModelBundle modelBundle) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: secondaryColor),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            itemRechargeCard(modelBundle),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Text('USSD Bundle: ${modelBundle.bundle}')),
            ElevatedButton(
              onPressed: () async {
                if (_carrier != "Touch") return;
                // if (await Helpers.requestSMSPermission(context)) {
                if (Singleton().isConnected) {
                  // there is network access
                  if (modelBundle.bundle <= _availableUSSD + 0.16) {
                    // this bundle can be charged, there is enough credits
                    if (_listOfInts.contains(2)) {
                      // user is charging for other phone number
                      if (_controllerOtherPhoneNumber.text.trim().isEmpty) {
                        // other phone number is not empty
                        if (context.mounted) {
                          HelperDialog().showDialogInfo(
                              "Attention!",
                              "Please enter the phone number you wish to charge for",
                              context,
                              true, () {
                            Navigator.pop(context);
                          });
                        }
                      } else {
                        for (var package in listOfPackages) {
                          if (package.identifier ==
                              "ussd_${modelBundle.bundle}") {
                            Purchases.purchasePackage(package).then((value) {
                              // payment is successful
                              DateTime now = DateTime.now();
                              String date =
                                  "${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}";
                              SqliteActions().insertPurchaseHistory(
                                  ModelPurchaseHistory(
                                      id: 0,
                                      bundle: modelBundle.bundle,
                                      price: modelBundle.price,
                                      date: date,
                                      color: modelBundle.color));
                              sendChargeRequest(modelBundle,
                                  int.parse(_controllerOtherPhoneNumber.text),
                                  () {
                                if (context.mounted) {
                                  HelperDialog().showDialogInfo(
                                      "Success!",
                                      "Bundle has been charged to the desired phone number",
                                      context,
                                      true, () {
                                    Navigator.pop(context);
                                  });
                                }
                              });
                            }).onError((error, stackTrace) {
                              // Payment failed
                              HelperDialog().showDialogInfo(
                                  "Warning!",
                                  "Purchase failed, make sure you entered the correct card details and you have enough money!",
                                  context,
                                  true, () {
                                Navigator.pop(context);
                              });
                            });
                            return;
                          }
                        }
                      }
                    } else {
                      // charging for current phone number
                      for (var package in listOfPackages) {
                        if (package.identifier ==
                            "ussd_${modelBundle.bundle}") {
                          Purchases.purchasePackage(package).then((value) {
                            DateTime now = DateTime.now();
                            String date =
                                "${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}";
                            SqliteActions().insertPurchaseHistory(
                                ModelPurchaseHistory(
                                    id: 0,
                                    bundle: modelBundle.bundle,
                                    price: modelBundle.price,
                                    date: date,
                                    color: modelBundle.color));
                            sendChargeRequest(
                                modelBundle,
                                int.parse(Singleton()
                                    .firebaseAuth
                                    .currentUser!
                                    .phoneNumber!
                                    .replaceFirst("+961", "")), () {
                              if (context.mounted) {
                                HelperDialog().showDialogInfo(
                                    "Success!",
                                    "Bundle has been charged to your phone number",
                                    context,
                                    true, () {
                                  Navigator.pop(context);
                                });
                              }
                            });
                          }).onError((error, stackTrace) {
                            HelperDialog().showDialogInfo(
                                "Warning!",
                                "Purchase failed, make sure you entered the correct card details and you have enough money!",
                                context,
                                true, () {
                              Navigator.pop(context);
                            });
                          });
                          return;
                        }
                      }
                    }
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
                // }
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
    super.dispose();
  }
}
