import 'package:flutter/material.dart';

class HelperDialog {
  void showDialogInfo(String title, String content, BuildContext context,
      bool showOKBtn, Function onPressed) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              Visibility(
                  visible: showOKBtn,
                  child: ElevatedButton(
                      onPressed: () {
                        onPressed();
                      },
                      child: const Text('OK')))
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
}
