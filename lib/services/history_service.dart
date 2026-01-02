import '../models/device_model.dart';
import 'history_service_helper_web.dart'
    if (dart.library.io) 'history_service_helper_io.dart';

class HistoryService {
  final _helper = HistoryServiceHelper();

  Future<void> saveScan(List<DispositivoRed> devices) async {
    await _helper.saveScan(devices);
  }

  Future<List<Map<String, dynamic>>> loadHistory() async {
    return await _helper.loadHistory();
  }

  Future<void> clearHistory() async {
    await _helper.clearHistory();
  }
}
