import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme.dart';
import '../services/localization_service.dart';

class PantallaWebSpy extends StatefulWidget {
  const PantallaWebSpy({super.key});
  @override
  State<PantallaWebSpy> createState() => _PantallaWebSpyState();
}

class _PantallaWebSpyState extends State<PantallaWebSpy> {
  final _urlCtrl = TextEditingController(text: "https://");
  String _log = "";
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _log = LanguageService().translate('enter_url_log');
  }

  Future<void> _analizarHeaders() async {
    String url = _urlCtrl.text;
    if (!url.startsWith("http")) url = "https://$url";
    setState(() {
      _cargando = true;
      _log = "${LanguageService().translate('connecting_log')} $url...\n";
    });
    try {
      final response = await http.head(Uri.parse(url));
      _log +=
          "${LanguageService().translate('status_log')} ${response.statusCode}\n\n${LanguageService().translate('headers_log')}\n";
      response.headers.forEach((k, v) => _log += "$k: $v\n");
    } catch (e) {
      _log += "${LanguageService().translate('error_label')} $e";
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text(
            LanguageService().translate('webspy_title'),
            style: const TextStyle(
              color: Colors.pinkAccent,
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
                    labelText: LanguageService().translate('url_label'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.language),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _cargando ? null : _analizarHeaders,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.all(15),
                ),
                child: const Icon(Icons.bug_report),
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
                  color: Colors.pinkAccent.withValues(alpha: 0.5),
                ),
              ),
              child: SingleChildScrollView(
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
