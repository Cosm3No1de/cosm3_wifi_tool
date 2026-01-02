import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/device_model.dart';

class HistoryServiceHelper {
  static const String _fileName = 'scan_history.json';

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_fileName';
  }

  Future<void> saveScan(List<DispositivoRed> devices) async {
    final path = await _getFilePath();
    final file = File(path);
    List<dynamic> currentHistory = [];
    if (await file.exists()) {
      try {
        currentHistory = jsonDecode(await file.readAsString());
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    final newEntry = {
      'date': DateTime.now().toIso8601String(),
      'devices': devices
          .map(
            (d) => {
              'ip': d.ip,
              'nombre': d.nombre,
              'mac': d.mac,
              'vendedor': d.vendedor,
            },
          )
          .toList(),
    };

    currentHistory.insert(0, newEntry); 
    if (currentHistory.length > 50) {
      currentHistory = currentHistory.sublist(0, 50);
    }
    await file.writeAsString(jsonEncode(currentHistory));
  }

  Future<List<Map<String, dynamic>>> loadHistory() async {
    final path = await _getFilePath();
    final file = File(path);
    if (!await file.exists()) return [];
    try {
      final data = jsonDecode(await file.readAsString());
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return [];
    }
  }

  Future<void> clearHistory() async {
    final path = await _getFilePath();
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
