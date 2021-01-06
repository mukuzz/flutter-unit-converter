import 'package:flutter/material.dart';
import 'package:one/unit.dart';
import 'package:one/category.dart';

import 'api.dart';

class UnitConverter extends StatefulWidget {
  final Category category;

  const UnitConverter({
    @required this.category,
  }) : assert(category != null);

  @override
  _UnitConverterState createState() => _UnitConverterState();
}

class _UnitConverterState extends State<UnitConverter> {
  Unit _fromUnit;
  Unit _toUnit;
  double _inputValue;
  String _convertedValue = '';
  List<DropdownMenuItem> _unitMenuItems = [];
  bool _showValidationErrors = false;
  final _inputKey = GlobalKey(debugLabel: 'inputText');
  bool _showErrorUI = false;

  @override
  void initState() {
    _createDropdownMenuItems();
    _setDefaults();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant UnitConverter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.category != oldWidget.category) {
      _createDropdownMenuItems();
      _setDefaults();
    }
    _updateConversion();
  }

  void _createDropdownMenuItems() {
    var unitMenuItems = widget.category.units.map((unit) {
      return DropdownMenuItem(
        child: Text(
          unit.name,
          softWrap: true,
        ),
        value: unit.name,
      );
    }).toList();
    setState(() {
      _unitMenuItems = unitMenuItems;
    });
  }

  void _setDefaults() {
    setState(() {
      _fromUnit = widget.category.units[0];
      _toUnit = widget.category.units[1];
      _showErrorUI = false;
    });
  }

  void _updateFromConversionUnit(dynamic unitName) {
    setState(() {
      _fromUnit = widget.category.units.firstWhere(
        (Unit u) => u.name == unitName,
        orElse: null,
      );
      _updateConversion();
    });
  }

  void _updateToConversionUnit(dynamic unitName) {
    setState(() {
      _toUnit = widget.category.units.firstWhere(
        (Unit u) => u.name == unitName,
        orElse: null,
      );
      _updateConversion();
    });
  }

  void _updateInputValue(String input) {
    setState(() {
      if (input == null || input.isEmpty) {
        _convertedValue = '';
      } else {
        try {
          final inputDouble = double.parse(input);
          _showValidationErrors = false;
          _inputValue = inputDouble;
          _updateConversion();
        } on Exception catch (e) {
          print('Error: $e');
          _showValidationErrors = true;
        }
      }
    });
  }

  void _updateConversion() {
    if (_inputValue != null) {
      if (widget.category.name == 'Currency') {
        Api()
            .convert(
              'currency',
              _fromUnit.name,
              _toUnit.name,
              _inputValue.toString(),
            )
            .then(
              (value) => setState(() {
                if (value == null)
                  _showErrorUI = true;
                else {
                  _showErrorUI = false;
                  _convertedValue = value.toString();
                }
              }),
            );
      } else {
        setState(() {
          _convertedValue =
              (_inputValue * (_toUnit.conversion / _fromUnit.conversion))
                  .toStringAsPrecision(10);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showErrorUI) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: widget.category.color['error'],
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 180.0,
                  color: Colors.white,
                ),
                Text(
                  "Oh no! We can't connect right now!",
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      .copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget inputBlock = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        child: Column(
          children: [
            TextFormField(
              key: _inputKey,
              initialValue: _inputValue?.toString() ?? '',
              decoration: InputDecoration(
                labelText: 'Input',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(fontSize: 32),
                errorText:
                    _showValidationErrors ? 'Invalid number entered' : null,
              ),
              style: Theme.of(context).textTheme.headline4,
              keyboardType: TextInputType.number,
              onChanged: _updateInputValue,
            ),
            Container(
              margin: EdgeInsets.only(top: 16.0),
              child: DropdownButtonFormField(
                items: _unitMenuItems,
                value: _fromUnit.name,
                onChanged: _updateFromConversionUnit,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Widget outputBlock = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          InputDecorator(
            child: Text(
              _convertedValue,
              style: Theme.of(context).textTheme.headline4,
            ),
            decoration: InputDecoration(
              labelText: 'Output',
              border: OutlineInputBorder(),
              labelStyle: TextStyle(fontSize: 32),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 16.0),
            child: DropdownButtonFormField(
              items: _unitMenuItems,
              value: _toUnit.name,
              onChanged: _updateToConversionUnit,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );

    Widget portraitUI = ListView(
      padding: EdgeInsets.all(16.0),
      children: <Widget>[
        inputBlock,
        RotatedBox(
          quarterTurns: 1,
          child: Icon(Icons.compare_arrows, size: 40.0),
        ),
        outputBlock,
      ],
    );

    Widget landscapeUI = ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Expanded(flex: 1, child: inputBlock),
            Icon(Icons.compare_arrows, size: 40.0),
            Expanded(flex: 1, child: outputBlock),
          ],
        )
      ],
    );

    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    Widget unitConverterUI;
    if (isPortrait)
      unitConverterUI = portraitUI;
    else
      unitConverterUI = landscapeUI;

    return unitConverterUI;
  }
}
