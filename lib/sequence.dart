import 'dart:async';

typedef VoidCallback = void Function();

/// TODO Make Events mutable again and have the Sequence update on change.
/// TODO Use proper asynchronous programming for the Sequence.
/// TODO Unfuck the code
/// TODO Improve usability & add features such as
///   muting callbacks
///   reversing playback
///   adding and removing Events from Sequence
///   maybe add debugging functionality that says which events are currently being fired?
///     I guess that means Streams?

/// A list of [Event]s relative to a specific point in time. (Let's call it [Point 0])
///
/// You can use [call()] to play the sequence in a loop.
/// Negative [Duration]s mean that the [Event] will played before [Time 0].
class Sequence {
  /// Stores the [Event]s that will be run.
  List<Event> _events;

  /// Returns how long the [Sequence] goes before [Point 0]. Negative if there are [Event]s before [Point 0].
  Duration get startOffset => _startOffset;
  Duration _startOffset;

  /// The length of one run through the [Sequence].
  Duration get length => _length;
  Duration _length;

  /// The amount of times the [Sequence] has been repeated since the last time it has been cancelled with [cancel()].
  int get ticks => _driver != null ? _driver.tick : 0;

  /// This [Timer] is responsible for repeating the sequence.
  Timer _driver;

  /// When the [Sequence] [isRunning] this holds all of the [Timer] instances.
  List<Timer> _timers = [];

  /// Returns whether or not a sequence is currently playing.
  bool get isRunning => _isRunning;
  bool _isRunning = false;

  Sequence(this._events) {
    _events.sort();
    _startOffset = -_events.first.offset;
    // Offsets the List so that the first Duration starts at 0;
    // Also the [Event]s are being copied, so no one can interfere for now
    _events.map((event) => event.move(startOffset));

    _length = _events.last.offset;
  }

  /// Cancels any ongoing [Timer]s and stops the [Sequence] from playing.
  void cancel() {
    _driver?.cancel();
    _timers?.forEach((timer) => timer.cancel());
    _isRunning = false;
    _timers = <Timer>[];
    _driver = null;
  }

  /// Starts the Sequence, so that at [startIn] an [Event] with 0 [offset] would be played.
  ///
  /// Returns [false] if the input is invalid.
  /// A negative [startIn] means that [Point 0] has already passed.
  bool call({Duration startIn, Duration period}) {
    // Make sure the full spiel can happen.
    if (isRunning) return false;
    // if (period <= length) return false;
    // if (startIn <= startOffset) return null;

    // Find the [Event] that should be played first.
    int nextEventIndex = _nextEventIndex(startIn);
    // Maybe the [Sequence] has to be wrapped around it's [period] first.
    if (nextEventIndex == -1)
      nextEventIndex = _nextEventIndex(startIn + period);
    // However having [startIn]s that are farer than one [period] away in the past aren't supported.
    if (nextEventIndex == -1) return false;

    _isRunning = true;
    // Start a periodic Timer in [startIn]
    if (nextEventIndex == 0) {
      // Wait for the Sequence to start
      _driver = Timer(startIn + startOffset, () {
        // Play the Sequence
        _driver = Timer.periodic(period, _startSequence);
        return true;
      });
    } else {
      // Wait for the [nextEvent] to come.
      _driver =
          Timer(startIn + startOffset + _events[nextEventIndex].offset, () {
        // Play starting at the [nextEvent].
        _startSequence(_driver, nextEventIndex);
        // Wait for the next full [Sequence] to begin.
        _driver = Timer(period - _events[nextEventIndex].offset, () {
          // Play that full [Sequence].
          _startSequence(_driver);
          // Start looping.
          _driver = Timer.periodic(period, _startSequence);
        });
      });
      return true;
    }
    return false; // Shut up, Dart Analyzer
  }

  /// Find the [Event] that should be started next, based on [startIn].
  int _nextEventIndex(Duration startIn) =>
      _events.indexWhere((event) => event.offset > -(startIn - startOffset));

  /// Populates [_timers] with instances of [Timer] that will fire each [Event] in [_events].
  ///
  /// [startAtIndex] can be used to start the Sequence at a specific [Event] rather than the first.
  /// Since the first [Event] will start immediately, it is being filtered out and started seperately.
  void _startSequence(Timer t, [int startAtIndex = 0]) {
    if (startAtIndex == 0) {
      _timers
          .addAll(_events.skip(1)?.map((event) => event.toTimer())?.toList());
      _events.first.callback();
    } else {
      // Apply an additional offset on to the [Event]s to even out the later start.
      var offset = _events[startAtIndex];
      _timers.addAll(_events
          .skip(startAtIndex + 1)
          ?.map((event) => Timer(event.offset - offset.offset, event.callback))
          ?.toList());
      // Play the left out [Event] seperately.
      _events[startAtIndex].callback();
    }
    // Cleanup by removing inactive [Timer]
    _timers.removeWhere((Timer timer) => !timer.isActive);
  }
}

/// Basically a Timer that hasn't started yet.
class Event implements Comparable {
  final Duration offset;
  final VoidCallback callback;

  const Event(this.offset, this.callback);

  /// Returns a new [Event], but offset by [offset].
  Event move(Duration offset) => Event(offset + this.offset, callback); 

  /// Returns a new [Timer] that will fire [callback] in [offset].
  Timer toTimer() => Timer(offset, callback);

  @override

  /// Sorts by [offset], negative [Duration]s are smaller.
  int compareTo(other) => offset.compareTo(other.offset);
}
