import 'package:flutter/material.dart';
import 'package:lebussd/colors.dart';
import 'package:lebussd/components/item_leaderboard_bottom.dart';
import 'package:lebussd/components/item_leaderboard_top.dart';
import 'package:lebussd/helper_dialog.dart';
import 'package:lebussd/helper_firebase.dart';
import 'package:lebussd/helpers.dart';
import 'package:lebussd/models/model_leaderboard.dart';

class ScreenLeaderboard extends StatefulWidget {
  ScreenLeaderboard({required this.onNetworkAccess});

  final Function() onNetworkAccess;

  @override
  _ScreenLeaderboard createState() => _ScreenLeaderboard();
}

class _ScreenLeaderboard extends State<ScreenLeaderboard> {
  List<ModelLeaderboard> _list = [];

  @override
  void initState() {
    super.initState();

    fetchAllUsers();
  }

  Future<void> fetchAllUsers() async {
    if (await Helpers.isConnected()) {
      HelperDialog().showLoaderDialog(context);
      List<ModelLeaderboard> result = [];
      await HelperFirebase.fetchAllUsers((documentSnapshot) {
        result.add(ModelLeaderboard(
            name: documentSnapshot["username"],
            phoneNumber: documentSnapshot.id,
            numberOfCredits: documentSnapshot["numberOfCredits"]));
      });

      setState(() {
        _list = result;
      });

      Navigator.pop(context);

      _list.sort((p, n) {
        return int.parse(n.numberOfCredits)
            .compareTo(int.parse(p.numberOfCredits));
      });
    } else {
      HelperDialog().showDialogNotConnected(context);

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);

        widget.onNetworkAccess();
      });
    }
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
                    "Info",
                    "- The First will get 5 credits\n- The Second will get 3 credits\n- The Third will get 2 credits\n\nEach will receive their bonuses monthly on the 1st of the second month.",
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
              child: Visibility(
                  visible: _list.length >= 3,
                  child: Stack(children: listOfLeaderboardsTop()
                      // Positioned(
                      //   bottom: 0,
                      //   left: -5,
                      //   child:
                      //       ItemLeaderboardTop(_list.elementAt(1), 2, context),
                      // ),
                      // Positioned(
                      //     bottom: 0,
                      //     left: MediaQuery.of(context).size.width * 0.68,
                      //     child: ItemLeaderboardTop(
                      //         _list.elementAt(2), 3, context)),
                      // Positioned(
                      //     bottom: 0,
                      //     left: MediaQuery.of(context).size.width * 0.3,
                      //     child: ItemLeaderboardTop(
                      //         _list.elementAt(0), 1, context)),

                      )),
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

  List<Widget> listOfLeaderboardsTop() {
    List<Widget> result = [];

    Widget? first;

    for (var i = 0; i < _list.length; i++) {
      if (i > 2) {
        break;
      }
      if (i == 0) {
        // because we want to add the first standing at the end to become infront the others
        first = Positioned(
          bottom: 0,
          left: i + 1 == 2
              ? -5
              : i + 1 == 3
                  ? MediaQuery.of(context).size.width * 0.68
                  : MediaQuery.of(context).size.width * 0.3,
          child: ItemLeaderboardTop(_list.elementAt(i), i + 1, context),
        );
        continue;
      }

      result.add(Positioned(
        bottom: 0,
        left: i + 1 == 2
            ? -5
            : i + 1 == 3
                ? MediaQuery.of(context).size.width * 0.68
                : MediaQuery.of(context).size.width * 0.3,
        child: ItemLeaderboardTop(_list.elementAt(i), i + 1, context),
      ));
    }
    if (first != null) {
      result.add(first);
    }

    return result;
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
