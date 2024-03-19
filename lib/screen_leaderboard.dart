import 'package:flutter/material.dart';
import 'package:lebussd/colors.dart';
import 'package:lebussd/components/item_leaderboard_bottom.dart';
import 'package:lebussd/components/item_leaderboard_top.dart';
import 'package:lebussd/helper_dialog.dart';
import 'package:lebussd/helper_firebase.dart';
import 'package:lebussd/helpers.dart';
import 'package:lebussd/models/model_leaderboard.dart';
import 'package:lottie/lottie.dart';

class ScreenLeaderboard extends StatefulWidget {
  ScreenLeaderboard({required this.onNetworkAccess});

  final Function() onNetworkAccess;

  @override
  _ScreenLeaderboard createState() => _ScreenLeaderboard();
}

class _ScreenLeaderboard extends State<ScreenLeaderboard>
    with SingleTickerProviderStateMixin {
  List<ModelLeaderboard> _list = [];
  late final String firstReward;
  late final String secondReward;
  late final String thirdReward;
  late AnimationController controller;
  bool _showAnimations = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);

    Future.delayed(const Duration(milliseconds: 500), () {fetchIfIsCongratsTrue();});
    
    fetchAllUsers();
    fetchNumberOfRewardsStored();
  }

  Future<void> fetchIfIsCongratsTrue() async {
    HelperFirebase.fetchIsCongratsTrue().then((value) {
      if (value) {
        setState(() {
          _showAnimations = true;
        });
        controller.repeat(period: const Duration(seconds: 2));

        Future.delayed(const Duration(seconds: 5), () {
          HelperFirebase.updateIsCongrats(false);
          controller.reset();
        });
      }
    });
  }

  Future<void> fetchNumberOfRewardsStored() async {
    if (await Helpers.isConnected()) {
      await HelperFirebase.fetchNumberOfRewardsStored().then((value) async {
        if (value != null) {
          firstReward = value["firstReward"];
          secondReward = value["secondReward"];
          thirdReward = value["thirdReward"];
        }
      });
    }
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
                    "- The First will get $firstReward credits\n- The Second will get $secondReward credits\n- The Third will get $thirdReward credits\n\nEach will receive their rewards monthly on the 1st of the second month.",
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
            child: Visibility(
                visible: _list.length >= 3,
                child: Stack(children: listOfLeaderboardsTop())),
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
          ),
          Visibility(
              visible: _showAnimations,
              child: Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Lottie.asset(
                    controller: controller,
                    "assets/congratulations.json",
                    animate: true,
                    repeat: false),
              )),
          Visibility(
              visible: _showAnimations,
              child: Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Lottie.asset(
                      controller: controller,
                      "assets/congrats.json",
                      animate: true,
                      repeat: false))),
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
