import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lebussd/colors.dart';
import 'package:lebussd/helper_dialog.dart';
import 'package:lebussd/screen_home.dart';
import 'package:permission_handler/permission_handler.dart';

import 'helpers.dart';
import 'singleton.dart';

class SigninPage extends StatefulWidget {
  @override
  _SigninPage createState() => _SigninPage();
}

class _SigninPage extends State<SigninPage> {
  TextEditingController _controllerPhoneNumber = TextEditingController();
  TextEditingController _controllerCode = TextEditingController();
  bool _isCodeSent = false;
  late String _verificationID;
  bool _isButtonDisabled = false;

  _SigninPage() {
    Future.delayed(Duration(seconds: 1), () {
      requestPermissions();
    });
  }

  Future<void> requestPermissions() async {
    var phoneStatus = await Permission.phone.request();

    if (phoneStatus.isGranted) {
      // Permission granted. You can now use the camera.
    } else if (phoneStatus.isDenied) {
      HelperDialog().showDialogInfo(
          "Attention!",
          "In order to be able to charge credits online, you should allow this permission",
          context,
          true, () {
        Navigator.pop(context);
        requestPermissions();
      });
      // Permission denied. You might want to show a message to the user.
    } else if (phoneStatus.isPermanentlyDenied) {
      // The user has permanently denied the permission.
      // You might want to guide the user to the app settings.
    }
  }

  void fetchPhoneNumber() {
    Singleton().phoneNumber =
        Singleton().firebaseAuth.currentUser!.phoneNumber ?? "NA";
  }

  void signinUser(PhoneAuthCredential credential) {
    Singleton().firebaseAuth.signInWithCredential(credential);
    fetchPhoneNumber();
    Navigator.pop(context); // dismissing the dialog loading
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return ScreenHome();
    }));
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

    // Sign the user in (or link) with the credential
    await Singleton()
        .firebaseAuth
        .signInWithCredential(credential)
        .then((value) {
      if (value.user != null) {
        fetchPhoneNumber();
        Navigator.pop(context); // dismissing the dialog loading
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return ScreenHome();
        }));
      } else {
        Navigator.pop(context); // dismissing the dialog loading
        Helpers.logD(" User is not allowed to login");
      }
    });
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

                  if (_isCodeSent) {
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
                    if (_controllerPhoneNumber.text.trim().length == 0) {
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
                child: Text(_isCodeSent ? 'Verify Code' : 'Sign Up'),
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
            Padding(
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
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: 'Enter your phone number',
                      helperText: "ex 81909560",
                      helperStyle: TextStyle(color: Colors.grey),
                      labelStyle: TextStyle(color: Colors.grey, fontSize: 13)),
                )),
            Visibility(
              visible: true,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                        labelStyle:
                            TextStyle(color: Colors.grey, fontSize: 13)),
                  )),
            ),
          ],
        )));
  }
}
