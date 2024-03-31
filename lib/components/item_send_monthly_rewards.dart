import 'package:flutter/material.dart';
import 'package:lebussd/components/text.dart';
import 'package:lebussd/helper_firebase.dart';
import 'package:lebussd/helpers.dart';

Widget ItemSendMonthlyRewards(String username, String phoneNumber,
    String carrier, String numberOfCredits, Function onSuccess) {
  TextEditingController controller = TextEditingController();
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.TextLabel(text: username),
          MyText.TextGrey(text: phoneNumber),
          MyText.TextGrey(text: carrier),
          MyText.TextGrey(text: numberOfCredits),
        ],
      ),
      SizedBox(
        width: 50,
        height: 50,
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
        ),
      ),
      ElevatedButton(
          onPressed: () async {
            await Helpers.sendSMSMsg(
                message: "${phoneNumber}t${controller.text}",
                recipients: [carrier == "Touch" ? "1199" : "1313"],
                sendDirect: false,
                whenComplete: () {
                  onSuccess();
                },
                whenError: (e) {});
            await HelperFirebase.makeCongratsTrue(phoneNumber);
          },
          child: MyText.TextButton(text: "Send"))
    ],
  );
}
