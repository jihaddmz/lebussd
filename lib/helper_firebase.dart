import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lebussd/HelperSharedPref.dart';
import 'package:lebussd/singleton.dart';

class HelperFirebase {
  static final fields = _Fields._();

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

// for server fetching the top 3 in the leaderboards
  static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?>
      fetchTop3InLeaderboard() async {
    List<QueryDocumentSnapshot<Map<String, dynamic>>>? list;
    await Singleton()
        .db
        .collection(fields.collUsers)
        .get()
        .then((value) {
      list = value.docs;
      list!.sort((p, n) {
        // sorting the docs according to the descending order of numberOfCredits
        return double.parse(n[fields.fieldNumberOfCredits])
            .compareTo(
                double.parse(p[fields.fieldNumberOfCredits]));
      });
      // list!.removeRange(3, list!.length); // removing the unneccassary elements
      // for (var element in list!) {
      //   Helpers.logD("Number of credits is ${element["numberOfCredits"]}");
      // }
    }).onError((error, stackTrace) => null);

    return list;
  }

// for server, reset the number of credits for the users that are rewarded and returns true if the process is successful
  static Future<bool> resetNumberOfCredits(String phoneNumber) async {
    bool result = false;
    Singleton()
        .db
        .collection(fields.collUsers)
        .doc(phoneNumber)
        .set({fields.fieldNumberOfCredits: "0"},
            SetOptions(merge: true)).then((value) {
      result = true;
    }).onError((error, stackTrace) {
      result = false;
    });

    return result;
  }

// for server, updates the congrats value to true so the user will be congratulated in the app
  static Future<void> makeCongratsTrue(String phoneNumber) async {
    Map<String, dynamic> map = {};
    map[fields.fieldCongrats] = true;
    await Singleton()
        .db
        .collection(fields.collUsers)
        .doc(phoneNumber)
        .set(map, SetOptions(merge: true));
  }
}

// fields for firebase firestore
class _Fields {
  _Fields._();

  final String collScheduledAlfaCredits = "scheduledAlfaCredits";
  final String collScheduledTouchCredits = "scheduledTouchCredits";
  final String collRequests = "requestss";
  final String collRequestsAlfa = "requestssAlfa";
  final String collUsers = "users";

  final String fieldNumberOfCredits = "numberOfCredits";
  final String fieldCongrats = "congrats";
}
