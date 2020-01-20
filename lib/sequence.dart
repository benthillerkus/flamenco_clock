import 'dart:async';

import 'package:meta/meta.dart';

typedef VoidCallback = void Function();

/// TODO write tests lol
/// TODO Make Events mutable again and have the Sequence update on change.
///   this might actually work though haha
/// TODO Use proper asynchronous programming for the Sequence.
/// TODO Unfuck the code
/// TODO Improve usability & add features such as
///   muting callbacks
///   reversing playback
///   maybe add debugging functionality that says which events are currently being fired?
///     I guess that means Streams?

/// A list of [Event]s relative to a specific point in time.
/// (Let's call it [Point 0])
///
/// You can use [call()] to play the sequence in a loop.
/// Negative [Duration]s mean that the [Event] will played before [Time 0].
class Sequence {
  /// Stores the [Event]s that will be run.
  List<Event> get events => List.unmodifiable(_events);
  final List<Event> _events = [];

  /// Returns how long the [Sequence] goes before [Point 0].
  /// Negative if there aren't [Event]s before [Point 0].
  Duration get startOffset => _startOffset;
  Duration _startOffset;

  /// The length of one run through the [Sequence].
  Duration get length => _length;
  Duration _length;

  /// The amount of times the [Sequence] has been repeated
  /// since the last time it has been cancelled with [cancel()].
  int get ticks => _driver != null ? _driver.tick : 0;

  /// This [Timer] is responsible for repeating the sequence.
  Timer _driver = null;

  /// When the [Sequence] [isRunning] this holds all of the [Timer] instances.
  final List<Timer> _timers = [];

  /// Returns whether or not a sequence is currently playing.
  bool get isRunning => _isRunning;
  bool _isRunning = false;

  /// Construct a [Sequence] from a [List] of [Event]s
  Sequence(List<Event> events) {
    _events.addAll(events);
    events.forEach((event) => event.registerSequence(this));
    updateTimings();
  }

  /// Create an empty [Sequence].
  Sequence.empty();

  /// Adds a single [Event] to the [Sequence].
  void add(Event event) {
    _events.add(event);
    event.registerSequence(this);
    updateTimings();
  }

  /// Removes a single [Event] from the [Sequence].
  void remove(Event event) {
    _events.remove(event);
    event.unregisterSequence(this);
    updateTimings();
  }

  /// Recalculates the in- and outpoints.
  ///
  /// There is no need for you to touch this.
  void updateTimings() {
    _events.sort();
    _startOffset = -_events.first.offset;
    _length = _events.last.offset + _startOffset;
  }

  /// Cancels any ongoing [Timer]s and stops the [Sequence] from playing.
  void cancel() {
    _driver?.cancel();
    _timers?.forEach((timer) => timer.cancel());
    _isRunning = false;
    _timers.clear();
    _driver = null;
  }

  /// Makes this removable by GC
  ///
  /// Cancels any ongoing [Timer]s,
  /// stops the [Sequence] and removes all [Event]s.
  void destruct() {
    cancel();
    var tempCopies = _events.toList(growable: false);
    _events.clear();
    tempCopies.forEach((event) => event.unregisterSequence(this));
  }

  /// Starts this [Sequence],
  ///
  /// so that at [startPoint] an [Event] with 0 [offset] would be played.
  /// This is a wrapper for [call()].
  bool startAt(
          {@required DateTime startPoint,
          Duration period = const Duration()}) =>
      call(startIn: DateTime.now().difference(startPoint), period: period);

  /// Starts the [Sequence],
  ///
  /// so that at [startIn] an [Event] with 0 [offset] would be played.
  /// Returns [false] if the input is invalid.
  /// A negative [startIn] means that [Point 0] has already passed.
  bool call({@required Duration startIn, Duration period = const Duration()}) {
    if (isRunning) return false;

    var isPeriodic = period != const Duration();

    // Find the [Event] that should be played first.
    var nextEventIndex = _nextEventIndex(startIn);
    // Maybe the [Sequence] has to be wrapped around it's [period] first.
    if (nextEventIndex == -1) {
      nextEventIndex = _nextEventIndex(startIn + period);
    }
    // However having [startIn]s that are farer than one [period] away
    // in the past aren't supported.
    if (nextEventIndex == -1) return false;

    _isRunning = true;
    // Start a periodic Timer in [startIn]
    if (nextEventIndex == 0) {
      // Wait for the Sequence to start
      _driver = Timer(startIn + startOffset, () {
        // Play that full [Sequence].
        _startSequence(_driver);
        // Play the Sequence
        if (isPeriodic) {
          _driver = Timer.periodic(period, _startSequence);
        } else {
          _isRunning = false;
        }
        return true;
      });
    } else {
      // Wait for the [nextEvent] to come.
      _driver = Timer(startIn + startOffset, () {
        // Play starting at the [nextEvent].
        _startSequence(_driver, nextEventIndex);
        // Wait for the next full [Sequence] to begin.
        _driver = Timer(period - _events[nextEventIndex].offset, () {
          // Play that full [Sequence].
          _startSequence(_driver);
          // Start looping.
          if (isPeriodic) {
            _driver = Timer.periodic(period, _startSequence);
          } else {
            _isRunning = false;
          }
        });
      });
      return true;
    }
    return false; // Shut up, Dart Analyzer
  }

  /// Cleanup by removing inactive [Timer]s from [_timers].
  void cleanup() async {
    _timers.removeWhere((timer) => !timer.isActive);
  }

  /// Find the [Event] that should be started next, based on [startIn].
  int _nextEventIndex(Duration startIn) =>
      _events.indexWhere((event) => event.offset > -startIn);

  /// Populates [_timers] with instances of [Timer]
  /// that will fire each [Event] in [_events].
  ///
  /// [startAtIndex] can be used to start the [Sequence]
  ///  at a specific [Event] rather than the first [Event].
  /// Since the first [Event] will start immediately,
  /// it is being filtered out and started seperately.
  void _startSequence(Timer t, [int startAtIndex = 0]) {
    if (startAtIndex == 0) {
      _timers.addAll(_events
          .skip(1)
          ?.map((event) => event.toTimer(startOffset))
          ?.toList());
      _events.first.callback();
    } else {
      // Apply an additional offset onto the [Event]s
      // to even out the later start.
      var offset = _events[startAtIndex];
      _timers.addAll(_events
          .skip(startAtIndex + 1)
          ?.map((event) =>
              Timer(event.offset - offset.offset + startOffset, event.callback))
          ?.toList());
      // Play the left out [Event] seperately.
      _events[startAtIndex].callback();
    }
    cleanup();
  }
}

/// Basically a Timer that hasn't started yet.
class Event implements Comparable {
  /// The [Duration] to [Point 0]
  Duration get offset => _offset;
  set offset(Duration offset) {
    _offset = offset;
    registeredIn.forEach((sequence) => sequence.updateTimings());
  }

  Duration _offset;

  /// Callback that should be fired when this [Event] happens.
  VoidCallback callback;

  /// All of the [Sequence]s this [Event] is part of.
  List<Sequence> get registeredIn => List.unmodifiable(_registeredIn);
  final Set<Sequence> _registeredIn = {};

  /// Internal thing that links this to a [Sequence].
  /// This is done so that the [Duration] can be updated
  /// and the [Sequence]s reflect that.
  ///
  /// You don't need this either.
  @protected
  void registerSequence(Sequence sequence) =>
      {if (sequence.events.contains(this)) _registeredIn.add(sequence)};

  /// Don't touch XD.
  @protected
  void unregisterSequence(Sequence sequence) =>
      {if (!sequence.events.contains(this)) _registeredIn.remove(sequence)};

  /// Create an [Event] offset by [offset] from [Point 0].
  Event(this._offset, this.callback);

  /// Returns a new [Timer] that will fire [callback] in [offset].
  ///
  /// [offsetFurther] offsets the [offset], but it's per default 0 anyways.
  /// [callback] is the callback being called when the [Timer] runs out.
  Timer toTimer([Duration offsetFurther = const Duration()]) =>
      Timer(offset + offsetFurther, callback);

  /// Sorts by [offset], negative [Duration]s are smaller.
  @override
  int compareTo(dynamic other) => offset.compareTo(other.offset);
}
