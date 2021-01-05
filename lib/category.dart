import 'package:flutter/material.dart';
import 'package:one/unit.dart';

class Category {
  final ColorSwatch color;
  final String iconLoc;
  final String name;
  final List<Unit> units;

  Category({
    @required this.color,
    @required this.iconLoc,
    @required this.name,
    @required this.units,
  })  : assert(color != null),
        assert(iconLoc != null),
        assert(name != null),
        assert(units != null);
}
