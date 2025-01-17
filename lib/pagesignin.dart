import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lebussd/HelperSharedPref.dart';
import 'package:lebussd/colors.dart';
import 'package:lebussd/helper_dialog.dart';
import 'package:lebussd/helper_firebase.dart';
import 'package:lebussd/helpers.dart';
import 'package:lebussd/screen_navigator.dart';
import 'package:lebussd/sqlite_actions.dart';

import 'singleton.dart';

class SigninPage extends StatefulWidget {
  @override
  _SigninPage createState() => _SigninPage();
}

class _SigninPage extends State<SigninPage> {
  final TextEditingController _controllerPhoneNumber = TextEditingController();
  final TextEditingController _controllerUsername = TextEditingController();
  String? _errorText;
  String? _errorTextUserName;
  String _carrierValue = "Touch";

  _SigninPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Visibility(
          visible: MediaQuery.of(context).viewInsets.bottom == 0.0,
          child: Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: ElevatedButton(
                onPressed: () async {
                  String phoneNumber = _controllerPhoneNumber.text.trim();
                  String username = _controllerUsername.text.trim();

                  if (username.isEmpty) {
                    setState(() {
                      _errorTextUserName = "Please enter your username.";
                    });
                    return;
                  }

                  if (phoneNumber.isEmpty) {
                    setState(() {
                      _errorText = "Please enter your phone number.";
                    });
                    return;
                  }

                  if (phoneNumber.length != 8) {
                    setState(() {
                      _errorText = "Invalid phone number.";
                    });
                    return;
                  }

                  if (await Helpers.isConnected()) {
                    HelperDialog().showLoaderDialog(context);

                    String numberOfCredits = "0";
                    bool isSignedInTrue = false;

                    if (HelperSharedPreferences.getString("phone_number")
                            .isEmpty &&
                        HelperSharedPreferences.getString("name").isEmpty) {
                      // the user has signed in before with his phone number and username
                      await HelperFirebase.isUserAlreadySignedIn(phoneNumber,
                          (docmentSnapshot) {
                        Map<String, dynamic> map =
                            HelperFirebase.getUserCredentials(docmentSnapshot);

                        if (map["isSignedIn"]) {
                          isSignedInTrue = true;
                          // isSignedIn is true, so this user can't sign in
                          Navigator.pop(context);
                          HelperDialog().showDialogInfo(
                              "Warning!",
                              "There is a user already signed in with this phone number!",
                              context,
                              true, () {
                            Navigator.pop(context);
                          });
                        } else {
                          // isSignedIn is false, so this user can sign in
                          numberOfCredits = map["numberOfCredits"];
                        }
                      });
                    } else {
                      // the user hasn't signed before with the new details (phone number and username)
                      await SqliteActions()
                          .getAllPurchasesHistory()
                          .then((value) {
                        for (var i = 0; i < value.length; i++) {
                          numberOfCredits =
                              (double.parse(numberOfCredits) + value[i].bundle)
                                  .toString();
                        }
                      });
                    }

                    if (!isSignedInTrue) {
                      await HelperFirebase.createUserEntry(
                          phoneNumber, username, _carrierValue,
                          numberOfCredits: numberOfCredits);
                      HelperSharedPreferences.setString(
                              "phone_number", phoneNumber)
                          .then((value) {
                        HelperSharedPreferences.setString("name", username)
                            .then((value) {
                          HelperSharedPreferences.setString(
                                  "carrier", _carrierValue)
                              .then((value) async {
                            await HelperSharedPreferences.setString(
                                "number_of_credits", numberOfCredits);
                            Navigator.pop(context);
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (BuildContext context) {
                              return ScreenNavigator(
                                callbackForWaitToRestart: () {},
                              );
                            }), (route) => false);
                          });
                        });
                      });
                    }
                  } else {
                    HelperDialog().showDialogNotConnected(context);
                  }
                },
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(primaryColor),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                      ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                  minimumSize: MaterialStateProperty.all<Size>(
                      Size(MediaQuery.of(context).size.width - 50, 50)),
                ),
                child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
              )),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Image(
                    image: const AssetImage('images/img_signin.png'),
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.height * 0.4)),
            Text(
              "Charge Anytime Anywhere",
              style: Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    _errorTextUserName = null;
                  });
                },
                controller: _controllerUsername,
                inputFormatters: [LengthLimitingTextInputFormatter(13)],
                decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 1,
                            color: Colors.grey,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    labelText: 'Enter your username',
                    helperText: "Your name and family name",
                    errorText: _errorTextUserName,
                    helperStyle: const TextStyle(color: Colors.black),
                    labelStyle:
                        const TextStyle(color: Colors.grey, fontSize: 13)),
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _errorText = null;
                    });
                  },
                  keyboardType: TextInputType.phone,
                  controller: _controllerPhoneNumber,
                  inputFormatters: [LengthLimitingTextInputFormatter(8)],
                  decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1,
                              color: Colors.grey,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: 'Enter your phone number',
                      helperText: "ex 81909560",
                      errorText: _errorText,
                      helperStyle: const TextStyle(color: Colors.black),
                      labelStyle:
                          const TextStyle(color: Colors.grey, fontSize: 13)),
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: DropdownButton(
                    value: _carrierValue,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: primaryColor,
                    ),
                    isExpanded: true,
                    items: Singleton().listOfCarriers.map((e) {
                      return DropdownMenuItem(value: e, child: Text(e));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _carrierValue = value!;
                      });
                    })),
          ],
        )));
  }

  @override
  void dispose() {
    _controllerPhoneNumber.dispose();
    _controllerUsername.dispose();
    super.dispose();
  }
}
