import 'dart:io';

Future<String> getMacAddress(String ip) async {
  try {
    final result = await File('/proc/net/arp').readAsString();
    final lines = result.split('\n');
    for (var line in lines) {
      if (line.contains(ip)) {
        final partes = line.split(RegExp(r'\s+'));
        if (partes.length >= 4) return partes[3].toUpperCase();
      }
    }
  } catch (e) {
    return "Restringido";
  }
  return "No encontrada";
}
