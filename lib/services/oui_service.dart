import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class OUIService {
  static final OUIService _instance = OUIService._internal();
  factory OUIService() => _instance;
  OUIService._internal();

  Map<String, String> _ouiMap = {};
  bool _loaded = false;

  Future<void> loadOUIData() async {
    if (_loaded) return;
    try {
      final String jsonString = await rootBundle.loadString('assets/oui.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _ouiMap = jsonMap.map(
        (key, value) => MapEntry(key.toUpperCase(), value.toString()),
      );
      _loaded = true;
    } catch (e) {
      debugPrint("Error loading OUI data: $e");
    }
  }

  String? lookup(String mac) {
    if (mac.length < 8) return null;
    // MAC format usually AA:BB:CC:DD:EE:FF
    // OUI is the first 3 bytes (AA:BB:CC)
    final prefix = mac.substring(0, 8).toUpperCase();
    return _ouiMap[prefix];
  }
}
