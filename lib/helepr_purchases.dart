import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class HelpersPurchases {

  Future<void> initPlatformState() async {
    await Purchases.setLogLevel(LogLevel.error);

    PurchasesConfiguration configuration = PurchasesConfiguration(
        "goog_XcmarpGGuGdsuSzcJrehkQZGCza"); // for android
    if (Platform.isIOS) {
      configuration = PurchasesConfiguration(""); // todo put the ios public api key
    }
    await Purchases.configure(configuration);
  }

  Future<void> setProducts({required Function(Offering) onOfferingsGetComplete}) async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        onOfferingsGetComplete(offerings.current!);
        // Display current offering with offerings.current
      }
    } on PlatformException catch (e) {
      // optional error handling
    }
  }
}