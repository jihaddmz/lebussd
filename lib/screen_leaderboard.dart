import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ScreenLeaderboard extends StatefulWidget {
  @override
  _ScreenLeaderboard createState() => _ScreenLeaderboard();
}

class _ScreenLeaderboard extends State<ScreenLeaderboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Leaderboard", style: Theme.of(context).textTheme.displayLarge),
        leading: null,
      ),
    );
  }
}
