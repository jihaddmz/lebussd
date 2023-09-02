import 'package:flutter/material.dart';
import 'package:lebussd/components/item_recharge_card.dart';
import 'package:lebussd/models/model_bundle.dart';

import '../models/model_purchase_history.dart';

Widget itemPurchaseHistory(ModelPurchaseHistory modelPurchaseHistory) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      itemRechargeCard(
          ModelBundle(modelPurchaseHistory.price, modelPurchaseHistory.bundle, modelPurchaseHistory.color)),
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 30, 10, 30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "Bundle \$${modelPurchaseHistory.bundle}   Price \$${modelPurchaseHistory.price}")
              ],
            ),
            Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text("Purchased at ${modelPurchaseHistory.date}"))
          ],
        ),
      ),
    ],
  );
}
