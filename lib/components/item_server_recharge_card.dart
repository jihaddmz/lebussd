import 'package:flutter/material.dart';

import '../models/model_server_charge_history.dart';

Widget itemServerRechargeCard(
    ModelServerChargeHistory modelServerChargeHistory) {
  return Card(
    color: Colors.white10,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "\$${modelServerChargeHistory.bundle}",
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              modelServerChargeHistory.phoneNumber,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              modelServerChargeHistory.date,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const Align(
            alignment: Alignment.bottomRight,
            child: Image(
                image: AssetImage('images/touch.png'), width: 50, height: 50),
          )
        ],
      ),
    ),
  );
}
