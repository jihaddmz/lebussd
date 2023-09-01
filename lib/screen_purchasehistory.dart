import 'package:flutter/material.dart';
import 'package:lebussd/components/item_purchasehistory.dart';
import 'package:lebussd/sqlite_actions.dart';

import 'models/model_purchase_history.dart';

class ScreenPurchaseHistory extends StatefulWidget {
  @override
  _ScreenPurchaseHistory createState() => _ScreenPurchaseHistory();
}

class _ScreenPurchaseHistory extends State<ScreenPurchaseHistory> {
  List<ModelPurchaseHistory> _list = [];

  _ScreenPurchaseHistory() {
    setAllModelPurchasesToList();
  }

  void setAllModelPurchasesToList() async {
    var list = await SqliteActions().getAllPurchasesHistory();
    setState(() {
      _list = list.reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Purchase History", style: Theme.of(context).textTheme.displayLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: ListView.builder(
            itemCount: _list.length,
            itemBuilder: (context, index) {
              return itemPurchaseHistory(_list[index]);
            }),
      ),
    );
  }
}
