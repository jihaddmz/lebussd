import 'package:flutter/material.dart';
import 'package:lebussd/colors.dart';
import 'package:lebussd/helpers.dart';
import 'package:lebussd/screen_contactus.dart';
import 'package:lebussd/screen_home.dart';
import 'package:lebussd/screen_leaderboard.dart';
import 'package:lebussd/screen_purchasehistory.dart';
import 'package:lebussd/singleton.dart';

class ScreenNavigator extends StatefulWidget {
  ScreenNavigator({required this.callbackForWaitToRestart});

  final Function callbackForWaitToRestart;

  @override
  _ScreenNavigator createState() => _ScreenNavigator();
}

class _ScreenNavigator extends State<ScreenNavigator> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Helpers.isClientPhone()
            ? BottomNavigationBar(
                onTap: (index) {
                  setState(() {
                    if (_selectedIndex != index) {
                      _selectedIndex = index;
                    }
                  });
                },
                selectedItemColor: primaryColor,
                unselectedItemColor: Colors.black,
                items: Singleton().listOfBottomNavItems,
                currentIndex: _selectedIndex,
              )
            : null,
        body: _selectedIndex == 0
            ? ScreenHome(
                callbackForWaitToRestart: widget.callbackForWaitToRestart)
            : _selectedIndex == 1
                ? ScreenPurchaseHistory()
                : _selectedIndex == 2
                    ? ScreenLeaderboard()
                    : ScreenContactUs());
  }
}
