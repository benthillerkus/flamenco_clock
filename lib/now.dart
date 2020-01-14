import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class Now {
  static DateTime _now = DateTime.now();
  final String format;
  
  List<ValueNotifier<String>> notifiers = [];
  Now(this.format) {
    formatted.split('').forEach((string) {notifiers.add(ValueNotifier(string));});
    _update();
  }
  
  String get formatted => DateFormat(format).format(_now);

  DateTime get raw => _now;

  void _tick() {
    Timer(
        Duration(seconds: 1) -
            Duration(milliseconds: DateTime.now().millisecond),
        _update);
  }

  void _update() {
    _now = DateTime.now();
    formatted
        .split('')
        .forEachIndex((string, index) => notifiers[index].value = string);
    _tick();
  }
}

extension <E> on Iterable<E> {
  void forEachIndex(void f(E element, int index)) {
    int index = 0;
    for (var element in this) {f(element, index); index++;} 
  }
}
