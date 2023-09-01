import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lebussd/models/model_bundle.dart';

Widget itemRechargeCard(ModelBundle modelBundle) {
  return Card(
    color: Colors.white54,
      child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "\$${modelBundle.bundle}",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Recharge Card",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const Align(
                alignment: Alignment.bottomRight,
                child: Image(
                    image: AssetImage('images/touch.png'),
                    width: 50,
                    height: 50),
              )
            ],
          ),
        ),
      );
}
