import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:one/category.dart';
import 'package:one/category_tile.dart';
import 'package:one/unit.dart';
import 'package:one/backdrop.dart';
import 'package:one/unit_converter.dart';
import 'package:one/api.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _categories = <Category>[];
  Category _defaultCategory;
  Category _currentCategory;

  static const _baseColors = <ColorSwatch>[
    ColorSwatch(0xFF6AB7A8, {
      'highlight': Color(0xFF6AB7A8),
      'splash': Color(0xFF0ABC9B),
    }),
    ColorSwatch(0xFFFFD28E, {
      'highlight': Color(0xFFFFD28E),
      'splash': Color(0xFFFFA41C),
    }),
    ColorSwatch(0xFFFFB7DE, {
      'highlight': Color(0xFFFFB7DE),
      'splash': Color(0xFFF94CBF),
    }),
    ColorSwatch(0xFF8899A8, {
      'highlight': Color(0xFF8899A8),
      'splash': Color(0xFFA9CAE8),
    }),
    ColorSwatch(0xFFEAD37E, {
      'highlight': Color(0xFFEAD37E),
      'splash': Color(0xFFFFE070),
    }),
    ColorSwatch(0xFF81A56F, {
      'highlight': Color(0xFF81A56F),
      'splash': Color(0xFF7CC159),
    }),
    ColorSwatch(0xFFD7C0E2, {
      'highlight': Color(0xFFD7C0E2),
      'splash': Color(0xFFCA90E5),
    }),
    ColorSwatch(0xFFCE9A9A, {
      'highlight': Color(0xFFCE9A9A),
      'splash': Color(0xFFF94D56),
      'error': Color(0xFF912D2D),
    }),
  ];

  static const iconPaths = {
    'Length': 'assets/icons/length.png',
    'Area': 'assets/icons/area.png',
    'Currency': 'assets/icons/currency.png',
    'Digital Storage': 'assets/icons/digital_storage.png',
    'Mass': 'assets/icons/mass.png',
    'Energy': 'assets/icons/power.png',
    'Time': 'assets/icons/time.png',
    'Volume': 'assets/icons/volume.png',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_categories.isEmpty) {
      _retrieveLocalCategories().then((value) {
        Api().getUnits('currency').then((units) {
          _categories.add(
            Category(
              color: _baseColors[_baseColors.length - 1],
              iconLoc: iconPaths['Currency'],
              name: 'Currency',
              units: units ?? [],
            ),
          );
          setState(() {
            if (_categories.length > 0) {
              _defaultCategory = _categories[0];
            }
          });
        });
      });
    }
  }

  Future<void> _retrieveLocalCategories() async {
    final json = DefaultAssetBundle.of(context)
        .loadString('assets/data/regular_units.json');
    final data = JsonDecoder().convert(await json);

    if (data is! Map) {
      throw ('Data retrieved form API is not a map');
    }

    int i = 0;
    data.forEach((categoryName, categoryUnits) {
      final List<Unit> units = categoryUnits
          .map<Unit>((unitInfo) => Unit.fromJson(unitInfo))
          .toList();
      _categories.add(
        Category(
          color: _baseColors[i],
          iconLoc: iconPaths[categoryName],
          name: categoryName,
          units: units,
        ),
      );
      i = _baseColors.length - 1 == i ? 0 : i + 1;
    });
  }

  void _onCategoryTap(Category category) {
    if (category.units.length > 0)
      setState(() {
        _currentCategory = category;
      });
  }

  Widget _buildCategoriesWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 48.0),
      child: OrientationBuilder(builder: (context, orientation){
        if (orientation == Orientation.portrait) {
          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return CategoryTile(
                category: _categories[index],
                onTap: _onCategoryTap,
              );
            },
            itemCount: _categories.length,
          );
        } else {
          return GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 3.0,
            children: _categories.map((Category category) {
              return CategoryTile(
                category: category,
                onTap: _onCategoryTap,
              );
            }).toList(),
          );
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_defaultCategory == null) {
      return Center(
        child: Container(
          width: 180.0,
          height: 180.0,
          child: CircularProgressIndicator(),
        ),
      );
    }
    assert(debugCheckHasMediaQuery(context));
    return Backdrop(
      currentCategory:
          _currentCategory == null ? _defaultCategory : _currentCategory,
      frontPanel: _currentCategory == null
          ? UnitConverter(category: _defaultCategory)
          : UnitConverter(category: _currentCategory),
      backPanel: _buildCategoriesWidget(),
      frontTitle: Text('Unit Converter'),
      backTitle: Text('Select a category'),
    );
  }
}
