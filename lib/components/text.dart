import 'package:flutter/material.dart';
import 'package:lebussd/colors.dart';

class MyText {

  static Widget TextButton({required String text}) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
    );
  }

  static Widget TextNormal({required String text}) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.normal),
    );
  }

  static Widget TextGrey({required String text}) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w300),
    );
  }

  static Widget TextLabel({required String text}) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w500),
    );
  }

  static Widget TextHeadline({required String text}) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w700),
    );
  }

  static Widget TextTitle({required String text}) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w900),
    );
  }

  static Widget TextLink({required String text, required Function onTap}) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.normal,
            decoration: TextDecoration.underline,
            decorationColor: primaryColor,
            color: primaryColor),
      ),
    );
  }
}
