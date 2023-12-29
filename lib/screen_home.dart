import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lebussd/HelperSharedPref.dart';
import 'package:lebussd/colors.dart';
import 'package:lebussd/components/item_recharge_card.dart';
import 'package:lebussd/components/item_server_recharge_card.dart';
import 'package:lebussd/helper_dialog.dart';
import 'package:lebussd/models/model_bundle.dart';
import 'package:lebussd/models/model_purchase_history.dart';
import 'package:lebussd/screen_contactus.dart';
import 'package:lebussd/screen_purchasehistory.dart';
import 'package:lebussd/screen_welcome.dart';
import 'package:lebussd/singleton.dart';
import 'package:lebussd/sqlite_actions.dart';
import 'package:lottie/lottie.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ussd_advanced/ussd_advanced.dart';
import 'package:ussd_service/ussd_service.dart';

import 'helepr_purchases.dart';
import 'helpers.dart';
import 'models/model_server_charge_history.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({required this.callbackForWaitToRestart});

  final Function callbackForWaitToRestart;

  @override
  _ScreenHome createState() => _ScreenHome();
}

class _ScreenHome extends State<ScreenHome> {
  String _carrier = "Touch";
  String _error =
      ""; // error happened on the server phone during charging for the client
  final int _selectedIndex = 0;
  bool _isChargingForOther = false;
  final TextEditingController _controllerOtherPhoneNumber =
      TextEditingController();
  String _otherCarrier = "Touch";
  List<ModelBundle> _listOfBundle = [];
  late List<Package> listOfPackages;
  String? _errorText;
  String _textHeader = '';
  List<ModelServerChargeHistory> _listOfServerChargeHistory = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _carrier = HelperSharedPreferences.getString("carrier");
    });

    if (!isClientPhone()) {
      // it is the server phone number
      requestServerPhonePermissions();
      // checkUSSD();
      listen();
      removeLast10ServerChargeHistory();
      // waitToCheckBalance();
      widget.callbackForWaitToRestart();
    } else {
      setState(() {
        _textHeader = Singleton().listOfHeaderInformation[0];
      });
      pickRandomHeaderText();
      fetchIfAppIsForcedDisable();
      Future.delayed(const Duration(seconds: 2), () {
        Helpers.requestOneSignalPermission();
      });
    }
  }

  requestServerPhonePermissions() async {
    Future.delayed(const Duration(seconds: 2), () {
      Helpers.requestPhonePermission(context).then((value) {
        if (value) {
          Helpers.requestSMSPermission(context);
        }
      });
    });
  }

  waitToCheckBalance() async {
    await Future.delayed(const Duration(seconds: 2), () {
      Singleton()
          .db
          .collection("app")
          .doc("ussd_options")
          .get()
          .then((value) async {
        if (value.get("checkBalance")) {
          checkUSSD(onResponseResult: (value) {}, onResponseError: () {});
        }
      }).onError((error, stackTrace) {});
    });

    waitToCheckBalance();
  }

  fetchServerChargesHistory() async {
    await SqliteActions().getAllServerChargeHistory().then((value) {
      setState(() {
        _listOfServerChargeHistory = value;
      });
    });
  }

  removeLast10ServerChargeHistory() async {
    await Future.delayed(const Duration(minutes: 20), () {
      if (_listOfServerChargeHistory.length > 10) {
        SqliteActions().deleteLast10ServerChargeHistory();
        setState(() {
          _listOfServerChargeHistory.reversed.toList().removeRange(0, 10);
        });
      }
    });

    removeLast10ServerChargeHistory();
  }

  int counter = 0;

  pickRandomHeaderText() async {
    await Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _textHeader = Singleton().listOfHeaderInformation[counter];
      });
      counter++;
      if (counter == Singleton().listOfHeaderInformation.length) {
        counter = 0;
      }
    });

    pickRandomHeaderText();
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
    }, onError: (error) => {});
  }

  /// method for server
  /// checking the on device available ussd and set it to firestore, so the client can fetch it
  ///
  Future<void> checkUSSD(
      {Function(String)? onResponseResult, Function? onResponseError}) async {
    int subscriptionId = 1; // sim card subscription ID
    String code = "*220#"; // ussd code payload
    String firebaseAvailableUSSDField = "available_ussd";
    if (_carrier == "Alfa") {
      code = "*11#";
      firebaseAvailableUSSDField = "available_ussd_alfa";
    }
    try {
      String? ussdResponseMessage;
      if (Platform.isAndroid) {
        ussdResponseMessage = await UssdService.makeRequest(
          subscriptionId,
          code,
          const Duration(
              seconds: 60), // timeout (optional) - default is 10 seconds
        );
      } else {
        ussdResponseMessage =
            await UssdAdvanced.sendAdvancedUssd(code: code, subscriptionId: -1);
      }

      if (ussdResponseMessage != null) {
        if (onResponseResult != null) onResponseResult(ussdResponseMessage);
        String onDeviceUSSD;
        if (!isClientPhone()) {
          if (_carrier == "Alfa") {
            onDeviceUSSD = ussdResponseMessage
                .split(" ")[0]
                .trim()
                .replaceFirst("\$", "")
                .trim();
          } else {
            onDeviceUSSD = ussdResponseMessage.split(" ")[1].trim();
          }
          Singleton().db.collection("app").doc("ussd_options").set(
              {firebaseAvailableUSSDField: onDeviceUSSD},
              SetOptions(merge: true));
        }
      }
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
  Future<void> fetchNumberOfUSSD(Function(double) onResult) async {
    String firebaseAvailableUSSDField = "available_ussd";
    if (_isChargingForOther) {
      if (_otherCarrier == "Alfa") {
        firebaseAvailableUSSDField = "available_ussd_alfa";
      }
    } else if (_carrier == "Alfa") {
      firebaseAvailableUSSDField = "available_ussd_alfa";
    }

    await Singleton()
        .db
        .collection("app")
        .doc('ussd_options')
        .get()
        .then((value) {
      onResult(double.parse(value.get(firebaseAvailableUSSDField)));
    });
  }

  /// method for server phone
  /// this method is for the server phone that will listen to insertion to docs in firestore in order to
  /// send ussd charge for the user
  ///
  Future<void> listen() async {
    await Future.delayed(const Duration(seconds: 8), () async {
      final collRef = Singleton()
          .db
          .collection(_carrier == "Touch" ? "requests" : "requestsAlfa");
      await collRef.get().then((collection) async {
        if (collection.docs.isNotEmpty) {
          setState(() {
            _error = "";
          });

          await _sendSMS(
              message:
                  "${collection.docs[0].get("phoneNumber")}t${collection.docs[0].get("bundle")}",
              recipients: [_carrier == "Touch" ? "1199" : "1313"],
              whenComplete: () async {
                await Singleton().db.runTransaction((transaction) async {
                  transaction.delete(collection.docs[0].reference);
                }).then((value) async {
                  await checkUSSD();
                  ModelServerChargeHistory modelServerChargeHistory =
                      ModelServerChargeHistory(
                          0,
                          double.parse(collection.docs[0].get("bundle")),
                          collection.docs[0].get("phoneNumber").toString(),
                          _carrier == "Touch" ? 1 : 0,
                          collection.docs[0].get("date").toString());
                  await SqliteActions()
                      .insertServerChargeHistory(modelServerChargeHistory)
                      .onError((error, stackTrace) {});
                  setState(() {
                    _listOfServerChargeHistory.insert(
                        0, modelServerChargeHistory);
                  });
                  listen();
                });
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
      }).catchError((error) {
        setState(() {
          _error = error.toString();
        });
        listen();
      });
    });
  }

  /// method for client
  /// executed on pay btn click, send bundle charge request to the server phone through firebase
  ///
  void sendChargeRequest(String chargingDate, ModelBundle modelBundle,
      int phoneNumber, Function whenComplete) {
    Map<String, dynamic> data = HashMap();
    data["phoneNumber"] = phoneNumber;
    data["bundle"] = modelBundle.bundle.toString().replaceFirst(".0", "");
    data["date"] = chargingDate;
    var collRef = Singleton()
        .db
        .collection(modelBundle.isTouch == 1 ? "requests" : "requestsAlfa");
    collRef
        .doc()
        .set(data, SetOptions(merge: true))
        .whenComplete(() => whenComplete());
  }

  /// method for server
  /// charging the client by sending a message to the client phone number ex: 76815643t1
  ///
  Future<void> _sendSMS(
      {required String message,
      required List<String> recipients,
      required Function whenComplete,
      required Function(dynamic) whenError}) async {
    await sendSMS(message: message, recipients: recipients, sendDirect: true)
        .catchError((onError) {
      whenError(onError);
    }).then((value) {
      whenComplete();
    });
  }

  ///
  /// method to check if this device is a client or the server phone
  ///
  bool isClientPhone() {
    for (var number in Singleton().listOfServerPhoneNumbers) {
      if (HelperSharedPreferences.getString("phone_number") == number) {
        return false;
      }
    }

    return true;
  }

  List<Widget> itemsOfServerChargeHistory() {
    List<Widget> listOfServerChargeHistory = [];
    for (var item in _listOfServerChargeHistory) {
      listOfServerChargeHistory.add(itemServerRechargeCard(item));
    }
    return listOfServerChargeHistory;
  }

  ///
  /// method to fetch touch or alfa bundles
  ///
  fetchBundlesFromRevenueCat() async {
    bool isTouch;
    if (_isChargingForOther) {
      if (_otherCarrier == "Touch") {
        isTouch = true;
      } else {
        isTouch = false;
      }
    } else {
      if (_carrier == "Touch") {
        isTouch = true;
      } else {
        isTouch = false;
      }
    }
    HelpersPurchases().setProducts(
        isTouch: isTouch,
        onOfferingsGetComplete: (offering) {
          listOfPackages = offering.availablePackages;
          setState(() {
            _listOfBundle = [
              ModelBundle(offering.getPackage("ussd_0.5")!.storeProduct.price,
                  0.5, "0xffFFCC00", isTouch ? 1 : 0),
              ModelBundle(offering.getPackage("ussd_1")!.storeProduct.price, 1,
                  "0xffFF3B30", isTouch ? 1 : 0),
              ModelBundle(offering.getPackage("ussd_1.5")!.storeProduct.price,
                  1.5, "0xffFF9500", isTouch ? 1 : 0),
              ModelBundle(offering.getPackage("ussd_2")!.storeProduct.price, 2,
                  "0xff4CD964", isTouch ? 1 : 0),
              ModelBundle(offering.getPackage("ussd_2.5")!.storeProduct.price,
                  2.5, "0xff5AC8FA", isTouch ? 1 : 0),
              ModelBundle(offering.getPackage("ussd_3")!.storeProduct.price, 3,
                  "0xff5856D6", isTouch ? 1 : 0),
            ];
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    if (isClientPhone()) {
      fetchBundlesFromRevenueCat();
    } else {
      Future.delayed(const Duration(seconds: 5), () {
        fetchServerChargesHistory();
      });
    }

    return Scaffold(
        bottomNavigationBar: isClientPhone()
            ? BottomNavigationBar(
                onTap: (index) {
                  setState(() {
                    if (_selectedIndex != index) {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                        if (index == 1) {
                          return ScreenPurchaseHistory();
                        } else {
                          return ScreenContactUs();
                        }
                      }));
                    }
                  });
                },
                selectedItemColor: primaryColor,
                unselectedItemColor: Colors.black,
                items: Singleton().listOfBottomNavItems,
                currentIndex: _selectedIndex,
              )
            : null,
        appBar: AppBar(
          leading: const Image(image: AssetImage("images/logo.png")),
          title: Text(Singleton().appName,
              style: Theme.of(context).textTheme.displayLarge),
          actions: [
            IconButton(
                onPressed: () async {
                  if (Platform.isAndroid) {
                    if (await Helpers.requestPhonePermission(context)) {
                      if (context.mounted) {
                        HelperDialog().showLoaderDialog(context);
                        checkUSSD(onResponseResult: (result) {
                          Navigator.pop(context);
                          HelperDialog()
                              .showDialogInfo(null, result, context, true, () {
                            Navigator.pop(context);
                          });
                        }, onResponseError: () {
                          Navigator.pop(context);
                        });
                      }
                    }
                  } else {
                    checkUSSD(
                        onResponseError: () {}, onResponseResult: (result) {});
                  }
                },
                icon: const Icon(Icons.balance_outlined)),
            IconButton(
                onPressed: () {
                  HelperDialog().showDialogAffirmation(context, "Attention!",
                      "Are you sure you want to sign out?", () {
                    HelperSharedPreferences.setString("phone_number", "")
                        .then((value) {
                      Navigator.pop(context);
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => ScreenWelcome()),
                          (route) => false);
                    });
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
                  Visibility(
                      visible: !isClientPhone(),
                      child: Column(
                        children: itemsOfServerChargeHistory(),
                      )),
                  // Load a Lottie file from your assets
                  Visibility(
                      visible: _listOfBundle.isEmpty && isClientPhone(),
                      child:
                          Lottie.asset('assets/loading.json', animate: true)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                          visible: isClientPhone(),
                          child: Card(
                              child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 30),
                            child: Container(
                              alignment: Alignment.center,
                              child: AnimatedTextKit(
                                animatedTexts: [
                                  TyperAnimatedText(
                                    _textHeader,
                                    textAlign: TextAlign.center,
                                    textStyle: GoogleFonts.croissantOne(),
                                  )
                                ],
                                totalRepeatCount: 500,
                                pause: const Duration(seconds: 5),
                              ),
                            ),
                          ))),
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
                      Visibility(
                          visible: isClientPhone(),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Text("For Me"),
                                      Checkbox(
                                          value: !_isChargingForOther,
                                          onChanged: (value) {
                                            setState(() {
                                              _isChargingForOther = false;
                                            });
                                          }),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text("For Other"),
                                      Checkbox(
                                          value: _isChargingForOther,
                                          onChanged: (value) {
                                            setState(() {
                                              _isChargingForOther = true;
                                            });
                                          })
                                    ],
                                  )
                                ],
                              ),
                              Visibility(
                                visible: _isChargingForOther,
                                maintainAnimation: true,
                                maintainState: true,
                                child: Column(
                                  children: [
                                    AnimatedOpacity(
                                        duration:
                                            const Duration(milliseconds: 1000),
                                        curve: Curves.fastOutSlowIn,
                                        opacity: _isChargingForOther ? 1 : 0,
                                        child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 20, 20, 0),
                                            child: TextFormField(
                                              keyboardType: TextInputType.phone,
                                              enabled: _isChargingForOther,
                                              controller:
                                                  _controllerOtherPhoneNumber,
                                              onChanged: (value) {
                                                setState(() {
                                                  _errorText = null;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                  enabledBorder:
                                                      const OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              width: 1,
                                                              color: Colors
                                                                  .grey,
                                                              style: BorderStyle
                                                                  .solid),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10))),
                                                  labelText:
                                                      'Phone Number ex 81909560',
                                                  helperText:
                                                      "Phone number you wish to charge for.",
                                                  errorText: _errorText,
                                                  suffixIcon: IconButton(
                                                      onPressed: () async {
                                                        if (await Helpers
                                                            .requestContactPermission(
                                                                context)) {
                                                          final PhoneContact
                                                              contact =
                                                              await FlutterContactPicker
                                                                  .pickPhoneContact();

                                                          setState(() {
                                                            if (contact
                                                                    .phoneNumber !=
                                                                null) {
                                                              _controllerOtherPhoneNumber
                                                                      .text =
                                                                  contact
                                                                      .phoneNumber!
                                                                      .number
                                                                      .toString()
                                                                      .replaceFirst(
                                                                          "+961",
                                                                          "")
                                                                      .replaceAll(
                                                                          " ",
                                                                          "");
                                                            }
                                                          });
                                                        }
                                                      },
                                                      icon: const Icon(
                                                          Icons.contact_phone,
                                                          color: primaryColor)),
                                                  labelStyle: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13),
                                                  helperStyle: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13)),
                                            ))),
                                    AnimatedOpacity(
                                        duration:
                                            const Duration(milliseconds: 1000),
                                        curve: Curves.fastOutSlowIn,
                                        opacity: _isChargingForOther ? 1 : 0,
                                        child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 20, 20, 0),
                                            child: DropdownButton(
                                                value: _otherCarrier,
                                                icon: const Icon(
                                                  Icons.arrow_drop_down,
                                                  color: primaryColor,
                                                ),
                                                isExpanded: true,
                                                items: Singleton()
                                                    .listOfCarriers
                                                    .map((e) {
                                                  return DropdownMenuItem(
                                                      value: e, child: Text(e));
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _otherCarrier = value!;
                                                  });
                                                })))
                                  ],
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Visibility(
                                      visible: isClientPhone(),
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 50),
                                        child: Text(
                                          'USSD Bundles:',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium,
                                          textAlign: TextAlign.left,
                                        ),
                                      )),
                                  Visibility(
                                      visible: _listOfBundle.isEmpty,
                                      child: const Padding(
                                        padding: EdgeInsets.only(top: 50),
                                        child: Text("Loading Bundles..."),
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
                                          ))))
                            ],
                          ))
                    ],
                  ),
                ],
              )),
        ));
  }

  List<Widget> listOfCards() {
    List<Widget> list = [];
    for (int i = 0; i < _listOfBundle.length; i++) {
      if (i == 0) {
        list.add(Padding(
          padding: const EdgeInsets.only(top: 10),
          child: item(_listOfBundle[i]),
        ));
      } else {
        list.add(Padding(
          padding: const EdgeInsets.only(top: 30),
          child: item(_listOfBundle[i]),
        ));
      }
    }
    return list;
  }

  void purchaseAndCharge(
      ModelBundle modelBundle, Package package, bool forOther) async {
    String phoneNumber = forOther
        ? _controllerOtherPhoneNumber.text
            .replaceFirst("+", "")
            .replaceFirst("961", "")
        : HelperSharedPreferences.getString("phone_number");

    try {
      Purchases.purchasePackage(package).then((value) {
        HelperDialog().showLoaderDialog(context);
        // payment is successful
        DateTime now = DateTime.now();
        String chargingDate =
            "${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}";
        SqliteActions().insertPurchaseHistory(ModelPurchaseHistory(
            id: 0,
            bundle: modelBundle.bundle,
            price: modelBundle.price,
            date: chargingDate,
            color: modelBundle.color,
            phoneNumber: phoneNumber,
            isTouch: modelBundle.isTouch));
        sendChargeRequest(chargingDate, modelBundle, int.parse(phoneNumber),
            () {
          if (context.mounted) {
            Navigator.pop(context);
            HelperDialog().showDialogInfo(
                "Success!",
                forOther
                    ? "Bundle has been charged to the desired phone number."
                    : "Bundle has been charged to your phone number.",
                context,
                true, () {
              Navigator.pop(context);
            },
                note:
                    "Note: If bundle hasn't been added 5 minutes by max, please contact us in the contact section, and select the Bundle option.");
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
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        // Payment failed
        HelperDialog().showDialogInfo(
            "Warning!",
            "Purchase failed, make sure you entered the correct card details and you have enough money!",
            context,
            true, () {
          Navigator.pop(context);
        });
      }
    }
  }

  Widget item(ModelBundle modelBundle) {
    if (_isChargingForOther) {
      if (_otherCarrier == "Touch") {
        Singleton().transferTax = 0.16;
      } else {
        Singleton().transferTax = 0.14;
      }
    } else {
      if (_carrier == "Touch") {
        Singleton().transferTax = 0.16;
      } else {
        Singleton().transferTax = 0.14;
      }
    }
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
                child: Text(
                  'USSD Bundle: ${modelBundle.bundle}\nNo Added Tax',
                  textAlign: TextAlign.center,
                )),
            ElevatedButton(
              onPressed: () async {
                // if (await Helpers.requestSMSPermission(context)) {
                if (Singleton().isConnected) {
                  // there is network access
                  double availableUSSD = 0.0;
                  await fetchNumberOfUSSD((p0) {
                    availableUSSD = p0;
                  });
                  if (availableUSSD > 1.3 &&
                      modelBundle.bundle + Singleton().transferTax <=
                          availableUSSD) {
                    if (_isChargingForOther) {
                      // this bundle can be charged, there is enough credits
                      // user is charging for other phone number
                      if (_controllerOtherPhoneNumber.text.trim().isEmpty) {
                        // invalid phone number empty
                        setState(() {
                          _errorText = "Invalid Phone Number!";
                        });
                      } else {
                        if (_controllerOtherPhoneNumber.text.trim().length !=
                            8) {
                          // invalid phone number, not 8 digits
                          setState(() {
                            _errorText = "Invalid Phone Number!";
                          });
                          return;
                        }
                        for (var package in listOfPackages) {
                          if (package.identifier ==
                              "ussd_${modelBundle.bundle.toString().replaceFirst(".0", "")}") {
                            modelBundle.isTouch =
                                _otherCarrier == "Touch" ? 1 : 0;
                            purchaseAndCharge(modelBundle, package, true);
                            return;
                          }
                        }
                      }
                    } else {
                      // charging for current phone number
                      for (var package in listOfPackages) {
                        if (package.identifier ==
                            "ussd_${modelBundle.bundle.toString().replaceFirst(".0", "")}") {
                          modelBundle.isTouch = _carrier == "Touch" ? 1 : 0;
                          purchaseAndCharge(modelBundle, package, false);
                          return;
                        }
                      }
                    }
                  } else {
                    // there is no enough credits to charge
                    if (context.mounted) {
                      HelperDialog().showDialogInfo(
                          "Attention!",
                          "There is something wrong on our end, we're working on it!. Please try again later.",
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
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                    ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                minimumSize: MaterialStateProperty.all<Size>(
                    Size(MediaQuery.of(context).size.width - 50, 50)),
              ),
              child: Text(
                "Pay \$${(modelBundle.price - Singleton().transferTax).toStringAsFixed(2)} + \$${Singleton().transferTax} Transfer Fee",
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
