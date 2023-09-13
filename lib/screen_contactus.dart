import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:image_picker/image_picker.dart';

import 'colors.dart';
import 'components/options_selector.dart';

class ScreenContactUs extends StatefulWidget {
  @override
  _ScreenContactUs createState() => _ScreenContactUs();
}

class _ScreenContactUs extends State<ScreenContactUs> {
  String bug = "Bug";
  String bundle = "Bundle";
  String other = "Other";
  late String _selectedOption;
  TextEditingController _controllerMessage = TextEditingController();
  String? _errorText;
  List<File> _listOfFiles = [];

  @override
  void initState() {
    super.initState();
    _selectedOption = bug;
  }

  @override
  Widget build(BuildContext context) {
    String explanationText = _selectedOption == bug
        ? "Submit any bug/error you have encountered while using the app, in order to solve it for you. Please provide as much information you can, so we "
            "can clearly see what happened with you!"
        : _selectedOption == bundle
            ? "Submit an issue if you have purchased any of the bundles available and you haven't received the bundle. "
                "Please be sure to attach a screenshot of the purchase history screen as well!"
            : "Submit any other feedback, comments, features you want to see in the future, or any questions you have about the app.";

    return Scaffold(
        appBar: AppBar(
          title: Text("Contact Us",
              style: Theme.of(context).textTheme.displayLarge),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Visibility(
          visible: MediaQuery.of(context).viewInsets.bottom == 0.0,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (validated()) {
                      sendEmail();
                    } else {
                      setState(() {
                        _errorText = "Enter all required information *";
                      });
                    }
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                        validated() ? Colors.white : Colors.black),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        validated() ? primaryColor : secondaryColor),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                        ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                    minimumSize: MaterialStateProperty.all<Size>(
                        Size(MediaQuery.of(context).size.width - 50, 50)),
                  ),
                  child: const Text("Submit", style: TextStyle(fontSize: 18)),
                ),
                Text(
                  _errorText ?? "",
                  style: TextStyle(color: Colors.red),
                )
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: OptionsSelector(
                    list: [bug, bundle, other],
                    onTap: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(explanationText,
                              style: const TextStyle(color: Colors.grey))),
                      Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: TextFormField(
                            onChanged: (value) {
                              if (_errorText != null) {
                                setState(() {
                                  _errorText = null;
                                });
                              }
                            },
                            maxLines: 10,
                            minLines: 3,
                            enabled: true,
                            controller: _controllerMessage,
                            decoration: const InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1,
                                        color: Colors.grey,
                                        style: BorderStyle.solid),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                labelText: "Your Message*",
                                labelStyle: TextStyle(
                                    color: Colors.grey, fontSize: 13)),
                          )),
                      Visibility(
                          visible: _selectedOption == bundle,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _getFromGallery();
                                  },
                                  child: const Text("Attach:*",
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Expanded(
                                    child: SizedBox(
                                  height: 60,
                                  child: ListView(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      children: attachments()),
                                ))
                              ],
                            ),
                          ))
                    ],
                  ),
                )
              ],
            )));
  }

  bool validated() {
    if (_selectedOption == bundle) {
      if (_listOfFiles.isNotEmpty &&
          _controllerMessage.text.trim().isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } else {
      if (_controllerMessage.text.trim().isNotEmpty) {
        return true;
      } else {
        return false;
      }
    }
  }

  /// Get from gallery
  _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _listOfFiles.add(imageFile);
      });
    }
  }

  void sendEmail() async {
    final Email email = Email(
      body: _controllerMessage.text.trim(),
      subject: _selectedOption,
      recipients: ['developer@appsfourlife.com'],
      attachmentPaths: fromToString(),
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }

  List<String> fromToString() {
    List<String> list = [];

    for (var file in _listOfFiles) {
      list.add(file.path);
    }

    return list;
  }

  List<Widget> attachments() {
    List<Widget> widgets = [];

    List.generate(_listOfFiles.length, (index) {
      File current = _listOfFiles[index];

      widgets.add(Card(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              Text(current.path.split("/")[current.path.split("/").length - 1]),
              IconButton(
                  onPressed: () {
                    setState(() {
                      _listOfFiles.remove(current);
                    });
                  },
                  icon: Icon(Icons.close))
            ],
          ),
        ),
      ));
    });

    return widgets;
  }
}
