import 'package:flutter/material.dart';

Widget ButtonSmall({required String text, required Color color, required Function onClick}) {
  return ElevatedButton(
      onPressed: () {
        onClick();
      },
      child: Text(text, style: TextStyle(fontSize: 15, color: color)));
}

Widget ButtonMedium({required String text, required Color color, required Function onClick}) {
  return ElevatedButton(
      onPressed: () {
        onClick();
      },
      child: Text(text, style: TextStyle(fontSize: 17, color: color)));
}
