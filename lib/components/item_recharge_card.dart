import 'package:flutter/material.dart';
import 'package:lebussd/models/model_bundle.dart';

Widget itemRechargeCard(ModelBundle modelBundle) {
  return Card(
    color: Color(int.parse(modelBundle.color)),
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
                    color: Colors.white),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Recharge Card",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  "Including V.A.T",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Image(
                    image: modelBundle.isTouch == 1 ? const AssetImage('images/touch.png') : const AssetImage('images/alfa.png'),
                    width: 50,
                    height: 50),
              )
            ],
          ),
        ),
      );
}
