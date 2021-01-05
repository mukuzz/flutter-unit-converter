import 'dart:io';
import 'dart:convert' show utf8, json;

import 'package:one/unit.dart';

class Api {
  final httpClient = HttpClient();
  final url = "flutter.udacity.com";

  Future<List<Unit>> getUnits(String category) async {
    final uri = Uri.https(url, '/$category');
    final jsonData = await _getJson(uri);
    if (jsonData == null || jsonData['units'] == null) {
      return null;
    }

    List<Unit> units = [];
    for (int i = 0; i < jsonData['units'].length; i++) {
      if (jsonData['units'][i] is! Map) print('OOPS');
      units.add(Unit.fromJson(jsonData['units'][i]));
    }
    return units;
  }

  Future<double> convert(
      String category, String fromUnit, String toUnit, String amount) async {
    final uri = Uri.https(url, '/$category/convert',
        {'amount': amount, 'from': fromUnit, 'to': toUnit});

    final jsonData = await _getJson(uri);
    if (jsonData == null || jsonData['status'] == 'error') {
      return null;
    }
    return jsonData['conversion'].toDouble();
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final httpRequest = await httpClient.getUrl(uri);
      final httpResponse = await httpRequest.close();
      if (httpResponse.statusCode != HttpStatus.ok) {
        return null;
      }
      final responseBody = await httpResponse.transform(utf8.decoder).join();
      return json.decode(responseBody);
    } on Exception catch (e) {
      print('$e');
      return null;
    }
  }
}
