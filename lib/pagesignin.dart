import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lebussd/HelperSharedPref.dart';
import 'package:lebussd/colors.dart';
import 'package:lebussd/helper_dialog.dart';
import 'package:lebussd/screen_home.dart';

import 'helpers.dart';
import 'singleton.dart';

class SigninPage extends StatefulWidget {
  @override
  _SigninPage createState() => _SigninPage();
}

class _SigninPage extends State<SigninPage> {
  final TextEditingController _controllerPhoneNumber = TextEditingController();
  final TextEditingController _controllerCode = TextEditingController();
  bool _isCodeSent = false;
  late String _verificationID;
  bool _isButtonDisabled = false;
  String _carrierValue = "Touch";
  List<String> list = const ["Touch", "Alpha"];

  _SigninPage();

  void signinUser(PhoneAuthCredential credential) async {
    // Sign the user in (or link) with the credential
    await Singleton()
        .firebaseAuth
        .signInWithCredential(credential)
        .then((value) {
      if (value.user != null) {
        HelperSharedPreferences.setString("carrier", _carrierValue);
        // Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pop(context); // dismissing the dialog loading
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return ScreenHome();
          }));
        // });
      } else {
        Navigator.pop(context); // dismissing the dialog loading
        Helpers.logD(" User is not allowed to login");
      }
    });
  }

  Future<void> verifyPhoneNumber() async {
    String phoneNb = _controllerPhoneNumber.text.trim();
    if (!phoneNb.contains("+961")) {
      phoneNb = "+961$phoneNb";
    } else if (phoneNb.contains("961") && !phoneNb.contains("+")) {
      phoneNb = "+$phoneNb";
    }

    await Singleton().firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNb,
          verificationCompleted: (PhoneAuthCredential credential) async {
            signinUser(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            Navigator.pop(context); // dismissing the dialog loading
          },
          codeSent: (String verificationId, int? resendToken) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            setState(() {
              _verificationID = verificationId;
              _isCodeSent = true;
            });
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
  }

  void verifyCodeSent() async {
    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationID, smsCode: _controllerCode.text);

    signinUser(credential);
  }

  void disableButton() {
    setState(() {
      _isButtonDisabled = true;
    });

    Future.delayed(Duration(minutes: 5), () {
      setState(() {
        _isButtonDisabled = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Visibility(
          visible: MediaQuery.of(context).viewInsets.bottom == 0.0,
          child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: () {
                  if (_isButtonDisabled) return;

                  if (!Singleton().isConnected) {
                    HelperDialog().showDialogInfo("Attention", "No network access, please connect and try again.", context, true, (){Navigator.pop(context);});
                    return;
                  }

                  if (_isCodeSent) {
                    // if the button is for verifying verification code
                    if (_controllerCode.text.trim().length == 0) {
                      HelperDialog().showDialogInfo(
                          'Attention',
                          "Please enter the verification code sent to you",
                          context,
                          true, () {
                        Navigator.pop(context);
                      });
                      return;
                    }
                    HelperDialog().showLoaderDialog(context);
                    verifyCodeSent();
                  } else {
                    // if the button is for signing user up
                    if (_controllerPhoneNumber.text.trim().isEmpty) {
                      HelperDialog().showDialogInfo('Attention',
                          "Please enter your phone number", context, true, () {
                        Navigator.pop(context);
                      });
                      return;
                    }
                    HelperDialog().showLoaderDialog(context);
                    verifyPhoneNumber();
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
                child: Text(_isCodeSent ? 'Verify Code' : 'Sign Up',
                    style: const TextStyle(fontSize: 20)),
              )),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                child: Image(
                    image: const AssetImage('images/img_signin.png'),
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.height * 0.4)),
            Text(
              "Lebanon USSD Store",
              style: Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            Visibility(
                visible: !_isCodeSent,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
                    child: TextFormField(
                      keyboardType: TextInputType.phone,
                      controller: _controllerPhoneNumber,
                      decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 1,
                                  color: Colors.grey,
                                  style: BorderStyle.solid),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          labelText: 'Enter your phone number',
                          helperText: "ex 81909560",
                          helperStyle: TextStyle(color: Colors.grey),
                          labelStyle:
                              TextStyle(color: Colors.grey, fontSize: 13)),
                    ))),
            Visibility(
                visible: !_isCodeSent,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: DropdownButton(
                        value: _carrierValue,
                        icon: const Icon(
                          Icons.arrow_downward,
                          color: primaryColor,
                        ),
                        isExpanded: true,
                        items: list.map((e) {
                          return DropdownMenuItem(value: e, child: Text(e));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _carrierValue = value!;
                          });
                        }))),
            Visibility(
              visible: _isCodeSent,
              maintainAnimation: true,
              maintainState: true,
              child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.fastOutSlowIn,
                  opacity: _isCodeSent ? 1 : 0,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
                      child: TextFormField(
                        enabled: _isCodeSent,
                        controller: _controllerCode,
                        decoration: const InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1,
                                    color: Colors.grey,
                                    style: BorderStyle.solid),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            labelText: 'Verification Code',
                            helperText: "Verification code is sent by sms!",
                            labelStyle:
                                TextStyle(color: Colors.grey, fontSize: 13),
                            helperStyle:
                                TextStyle(color: Colors.grey, fontSize: 13)),
                      ))),
            ),
          ],
        )));
  }
}
