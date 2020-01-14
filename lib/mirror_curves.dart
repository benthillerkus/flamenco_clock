import 'package:flutter/animation.dart';

class MirrorCurve extends Curve {
  final Curve curve;
  const MirrorCurve(this.curve) : super();

  @override
  double transformInternal(double t) => t <= .5 ? curve.transformInternal(t) : curve.transformInternal(-t);
}