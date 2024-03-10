import 'package:flutter/material.dart';
import 'package:lebussd/HelperSharedPref.dart';
import 'package:lebussd/models/model_leaderboard.dart';

Widget ItemLeaderboardTop(
    ModelLeaderboard modelLeaderboard, int position, BuildContext context) {
  bool isThisItemForThisUser = modelLeaderboard.phoneNumber ==
      HelperSharedPreferences.getString("phone_number");
  double containerHeight = 0;
  double positionTextSize = 0;
  double nameTextSize = 0;
  double avatarTextSize = 0;
  double avatarRadius = 0;
  Color avatarColor = const Color(0xffffffff);

  if (position == 1) {
    containerHeight = 150;
    positionTextSize = 60;
    nameTextSize = 20;
    avatarTextSize = 30;
    avatarRadius = 30;
    avatarColor = const Color(0xffFF3B30);
  } else if (position == 2) {
    containerHeight = 100;
    positionTextSize = 60;
    positionTextSize = 45;
    avatarColor = const Color(0xffFF9500);
    nameTextSize = 17;
    avatarTextSize = 25;
    avatarRadius = 25;
  } else {
    containerHeight = 80;
    positionTextSize = 30;
    avatarColor = const Color(0xff4CD964);
    nameTextSize = 15;
    avatarTextSize = 20;
    avatarRadius = 20;
  }

  return Column(
    children: [
      CircleAvatar(
        radius: avatarRadius,
        backgroundColor: avatarColor,
        child: Text(
          modelLeaderboard.name.characters.elementAt(0),
          style: TextStyle(fontSize: avatarTextSize),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          isThisItemForThisUser ? "You" : modelLeaderboard.name,
          style: TextStyle(
              fontSize: nameTextSize,
              color: isThisItemForThisUser ? Colors.red : Colors.black),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          color: Colors.grey,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "USD ",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  modelLeaderboard.numberOfCredits,
                  style: const TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
        ),
      ),
      Card(
        elevation: 5,
        shadowColor: Colors.yellow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              height: 10,
            ),
            Container(
              color: Colors.yellow,
              width: MediaQuery.of(context).size.width *
                  (position == 2
                      ? 0.35
                      : position == 3
                          ? 0.31
                          : 0.4),
              height: containerHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Center(
                  child: Text(
                    "$position",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: positionTextSize,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ],
  );
}
