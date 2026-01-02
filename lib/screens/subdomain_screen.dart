import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/localization_service.dart';
import '../utils/subdomain_helper_web.dart'
    if (dart.library.io) '../utils/subdomain_helper_io.dart';

class PantallaSubdominios extends StatefulWidget {
  const PantallaSubdominios({super.key});
  @override
  State<PantallaSubdominios> createState() => _PantallaSubdominiosState();
}

class _PantallaSubdominiosState extends State<PantallaSubdominios> {
  final _dominioCtrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  String _log = "";
  bool _buscando = false;
  final _helper = SubdomainHelper();

  final List<String> _diccionario = [
    "www",
    "mail",
    "remote",
    "blog",
    "webmail",
    "server",
    "ns1",
    "ns2",
    "smtp",
    "secure",
    "vpn",
    "m",
    "shop",
    "ftp",
    "admin",
    "portal",
    "dev",
    "test",
    "cloud",
    "api",
    "cdn",
    "staging",
    "app",
    "support",
    "status",
    "docs",
    "chat",
  ];

  @override
  void initState() {
    super.initState();
    _log = "${LanguageService().translate('waiting_target_log')}\n";
  }

  void _addLog(String t) {
    setState(() => _log += "$t\n");
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  Future<void> _fuerzaBruta() async {
    if (kIsWeb) {
      _addLog(
        "Web Mode: DNS lookup restricted. Use native app for full features.",
      );
      return;
    }
    String dominio = _dominioCtrl.text.trim();
    if (dominio.isEmpty) return;
    setState(() {
      _buscando = true;
      _log = "${LanguageService().translate('starting_attack_log')} $dominio\n";
    });

    int encontrados = 0;
    for (String sub in _diccionario) {
      if (!_buscando) break;
      String objetivo = "$sub.$dominio";
      _addLog("${LanguageService().translate('testing_log')} $objetivo...");
      try {
        final addresses = await _helper.lookup(objetivo);
        if (addresses.isNotEmpty) {
          _addLog(
            "${LanguageService().translate('found_log')} $objetivo -> ${addresses.first}",
          );
          encontrados++;
        }
      } catch (e) {
        debugPrint(e.toString());
      }
      await Future.delayed(const Duration(milliseconds: 50));
    }
    _addLog("\n${LanguageService().translate('finished_log')} $encontrados");
    setState(() => _buscando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            LanguageService().translate('subdomain_title'),
            style: const TextStyle(
              color: Colors.orangeAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _dominioCtrl,
                  decoration: InputDecoration(
                    labelText: LanguageService().translate('domain_hint'),
                    prefixIcon: const Icon(Icons.travel_explore),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _buscando
                    ? () => setState(() => _buscando = false)
                    : _fuerzaBruta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buscando ? Colors.red : Colors.orange,
                  padding: const EdgeInsets.all(15),
                ),
                child: Icon(_buscando ? Icons.stop : Icons.play_arrow),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.orangeAccent.withValues(alpha: 0.5),
                ),
              ),
              child: SingleChildScrollView(
                controller: _scroll,
                child: Text(
                  _log,
                  style: const TextStyle(
                    fontFamily: "Courier",
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
