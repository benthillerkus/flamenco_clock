import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

class ShadowListTween extends Tween<List<Shadow>> {
  ShadowListTween({List<Shadow> begin, List<Shadow> end}) : super(begin: begin, end: end);

  @override lerp(double t) => Shadow.lerpList(begin, end, t);
}

class ShadowTween extends Tween<Shadow> {
  ShadowTween({Shadow begin, Shadow end}) : super(begin: begin, end: end);

  @override lerp(double t) => Shadow.lerp(begin, end, t);
}
