import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class Now {
  DateTime get raw => _now;
  String get formatted => DateFormat(format).format(_now);

  static DateTime _now = DateTime.now();
  final String format;
  final Duration preUpdateNotificationOffset;

  List<ClockLetterNotifier> notifiers = [];

  Now(this.format, this.preUpdateNotificationOffset) {
    formatted.split('').forEach((string) {
      notifiers.add(ClockLetterNotifier(string, preUpdateNotificationOffset));
    });
    _update();
  }

  void _tick() {
    var nextUpdate = Duration(seconds: 1) -
        Duration(milliseconds: DateTime.now().millisecond);
    Timer(nextUpdate, _update);
    Timer(nextUpdate - preUpdateNotificationOffset, () {
      notifiers.forEach((ClockLetterNotifier notifier) {
        notifier.toggleState();
      });
    });
  }

  void _update() {
    _now = DateTime.now();
    formatted
        .split('')
        .forEachIndex((string, index) => notifiers[index].value = string);
    _tick();
  }
}

class ClockLetterNotifier extends ValueNotifier<String> {
  ClockLetterNotifier(String value, this.preUpdateNotificationOffset)
      : super(value);

  bool get isBetweenUpdates => _isBetweenUpdates;
  bool _isBetweenUpdates = false;

  final Duration preUpdateNotificationOffset;

  void toggleState() {
    _isBetweenUpdates = !_isBetweenUpdates;
    notifyListeners();
  }
}

extension<E> on Iterable<E> {
  void forEachIndex(void f(E element, int index)) {
    int index = 0;
    for (var element in this) {
      f(element, index);
      index++;
    }
  }
}
