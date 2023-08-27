import 'package:flutter/material.dart';

class HelperDialog {
  void showDialogInfo(String? title, String content, BuildContext context,
      bool showOKBtn, Function onPressed) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: title != null ? Text(title) : null,
            content: Text(content),
            actions: [
              SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                child: Visibility(
                    visible: showOKBtn,
                    child: ElevatedButton(
                        onPressed: () {
                          onPressed();
                        },
                        child:
                            const Text('OK', style: TextStyle(fontSize: 15)))),
              )
            ],
          );
        });
  }

  void showLoaderDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: Text("Loading...")),
              ],
            ),
          );
        });
  }

  void showDialogAffirmation(BuildContext context, String title, String content,
      Function onYesClicked, Function onNoClicked) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    onYesClicked();
                  },
                  child: const Text('Yes', style: TextStyle(fontSize: 15))),
              ElevatedButton(
                  onPressed: () {
                    onNoClicked();
                  },
                  child: const Text('No', style: TextStyle(fontSize: 15)))
            ],
          );
        });
  }
}
