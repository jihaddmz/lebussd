import 'package:flutter/material.dart';
import 'package:lebussd/colors.dart';

class OptionsSelector extends StatefulWidget {
  List<String> list;
  Function(String) onTap;

  OptionsSelector({Key? key, required this.list, required this.onTap})
      : super(key: key);

  @override
  _OptionsSelector createState() => _OptionsSelector();
}

class _OptionsSelector extends State<OptionsSelector> {
  List<String> _selectedOptions = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedOptions.add(widget.list[0]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items(),
    );
  }

  List<Widget> items() {
    List<Widget> widgets = [];

    List.generate(widget.list.length, (index) {
      String current = widget.list[index];

      widgets.add(Expanded(
          child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedOptions.clear();
            _selectedOptions.add(current);
            widget.onTap(current);
          });
        },
        child: Card(
          color: _selectedOptions.contains(current)
              ? primaryColor
              : secondaryColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              children: [
                Visibility(
                    visible: _selectedOptions.contains(current),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                    )),
                Expanded(
                  child: Text(
                    current,
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
        ),
      )));
    });

    return widgets;
  }
}
