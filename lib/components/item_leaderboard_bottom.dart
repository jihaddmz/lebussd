import 'package:flutter/material.dart';
import 'package:lebussd/HelperSharedPref.dart';
import 'package:lebussd/models/model_leaderboard.dart';

Widget ItemLeaderboardBottom(ModelLeaderboard modelLeaderboard, int index) {
  bool isThisItemForThisUser = modelLeaderboard.phoneNumber ==
                    HelperSharedPreferences.getString("phone_number");
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Text("$index"),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: CircleAvatar(
              backgroundColor: Colors.black,
              child: Text(modelLeaderboard.name.characters.elementAt(0)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(isThisItemForThisUser
                ? "You"
                : modelLeaderboard.name, style: TextStyle(color: isThisItemForThisUser ? Colors.red : Colors.black),),
          )
        ],
      ),
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        color: Colors.grey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "USD ",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                modelLeaderboard.numberOfCredits,
                style: const TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
      )
    ],
  );
}
