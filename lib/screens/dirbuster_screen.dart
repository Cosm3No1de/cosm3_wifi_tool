import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme.dart';
import '../services/localization_service.dart';

class PantallaDirBuster extends StatefulWidget {
  const PantallaDirBuster({super.key});
  @override
  State<PantallaDirBuster> createState() => _PantallaDirBusterState();
}

class _PantallaDirBusterState extends State<PantallaDirBuster> {
  final _urlCtrl = TextEditingController(text: "http://");
  final ScrollController _scroll = ScrollController();
  String _log = "";
  bool _buscando = false;

  final List<String> _rutas = [
    "admin",
    "login",
    "dashboard",
    "config",
    ".env",
    "backup.zip",
    "robots.txt",
    "phpinfo.php",
    "test",
    "upload",
    "db.sql",
    "sitemap.xml",
    ".git/config",
    "wp-admin",
  ];

  @override
  void initState() {
    super.initState();
    _log = "${LanguageService().translate('dirbuster_waiting_log')}\n";
  }

  void _addLog(String t) {
    setState(() => _log += "$t\n");
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  Future<void> _escanearDirectorios() async {
    String base = _urlCtrl.text.trim();
    if (!base.startsWith("http")) base = "http://$base";
    if (base.endsWith("/")) base = base.substring(0, base.length - 1);

    setState(() {
      _buscando = true;
      _log = "${LanguageService().translate('dirbuster_starting_log')} $base\n";
    });

    for (String ruta in _rutas) {
      if (!_buscando) break;
      String target = "$base/$ruta";
      _addLog("${LanguageService().translate('testing_log')} /$ruta");
      try {
        final response = await http.get(Uri.parse(target));
        if (response.statusCode == 200) {
          _addLog("${LanguageService().translate('found_200_log')} $target");
        } else if (response.statusCode == 403) {
          _addLog(
            "${LanguageService().translate('forbidden_403_log')} $target",
          );
        }
      } catch (e) {
        debugPrint(e.toString());
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    _addLog("\n${LanguageService().translate('scan_finished_log')}");
    setState(() => _buscando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            LanguageService().translate('dirbuster_title'),
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _urlCtrl,
                  decoration: InputDecoration(
                    labelText: LanguageService().translate('url_base_label'),
                    prefixIcon: const Icon(Icons.folder_open),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _buscando
                    ? () => setState(() => _buscando = false)
                    : _escanearDirectorios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buscando ? Colors.grey : Colors.redAccent,
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
                  color: Colors.redAccent.withValues(alpha: 0.5),
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
