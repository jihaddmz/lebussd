import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HelperDialog {
  void showDialogInfo(String? title, String content, BuildContext context,
      bool showOKBtn, Function onPressed,
      {String note = ""}) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: title != null
                ? Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                : null,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  content,
                  textAlign: TextAlign.center,
                ),
                Visibility(
                    visible: note != "",
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        note,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ))
              ],
            ),
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

  void showDialogNotConnected(BuildContext context) {
    showDialogInfo(
        "Warning!",
        "You don't have network access! Pls connect and try again.",
        context,
        true, () {
      Navigator.pop(context);
    });
  }

  void showLoaderDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: SizedBox(
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('assets/loading.json', animate: true),
                    ],
                  )));
        });
  }

  void showDialogAffirmation(BuildContext context, String title, String content,
      Function onYesClicked, Function onNoClicked) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(content, textAlign: TextAlign.center),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
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
