import 'package:flutter/material.dart';
import 'package:lebussd/components/item_recharge_card.dart';
import 'package:lebussd/models/model_bundle.dart';

import '../models/model_purchase_history.dart';

Widget itemPurchaseHistory(ModelPurchaseHistory modelPurchaseHistory) {
  return SizedBox(height: 145, child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.max,
    children: [
      itemRechargeCard(ModelBundle(modelPurchaseHistory.price,
          modelPurchaseHistory.bundle, modelPurchaseHistory.color, modelPurchaseHistory.isTouch)),
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
                "Bundle \$${modelPurchaseHistory
                    .bundle}   Price \$${modelPurchaseHistory.price}"),
            Text("Phone Number ${modelPurchaseHistory.phoneNumber}"),
            Container(
              alignment: Alignment.bottomCenter,
              child: Text("Purchased at ${modelPurchaseHistory.date}"),
            )
          ],
        ),
      ),
    ],
  ));
}
