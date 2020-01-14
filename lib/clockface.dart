import 'package:flamenco_clock/now.dart';
import 'package:flamenco_clock/sweet_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as Intl;

class FlamencoClock extends StatefulWidget {
  final ClockModel model;

  FlamencoClock(this.model);

  @override
  _FlamencoClockState createState() => _FlamencoClockState();
}

class _FlamencoClockState extends State<FlamencoClock> {
  final Now now = Now(Intl.DateFormat.HOUR24_MINUTE_SECOND);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    return ChangeNotifierProvider<ClockModel>.value(
      value: widget.model,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE9EFF5), Color(0xFFEAD0E3)]),
          ),
          child: Center(
            child: AspectRatio(
                aspectRatio: 5 / 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 40, horizontal: 50),
                      child: SweetText(now.notifiers),
                    ),
                    Consumer<ClockModel>(
                        builder: (context, model, child) =>
                            Text(model.weatherString))
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
