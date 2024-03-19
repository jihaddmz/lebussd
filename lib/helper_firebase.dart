import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lebussd/HelperSharedPref.dart';
import 'package:lebussd/singleton.dart';

class HelperFirebase {
  static Future<void> createUserEntry(
      String phoneNumber, String username, String carrier,
      {String numberOfCredits = "0"}) async {
    Map<String, dynamic> map = {};
    map["username"] = username;
    map["numberOfCredits"] = numberOfCredits;
    map["isSignedIn"] = true;
    map["carrier"] = carrier;
    await Singleton()
        .db
        .collection("users")
        .doc(phoneNumber)
        .set(map)
        .then((value) => null)
        .catchError((e) {});
  }

  static Future<void> updateIsSignedOut() async {
    Map<String, dynamic> map = {};
    map["isSignedIn"] = false;
    await Singleton()
        .db
        .collection("users")
        .doc(HelperSharedPreferences.getString("phone_number"))
        .set(map, SetOptions(merge: true))
        .then((value) => null)
        .catchError((e) {});
  }

  static Future<bool> isUserAlreadySignedIn(String phoneNumber,
      Function(DocumentSnapshot<Map<String, dynamic>>) userIsCreated) async {
    bool isSignedIn = false;
    await Singleton()
        .db
        .collection("users")
        .doc(phoneNumber)
        .get()
        .then((value) {
      if (value.data() == null) {
        // the user is not created before
        isSignedIn = false;
      } else {
        // the user is created before
        isSignedIn = true;
        userIsCreated(value);
      }
    });

    return isSignedIn;
  }

  static Map<String, dynamic> getUserCredentials(
      DocumentSnapshot<Map<String, dynamic>> value) {
    return {
      "isSignedIn": value["isSignedIn"],
      "numberOfCredits": value["numberOfCredits"]
    };
  }

  static Future<String> getUserNumberOfCredits(String phoneNumber) async {
    String numberOfCredits = "0";

    await Singleton()
        .db
        .collection("users")
        .doc(phoneNumber)
        .get()
        .then((value) {
      numberOfCredits = value["numberOfCredits"];
    });

    return numberOfCredits;
  }

  static Future<void> fetchAllUsers(
      Function(DocumentSnapshot<Map<String, dynamic>>)
          onDocumentFetched) async {
    await Singleton().db.collection("users").get().then((value) {
      for (var element in value.docs) {
        onDocumentFetched(element);
      }
    });
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>?>
      fetchNumberOfRewardsStored() async {
    DocumentSnapshot<Map<String, dynamic>>? result;

    await Singleton()
        .db
        .collection("app")
        .doc("leaderboards")
        .get()
        .then((value) {
      result = value;
    });

    return result;
  }

  static Future<void> updateUserNumberOfCredits(double chosenBundle) async {
    Map<String, dynamic> map = {};
    map["numberOfCredits"] =
        (double.parse(HelperSharedPreferences.getString("number_of_credits")) +
                chosenBundle)
            .toString();
    await Singleton()
        .db
        .collection("users")
        .doc(HelperSharedPreferences.getString("phone_number"))
        .set(map, SetOptions(merge: true));
  }

  static Future<bool> fetchIsCongratsTrue() async {
    bool result = false;

    await Singleton()
        .db
        .collection("users")
        .doc(HelperSharedPreferences.getString("phone_number"))
        .get()
        .then((value) {
      result = value["congrats"];
    }).onError((error, stackTrace) {});

    return result;
  }

  static Future<void> updateIsCongrats(bool value) async {
    Map<String, dynamic> map = {};
    map["congrats"] = value;
    await Singleton()
        .db
        .collection("users")
        .doc(HelperSharedPreferences.getString("phone_number"))
        .set(map, SetOptions(merge: true));
  }
}
