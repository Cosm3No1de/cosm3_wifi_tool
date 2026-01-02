
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_certificate_pinning/http_certificate_pinning.dart';
import '../../theme.dart';
import '../../services/localization_service.dart';

class PantallaSSL extends StatefulWidget {
  const PantallaSSL({super.key});
  @override
  State<PantallaSSL> createState() => _PantallaSSLState();
}

class _PantallaSSLState extends State<PantallaSSL> {
  final _urlCtrl = TextEditingController(text: "google.com");
  String _log = "";
  bool _cargando = false;

  // Placeholder hash for google.com
  static const List<String> hashesFijados = [
    'c413e4a637eb55377a201854fc2022d9ceea44fef606a06e2fcbe176ba9ba02a', 
  ];

  @override
  void initState() {
    super.initState();
    _log = LanguageService().translate('enter_domain_hint');
  }

  Future<void> _conectarConPinning() async {
    String urlStr = _urlCtrl.text.trim();
    if (urlStr.isEmpty) return;

    if (!urlStr.startsWith('http')) {
      urlStr = 'https://$urlStr';
    }

    setState(() {
      _cargando = true;
      _log = "Initiating Secure Connection with Pinning to $urlStr...\n";
    });

    try {
      final secure = await HttpCertificatePinning.check(
        serverURL: urlStr,
        sha: SHA.SHA256,
        allowedSHAFingerprints: hashesFijados,
        timeout: 5000,
      );

      if (secure == "CONNECTION_SECURE") {
        setState(() {
          _log += '✅ CERTIFICADO VALIDADO (Pinning OK)\n';
          _log += 'Realizando petición HTTP segura...\n';
        });

        final response = await http.get(Uri.parse(urlStr));

        if (response.statusCode == 200) {
          setState(() {
            _log += '✅ CONEXIÓN EXITOSA (Status 200)\n';
          });
        } else {
          setState(() {
            _log +=
                '⚠️ CONEXIÓN COMPLETADA pero servidor respondió: ${response.statusCode}\n';
          });
        }
      } else {
        setState(() {
          _log += '⚠️ VERIFICACIÓN FALLIDA: $secure\n';
        });
      }
    } catch (e) {
      setState(() {
        _log +=
            '❌ ERROR CRÍTICO DE SEGURIDAD: El certificado no coincide o error de conexión.\n';
        _log += 'Detalle del error: $e';
      });
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _inspeccionarSSL() async {
    String host = _urlCtrl.text.trim();
    if (host.isEmpty) return;
    host = host
        .replaceAll("https://", "")
        .replaceAll("http://", "")
        .split("/")[0];
    setState(() {
      _cargando = true;
      _log =
          "${LanguageService().translate('connecting_ssl_log')} $host:443...";
    });

    try {
      SecureSocket socket = await SecureSocket.connect(
        host,
        443,
        onBadCertificate: (_) => true,
      );
      var cert = socket.peerCertificate;
      if (cert != null) {
        _log = LanguageService().translate('secure_connection_log');
        _log +=
            "${LanguageService().translate('subject_label')} ${cert.subject}\n${LanguageService().translate('issuer_label')} ${cert.issuer}\n${LanguageService().translate('expires_label')} ${cert.endValidity}\n";
        if (DateTime.now().isAfter(cert.endValidity)) {
          _log += LanguageService().translate('expired_cert_warning');
        } else {
          _log += LanguageService().translate('valid_cert_status');
        }
      } else {
        _log = LanguageService().translate('cert_error_log');
      }
      socket.destroy();
    } catch (e) {
      _log = "${LanguageService().translate('ssl_error_log')} $e";
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
            LanguageService().translate('ssl_title'),
            style: const TextStyle(
              color: Colors.tealAccent,
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
                    labelText: LanguageService().translate('domain_label'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _cargando ? null : _inspeccionarSSL,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.all(15),
                ),
                child: const Icon(Icons.search),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _cargando ? null : _conectarConPinning,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.all(15),
                ),
                child: const Icon(Icons.security),
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
                border: Border.all(color: Colors.teal.withValues(alpha: 0.5)),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _log,
                  style: const TextStyle(
                    fontFamily: "Courier",
                    color: Colors.white,
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
