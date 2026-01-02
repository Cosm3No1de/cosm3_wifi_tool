import 'dart:io';

class SubdomainHelper {
  Future<List<String>> lookup(String host) async {
    try {
      final listaIps = await InternetAddress.lookup(host);
      return listaIps.map((e) => e.address).toList();
    } catch (_) {
      return [];
    }
  }
}
