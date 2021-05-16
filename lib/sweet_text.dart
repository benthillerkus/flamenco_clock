import 'dart:math';

import 'package:flamenco_clock/sequence.dart';
import 'package:flutter/widgets.dart';

import 'shadow_tween.dart';

class SweetLetter extends StatefulWidget {
  final int index;
  final String Function(int index) valueCallback;
  final Sequence controller;

  SweetLetter(this.index, this.valueCallback, this.controller);

  @override
  _SweetLetterState createState() => _SweetLetterState();
}

class SweetText extends StatelessWidget {
  final SweetTextManager manager;
  SweetText(this.manager);

  @override
  Widget build(BuildContext context) {
    var letters = manager.controllers
        .asMap()
        .map((index, sequence) => MapEntry(
            index, SweetLetter(index, manager.getValueOfLetter, sequence)))
        .values
        .toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: letters,
    );
  }
}

abstract class SweetTextManager {
  List<Sequence> controllers;
  String Function(int index) getValueOfLetter;
}

class _SweetLetterState extends State<SweetLetter> {
  static var fullShadow = const <Shadow>[
    Shadow(
        blurRadius: 2,
        offset: Offset(0, 2),
        color: Color.fromRGBO(78, 63, 93, .06)),
    Shadow(
        blurRadius: 6,
        offset: Offset(0, 5),
        color: Color.fromRGBO(78, 63, 93, .1)),
    Shadow(
        blurRadius: 10,
        offset: Offset(0, 9),
        color: Color.fromRGBO(78, 63, 93, .13)),
    Shadow(
        blurRadius: 16,
        offset: Offset(0, 12),
        color: Color.fromRGBO(78, 63, 93, .16)),
    Shadow(
        blurRadius: 27,
        offset: Offset(0, 25),
        color: Color.fromRGBO(78, 63, 93, .2)),
    Shadow(
        blurRadius: 44,
        offset: Offset(0, 30),
        color: Color.fromRGBO(78, 63, 93, .25)),
    Shadow(
        blurRadius: 72,
        offset: Offset(0, 60),
        color: Color.fromRGBO(78, 63, 93, .35)),
    Shadow(blurRadius: 140, offset: Offset(0, 120), color: Color.fromRGBO(0, 0, 0, .41)),
  ];
  static var noShadow = const <Shadow>[
    Shadow(blurRadius: 0, offset: Offset(0, 0), color: Color(0x104E3FAD)),
    Shadow(blurRadius: 0, offset: Offset(0, 0), color: Color(0x244E3FBD)),
    Shadow(blurRadius: 0, offset: Offset(0, 0), color: Color(0x354E3FCD)),
    Shadow(blurRadius: 0, offset: Offset(0, 0), color: Color(0x404E3FDD)),
    Shadow(blurRadius: 0, offset: Offset(0, 0), color: Color(0x504E3FED)),
    Shadow(blurRadius: 0, offset: Offset(0, 0), color: Color(0x604E3FFD)),
    Shadow(blurRadius: 0, offset: Offset(0, 0), color: Color(0x704E3E1F)),
    Shadow(blurRadius: 0, offset: Offset(0, 0), color: Color(0x904E352D)),
  ];

  var _begin = noShadow;

  var _end = fullShadow;

  double _opacity = 1.0;
  double _top = 0.0;
  String _value;
  final Duration transitionLength = const Duration(milliseconds: 330);
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: AnimatedContainer(
      duration: transitionLength,
      curve: Curves.linearToEaseOut,
      padding: EdgeInsets.only(top: _top),
      child: Center(
        child: TweenAnimationBuilder<List<Shadow>>(
          tween: ShadowListTween(begin: _begin, end: _end),
          duration: transitionLength,
          curve: Curves.easeIn,
          builder: (context, shadows, child) {
            return AnimatedOpacity(
              duration: transitionLength * .4,
              opacity: _opacity,
              curve: Curves.linearToEaseOut,
              child: Text(_value,
                  style: TextStyle(
                      color: const Color.fromRGBO(255, 230, 255, 1),
                      fontFamily: 'Flamenco',
                      fontSize: 150,
                      shadows: shadows)),
            );
          },
        ),
      ),
    ));
  }

  @override
  void dispose() {
    widget.controller.deactivate();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    transitionIn();
    widget.controller.add(Event(-transitionLength, transitionOut));
    widget.controller.add(Event(Duration(), transitionIn));
    widget.controller.add(Event(
        Duration(milliseconds: -200),
        () => setState(() {
              _opacity = 0.0;
            })));
  }

  void transitionIn() {
    setState(() {
      _value = widget.valueCallback(widget.index);
      _begin = noShadow;
      _end = fullShadow;
      _opacity = 1.0;
      _top = 0.0;
    });
  }

  void transitionOut() {
    setState(() {
      _begin = fullShadow;
      _end = noShadow;
      _top = 7.0;
    });
  }
}

extension on Random {
  Color nextColor() => HSLColor.lerp(HSLColor.fromAHSL(1, 0, .5, .8),
          HSLColor.fromAHSL(1, 360, .5, .5), nextDouble())
      .toColor();
}
