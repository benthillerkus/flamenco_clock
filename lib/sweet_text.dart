import 'dart:math';

import 'package:flamenco_clock/mirror_curves.dart';
import 'package:flamenco_clock/shadow_tween.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'now.dart';

extension on Random {
  Color nextColor() => HSLColor.lerp(HSLColor.fromAHSL(1, 0, .5, .8),
          HSLColor.fromAHSL(1, 360, .5, .5), nextDouble())
      .toColor();
}

class SweetText extends StatelessWidget {
  final Iterable<ClockLetterNotifier> notifiers;

  SweetText(this.notifiers);

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (var notifier in notifiers) SweetLetter(notifier)
        ]);
  }
}

class SweetLetter extends StatefulWidget {
  final ClockLetterNotifier notifier;

  SweetLetter(this.notifier);

  @override
  // _SweetLetterState createState() => _SweetLetterState();
  _SweetLetterState2 createState() => _SweetLetterState2();
}

class _SweetLetterState2 extends State<SweetLetter> {
  static var begin = const <Shadow>[
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
  static var end = const <Shadow>[
    Shadow(blurRadius: 0, offset: Offset(0, 0), color: Color(0x1A4E3F5D)),
    Shadow(blurRadius: 0, offset: Offset(0, 0), color: Color(0x334E3F5D)),
    Shadow(blurRadius: 0, offset: Offset(0, 0), color: Color(0x484E3F5D)),
    Shadow(
        blurRadius: 0,
        offset: Offset(0, 0),
        color: Color.fromRGBO(78, 63, 93, .5562)),
    Shadow(
        blurRadius: 0,
        offset: Offset(0, 0),
        color: Color.fromRGBO(78, 63, 93, .6309)),
    Shadow(
        blurRadius: 0,
        offset: Offset(0, 0),
        color: Color.fromRGBO(78, 63, 93, .705)),
    Shadow(
        blurRadius: 0,
        offset: Offset(0, 0),
        color: Color.fromRGBO(78, 63, 93, .7996)),
    Shadow(blurRadius: 0, offset: Offset(0, 0), color: Color(0xFF4E3F5D)),
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
          child: ValueListenableBuilder<String>(
        valueListenable: widget.notifier,
        builder: (context, value, child) {
          bool out = !widget.notifier.isBetweenUpdates;
          return TweenAnimationBuilder<List<Shadow>>(
            tween: ShadowListTween(begin: out ? begin : end, end: out ? end : begin),
            duration: widget.notifier.preUpdateNotificationOffset,
            // curve: const MirrorCurve(Curves.easeIn),
            curve: Curves.easeIn,
            builder: (context, shadows, child) {
              return Text(value,
                  style: TextStyle(
                      color: const Color(0xFFE5CAE9),
                      fontFamily: 'Flamenco',
                      fontSize: 150,
                      shadows: shadows));
            },
          );
        },
      )),
    );
  }
}

class _SweetLetterState extends State<SweetLetter>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableProvider<String>.value(
        value: widget.notifier,
        child: Builder(builder: (BuildContext context) {
          return Expanded(
            child: Center(
              child: _SweetLetterText(
                controller: _controller,
              ),
            ),
          );
        }));
  }

  var shadows = const <Shadow>[
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
}

class _SweetLetterText extends AnimatedWidget {
  const _SweetLetterText({Key key, AnimationController controller})
      : super(key: key, listenable: controller);

  Animation<double> get _progress => listenable;

  @override
  Widget build(BuildContext context) {
    return Text(
      Provider.of<String>(context),
      style: TextStyle(
        color: Random().nextColor(),
        fontFamily: 'Flamenco',
        fontSize: _progress.value * 150,
      ),
    );
  }
}
