import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme.dart';
import '../services/localization_service.dart';

class PantallaOsint extends StatefulWidget {
  const PantallaOsint({super.key});
  @override
  State<PantallaOsint> createState() => _PantallaOsintState();
}

class _PantallaOsintState extends State<PantallaOsint> {
  final _dominioCtrl = TextEditingController();
  String _log = "";
  bool _buscando = false;

  @override
  void initState() {
    super.initState();
    _log = LanguageService().translate('enter_domain_log');
  }

  Future<void> _consultarDNS() async {
    String dominio = _dominioCtrl.text.trim();
    if (dominio.isEmpty) return;
    setState(() {
      _buscando = true;
      _log =
          "${LanguageService().translate('consulting_dns_log')} $dominio...\n";
    });

    List<String> tipos = ['A', 'MX', 'NS', 'TXT'];
    for (String tipo in tipos) {
      try {
        final url = Uri.parse(
          'https://dns.google/resolve?name=$dominio&type=$tipo',
        );
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data.containsKey('Answer')) {
            _log += "\n--- $tipo ---\n";
            for (var registro in data['Answer']) {
              _log += "➤ ${registro['data']} (TTL: ${registro['TTL']})\n";
            }
          }
        }
      } catch (e) {
        _log += "${LanguageService().translate('error_log')} $tipo: $e\n";
      }
    }
    setState(() => _buscando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text(
            LanguageService().translate('osint_title'),
            style: const TextStyle(
              color: Colors.blueAccent,
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
                    labelText: LanguageService().translate('domain_label'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _buscando ? null : _consultarDNS,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.all(15),
                ),
                child: const Icon(Icons.check),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.blueAccent.withValues(alpha: 0.5),
                ),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _log,
                  style: const TextStyle(
                    fontFamily: "Courier",
                    color: Colors.white70,
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
