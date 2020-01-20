import 'dart:async';

import 'package:flamenco_clock/sequence.dart';
import 'package:intl/intl.dart';
import 'sweet_text.dart';

extension on List<String> {
  /// Generates a [List<int>] of every index where the content
  /// of both [List]s is not the same.
  Iterable<int> indeciesOfDifferences(List<String> other) sync* {
    var a = this.iterator;
    var b = other.iterator;
    var index = 0;
    while (a.moveNext() && b.moveNext()) {
      if (a.current != b.current) {
        yield index;
      }
      index++;
    }
  }
}

class Now implements SweetTextManager {
  Duration get timeStep => _timeStep;
  var _timeStep = const Duration(seconds: 1);
  Timer _timer;

  Now() {
    _timer = Timer.periodic(timeStep, (timer) => _update());
  }

  /// Run every Sequence that will have it's associated value / char changed.
  void _update() {
    var now = DateTime.now();
    var soon = now.add(_timeStep);
    var nowFormatted = formatToList(now);
    var soonFormatted = formatToList(soon);

    for (int index in nowFormatted.indeciesOfDifferences(soonFormatted)) {
      controllers[index].call(
          startIn: Duration(
              milliseconds:
                  _timeStep.inMilliseconds - DateTime.now().millisecond));
    }
  }

  void cancel() => _timer?.cancel();

  static List<String> formatToList(DateTime date) =>
      DateFormat.Hms().format(date).split('');

  @override
  List<Sequence> controllers = List.generate(
      formatToList(DateTime.now()).length, (int index) => Sequence.empty(),
      growable: false);

  @override
  String Function(int index) getValueOfLetter =
      (index) => formatToList(DateTime.now())[index];
}
