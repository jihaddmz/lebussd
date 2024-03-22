import 'package:flutter/material.dart';
import 'package:lebussd/components/item_purchasehistory.dart';
import 'package:lebussd/helper_dialog.dart';
import 'package:lebussd/sqlite_actions.dart';
import 'package:lottie/lottie.dart';

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
        title: Text("History", style: Theme.of(context).textTheme.displayLarge),
        leading: null,
        actions: [
          IconButton(
              onPressed: () {
                HelperDialog().showDialogAffirmation(context, "Attention!",
                    "Are you sure you want to delete all purchase history?",
                    () {
                  Navigator.pop(context);
                  SqliteActions().deleteAllPurchasesHistory().then((value) {
                    setState(() {
                      _list.clear();
                    });
                  });
                }, () {
                  Navigator.pop(context);
                });
              },
              icon: const Icon(Icons.delete_sweep))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: _list.isEmpty
            ? Center(
                child: Lottie.asset('assets/loading.json', animate: true)
              )
            : ListView.builder(
                itemCount: _list.length,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: itemPurchaseHistory(_list[index]));
                }),
      ),
    );
  }
}
