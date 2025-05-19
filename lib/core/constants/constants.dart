import 'package:flutter/cupertino.dart';

extension CustomColorOpacity on Color {
  Color customOpacity(double opacity) {
    return withAlpha((opacity * 255).toInt());
  }
}