import 'package:flutter/material.dart';
import 'package:lebussd/colors.dart';
import 'package:lebussd/components/item_leaderboard_bottom.dart';
import 'package:lebussd/components/item_leaderboard_top.dart';
import 'package:lebussd/helper_dialog.dart';
import 'package:lebussd/models/model_leaderboard.dart';

class ScreenLeaderboard extends StatefulWidget {
  @override
  _ScreenLeaderboard createState() => _ScreenLeaderboard();
}

class _ScreenLeaderboard extends State<ScreenLeaderboard> {
  List<ModelLeaderboard> _list = [];

  @override
  void initState() {
    super.initState();

    _list = [
      ModelLeaderboard(
          name: "Jihad Mahfouz",
          phoneNumber: "81909560",
          numberOfCredits: "12012"),
      ModelLeaderboard(
          name: "Ghandi Ghanem",
          phoneNumber: "78459230",
          numberOfCredits: "98"),
      ModelLeaderboard(
          name: "Nomair Raya", phoneNumber: "78459230", numberOfCredits: "987"),
      ModelLeaderboard(
          name: "Goerge Maalouf",
          phoneNumber: "78459230",
          numberOfCredits: "111"),
      ModelLeaderboard(
          name: "Abbas Kassem Zein",
          phoneNumber: "78459230",
          numberOfCredits: "110"),
      ModelLeaderboard(
          name: "Georgio Nawfal",
          phoneNumber: "78459230",
          numberOfCredits: "500"),
      ModelLeaderboard(
          name: "Roy AboGharib",
          phoneNumber: "78459230",
          numberOfCredits: "50"),
      ModelLeaderboard(
          name: "Maher", phoneNumber: "78459230", numberOfCredits: "20"),
      ModelLeaderboard(
          name: "Sarjoun", phoneNumber: "78459230", numberOfCredits: "200")
    ];

    _list.sort((p, n) {
      return int.parse(n.numberOfCredits)
          .compareTo(int.parse(p.numberOfCredits));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("Leaderboard",
            style: Theme.of(context).textTheme.displayLarge),
        leading: null,
        actions: [
          IconButton(
              onPressed: () {
                HelperDialog().showDialogInfo(
                    "Note",
                    "The First will get 5 credits\nThe Second will get 3 credits\nThe Third will get 2 credits",
                    context,
                    true, () {
                  Navigator.pop(context);
                });
              },
              icon: const Icon(Icons.info_outline_rounded))
        ],
      ),
      body: Stack(
        children: [
          FractionallySizedBox(
            heightFactor: 0.45,
            widthFactor: 1,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: -5,
                    child: ItemLeaderboardTop(_list[1], 2, context),
                  ),
                  Positioned(
                      bottom: 0,
                      left: MediaQuery.of(context).size.width * 0.68,
                      child: ItemLeaderboardTop(_list[2], 3, context)),
                  Positioned(
                      bottom: 0,
                      left: MediaQuery.of(context).size.width * 0.3,
                      child: ItemLeaderboardTop(_list[0], 1, context)),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.6,
              widthFactor: 1.02,
              child: Card(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10))),
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 100),
                    child: Column(children: listOfLeaderboards()),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> listOfLeaderboards() {
    List<Widget> result = [];
    for (var i = 3; i < _list.length; i++) {
      result.add(Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: ItemLeaderboardBottom(_list[i], i + 1),
      ));
    }

    return result;
  }
}
