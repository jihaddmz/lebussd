import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'helper_dialog.dart';

class Helpers {
  static void logD(String msg) {
    debugPrint('Jihad $msg');
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
}
