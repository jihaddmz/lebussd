import 'package:flutter/material.dart';
import 'package:lebussd/pagesignin.dart';
import 'package:lebussd/singleton.dart';

class ScreenWelcome extends StatefulWidget {
  ScreenWelcome({super.key});

  @override
  _ScreenWelcome createState() => _ScreenWelcome();
}

class _ScreenWelcome extends State<ScreenWelcome> {
  final PageController _pageController = PageController(initialPage: 0);
  final List<Widget> _pages = [FirstPage(), SigninPage()];
  int _activePage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemBuilder: (BuildContext context, int index) {
                return _pages[index % _pages.length];
              },
              itemCount: _pages.length,
              onPageChanged: (int page) {
                setState(() {
                  _activePage = page;
                });
              },
            ),
            _activePage == 1
                ? Container()
                : Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List<Widget>.generate(
                            _pages.length,
                            (index) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: InkWell(
                                      onTap: () {
                                        _pageController.animateToPage(index,
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeIn);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(5)),
                                            color: _activePage == index
                                                ? const Color.fromARGB(
                                                    255, 37, 132, 241)
                                                : Colors.grey),
                                        width: 50,
                                        height: 10,
                                      )),
                                )),
                      ),
                    ),
                  ),
          ],
        ));
  }
}

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.1,
                horizontal: MediaQuery.of(context).size.width * 0.01),
            child: const Image(image: AssetImage('images/img_welcome.png'))),
        Text(Singleton().appName, style: Theme.of(context).textTheme.displayLarge),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Text(
            "Your phone will not be out of credits anymore!",
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }
}
