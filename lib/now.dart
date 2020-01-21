import 'package:flamenco_clock/sequence.dart';
import 'package:intl/intl.dart';

import 'sweet_text.dart';

class Now implements SweetTextManager {
  var _timeStep = const Duration(seconds: 1);
  Sequence _timer;
  @override
  List<Sequence> controllers = List.generate(
      formatToList(DateTime.now()).length, (int index) => Sequence.empty(),
      growable: false);

  @override
  String Function(int index) getValueOfLetter =
      (index) => formatToList(DateTime.now())[index];

  Now() {
    _timer = Sequence([Event(Duration(), _update)])
      ..call(period: timeStep, startIn: untilNextTimeStep);
  }

  /// The [Duration] between each [_update()].
  Duration get timeStep => _timeStep;

  /// The [Duration] until the next [_update()] happens.
  Duration get untilNextTimeStep => Duration(
      milliseconds: _timeStep.inMilliseconds - DateTime.now().millisecond);

  void deactivate() => _timer?.deactivate();

  /// Run every Sequence that will have it's associated value / char changed.
  void _update() {
    var now = DateTime.now();
    var soon = now.add(_timeStep + Duration(milliseconds: 100));
    var nowFormatted = formatToList(now);
    var soonFormatted = formatToList(soon);

    nowFormatted
        .indeciesOfDifferences(soonFormatted)
        .map(((int index) => controllers[index]))
        .forEach((sequence) async {
      sequence.call(startIn: untilNextTimeStep);
    });
  }

  static List<String> formatToList(DateTime date) =>
      DateFormat.Hms().format(date).split('');
}

extension<T> on List<T> {
  /// Generates a [List<int>] of every index where the content
  /// of both [List]s is not the same.
  Iterable<int> indeciesOfDifferences(List<T> other) sync* {
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
