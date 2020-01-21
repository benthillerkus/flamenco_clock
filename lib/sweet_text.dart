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
        blurRadius: 3,
        offset: Offset(0, 3),
        color: Color.fromRGBO(78, 63, 93, .1)),
    Shadow(
        blurRadius: 7,
        offset: Offset(0, 4),
        color: Color.fromRGBO(78, 63, 93, .2)),
    Shadow(
        blurRadius: 14,
        offset: Offset(0, 7),
        color: Color.fromRGBO(78, 63, 93, .28)),
    Shadow(
        blurRadius: 18.19,
        offset: Offset(0, 15.96),
        color: Color.fromRGBO(78, 63, 93, .5562)),
    Shadow(
        blurRadius: 30.5,
        offset: Offset(0, 30.8),
        color: Color.fromRGBO(78, 63, 93, .6309)),
    Shadow(
        blurRadius: 51.94,
        offset: Offset(0, 53.93),
        color: Color.fromRGBO(78, 63, 93, .705)),
    Shadow(
        blurRadius: 91.73,
        offset: Offset(0, 91.78),
        color: Color.fromRGBO(78, 63, 93, .7996)),
    Shadow(blurRadius: 167, offset: Offset(0, 173), color: Color(0xFF4E3F5D)),
  ];
  static var noShadow = const <Shadow>[
    Shadow(blurRadius: 0, offset: Offset(0, 0), color: Color(0x104E3F7D)),
    Shadow(blurRadius: 0, offset: Offset(0, 0), color: Color(0x244E3F7D)),
    Shadow(blurRadius: 0, offset: Offset(0, 0), color: Color(0x354E3F7D)),
    Shadow(blurRadius: 0, offset: Offset(0, 0), color: Color(0x404E3F7D)),
    Shadow(blurRadius: 0, offset: Offset(0, 0), color: Color(0x504E3F7D)),
    Shadow(blurRadius: 0, offset: Offset(0, 0), color: Color(0x604E3F7D)),
    Shadow(blurRadius: 0, offset: Offset(0, 0), color: Color(0x704E3E7F)),
    Shadow(blurRadius: 0, offset: Offset(0, 0), color: Color(0x904E358D)),
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
      curve: Curves.bounceIn,
      padding: EdgeInsets.only(top: _top),
      child: Center(
        child: TweenAnimationBuilder<List<Shadow>>(
          tween: ShadowListTween(begin: _begin, end: _end),
          duration: transitionLength,
          curve: Curves.easeIn,
          builder: (context, shadows, child) {
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _opacity,
              curve: Curves.ease,
              child: Text(_value,
                  style: TextStyle(
                      color: const Color(0xFFE5CAE9),
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
    widget.controller.add(Event(transitionIn));
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
      _top = 5.0;
    });
  }
}

extension on Random {
  Color nextColor() => HSLColor.lerp(HSLColor.fromAHSL(1, 0, .5, .8),
          HSLColor.fromAHSL(1, 360, .5, .5), nextDouble())
      .toColor();
}
