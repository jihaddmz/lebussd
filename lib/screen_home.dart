import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
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

  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;
  late BehaviorSubject<QuerySnapshot> debouncedStream;

  _ScreenHome() {
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
            "App is disabled, please wait till the app is re-enabled!!",
            context,
            false,
            () {});
        before = false;
      } else {
        if (before == false) {
          Navigator.pop(context);
        }
      }
      Helpers.logD("${event.docs[0].get('enableApp')}");
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
  /// charge the user
  ///
  void listen() {
    try {
      debouncedStream = BehaviorSubject<QuerySnapshot>();

      final collRef = Singleton().db.collection("requests");
      subscription = collRef.snapshots().listen((event) async {
        debouncedStream.add(event);
      }, onError: (error) => print("Listen failed: $error"));

      /**using  debouncedStream so we can listen just once for the same change event*/
      debouncedStream
          .debounceTime(Duration(milliseconds: 500))
          .listen((event) async {
        if (event.docChanges.length > 0) {
          if (event.docChanges[0].type == DocumentChangeType.added) {
            if (!subscription.isPaused) {
              Helpers.logD(' phoneNumber ${event.docs[0].get('phoneNumber')}');
              _sendSMS(
                  message: "Hi",
                  recipients: [event.docs[0].get('phoneNumber')],
                  whenComplete: () async {
                    checkUSSD(); // here we re-check the ussd available in the phone and send it to firebase
                    subscription
                        .pause(); // pausing the listener so the deletion happen successfully

                    await Singleton().db.runTransaction((transaction) async {
                      transaction.delete(event.docs[0].reference);
                    }).then((value) => {subscription.resume()});
                  },
                  whenError: () {});
            }
          }
        }
      });
    } catch (e) {
      Helpers.logD("error is ${e}");
    }
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
            const Text('Excluding Taxes'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("\$${modelBundle.price}"),
                const Text(" / "),
                Text(
                  "${modelBundle.bundle}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
            ElevatedButton(
              onPressed: () {
                if (Singleton().isConnected) {
                  if (modelBundle.bundle <= _availableUSSD + 0.16) {
                    // todo card can be charged
                  } else {
                    // there is no enough credits to charge
                    HelperDialog().showDialogInfo(
                        "Attention!",
                        "There is no enough USSDs, please try again later, or try lower bundles.",
                        context,
                        true, () {
                      Navigator.pop(context);
                    });
                  }
                }
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor:
                    MaterialStateProperty.all<Color>(primaryColor),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                    ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(50))),
                minimumSize: MaterialStateProperty.all<Size>(
                    Size(MediaQuery.of(context).size.width - 50, 50)),
              ),
              child: Text(
                "Pay \$${modelBundle.price} + \$0.16 Transfer Fee",
                style: const TextStyle(fontSize: 17),
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
