import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:lebussd/HelperSharedPref.dart';
import 'package:lebussd/singleton.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'helper_dialog.dart';

class Helpers {
  static void logD(String msg) {
    debugPrint('Jihad $msg');
  }

  ///
  /// method to check if this device is a client or the server phone
  ///
  static bool isClientPhone() {
    for (var number in Singleton().listOfServerPhoneNumbers) {
      if (HelperSharedPreferences.getString("phone_number") == number) {
        return false;
      }
    }

    return true;
  }

  static requestOneSignalPermission() {
    // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    OneSignal.shared
        .promptUserForPushNotificationPermission(fallbackToSettings: true);
  }

  static Future<bool> requestPhotoPermission(BuildContext context) async {
    var photoStatus = await Permission.photos.request();

    if (photoStatus.isGranted) {
      // Permission granted. You can now use the gallery.
      return true;
    } else if (photoStatus.isDenied) {
      if (context.mounted) {
        HelperDialog().showDialogInfo(
            "Attention!",
            "In order to be able to pick an image, you should allow this permission",
            context,
            true, () {
          Navigator.pop(context);
          requestPhotoPermission(context);
        });
      }
      // Permission denied. You might want to show a message to the user.
    } else if (photoStatus.isPermanentlyDenied) {
      if (context.mounted) {
        HelperDialog().showDialogInfo(
            "Attention!",
            "In order to be able to pick an image, you should allow this permission",
            context,
            true, () {
          Navigator.pop(context);
          openAppSettings();
        });
      }
    }
    return false;
  }

  static Future<bool> requestSMSPermission(BuildContext context) async {
    var smsStatus = await Permission.sms.request();

    if (smsStatus.isGranted) {
      // Permission granted. You can now use the camera.
      return true;
    } else if (smsStatus.isDenied) {
      if (context.mounted) {
        HelperDialog().showDialogInfo(
            "Attention!",
            "In order to be able to recharge credits online, you should allow this permission",
            context,
            true, () {
          Navigator.pop(context);
          requestSMSPermission(context);
        });
      }
      // Permission denied. You might want to show a message to the user.
    } else if (smsStatus.isPermanentlyDenied) {
      if (context.mounted) {
        HelperDialog().showDialogInfo(
            "Attention!",
            "In order to be able to recharge credits online, you should allow this permission",
            context,
            true, () {
          Navigator.pop(context);
          openAppSettings();
        });
      }
      // The user has permanently denied the permission.
      // You might want to guide the user to the app settings.
    }
    return false;
  }

  static Future<bool> requestPhonePermission(BuildContext context) async {
    var phoneStatus = await Permission.phone.request();

    if (phoneStatus.isGranted) {
      // Permission granted. You can now use the camera.
      return true;
    } else if (phoneStatus.isDenied) {
      if (context.mounted) {
        HelperDialog().showDialogInfo(
            "Attention!",
            "In order to be able to check your balance, you need to grant this permission",
            context,
            true, () {
          Navigator.pop(context);
          requestPhonePermission(context);
        });
      }
      // Permission denied. You might want to show a message to the user.
    } else if (phoneStatus.isPermanentlyDenied) {
      if (context.mounted) {
        HelperDialog().showDialogInfo(
            "Attention!",
            "In order to be able to check your balance, you need to grant this permission",
            context,
            true, () {
          Navigator.pop(context);
          openAppSettings();
        });
      }
      // The user has permanently denied the permission.
      // You might want to guide the user to the app settings.
    }
    return false;
  }

  static Future<bool> requestContactPermission(BuildContext context) async {
    var contactStatus = await Permission.contacts.request();

    if (contactStatus.isGranted) {
      // Permission granted. You can now use the camera.
      return true;
    } else if (contactStatus.isDenied) {
      if (context.mounted) {
        HelperDialog().showDialogInfo(
            "Attention!",
            "In order to be able to choose a contact on your phone, you have to grant this permission",
            context,
            true, () {
          Navigator.pop(context);
          requestPhonePermission(context);
        });
      }
      // Permission denied. You might want to show a message to the user.
    } else if (contactStatus.isPermanentlyDenied) {
      if (context.mounted) {
        HelperDialog().showDialogInfo(
            "Attention!",
            "In order to be able to choose a contact on your phone, you have to grant this permission",
            context,
            true, () {
          Navigator.pop(context);
          openAppSettings();
        });
      }
      // The user has permanently denied the permission.
      // You might want to guide the user to the app settings.
    }
    return false;
  }

  static Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// method for server
  /// charging the client by sending a message to the client phone number ex: 76815643t1
  ///
  static Future<void> sendSMSMsg(
      {required String message,
      required List<String> recipients,
      bool sendDirect = true,
      required Function whenComplete,
      required Function(dynamic) whenError}) async {
    await sendSMS(message: message, recipients: recipients, sendDirect: sendDirect)
        .catchError((onError) {
      whenError(onError);
    }).then((value) {
      whenComplete();
    });
  }
}
