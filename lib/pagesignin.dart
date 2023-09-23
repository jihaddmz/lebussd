import 'package:flutter/material.dart';
import 'package:lebussd/HelperSharedPref.dart';
import 'package:lebussd/colors.dart';
import 'package:lebussd/helper_dialog.dart';
import 'package:lebussd/screen_home.dart';

import 'singleton.dart';

class SigninPage extends StatefulWidget {
  @override
  _SigninPage createState() => _SigninPage();
}

class _SigninPage extends State<SigninPage> {
  final TextEditingController _controllerPhoneNumber = TextEditingController();
  String? _errorText;
  String _carrierValue = "Touch";

  _SigninPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Visibility(
          visible: MediaQuery.of(context).viewInsets.bottom == 0.0,
          child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: () async {
                  String phoneNumber = _controllerPhoneNumber.text.trim();
                  if (phoneNumber.isEmpty) {
                    setState(() {
                      _errorText = "Please enter your phone number.";
                    });
                    return;
                  }

                  for (var serverPhoneNumber
                      in Singleton().listOfServerPhoneNumbers) {
                    if (serverPhoneNumber == phoneNumber) {
                      setState(() {
                        _errorText = "Invalid phone number.";
                      });
                      return;
                    }
                  }

                  if (phoneNumber.length != 8) {
                    setState(() {
                      _errorText = "Invalid phone number.";
                    });
                    return;
                  }

                  HelperSharedPreferences.setString("phone_number", phoneNumber)
                      .then((value) {
                    HelperSharedPreferences.setString("carrier", _carrierValue)
                        .then((value) {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                        return ScreenHome(
                          callbackForWaitToRestart: () {},
                        );
                      }));
                    });
                  });
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
                padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
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
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _errorText = null;
                    });
                  },
                  keyboardType: TextInputType.phone,
                  controller: _controllerPhoneNumber,
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
                      helperStyle: const TextStyle(color: Colors.grey),
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
    super.dispose();
  }
}
