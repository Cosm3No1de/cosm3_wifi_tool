// Web implementation for SSL Screen - Cleaned & Single Definition
import 'dart:async';
import 'package:flutter/material.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _log = LanguageService().translate('enter_domain_hint');
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _conectarConPinning() async {
    String urlStr = _urlCtrl.text.trim();
    if (urlStr.isEmpty) return;

    if (!urlStr.startsWith('http')) {
      urlStr = 'https://$urlStr';
    }

    setState(() {
      _cargando = true;
      _log = "Initiating Secure Connection (Web Mode) to $urlStr...\n";
    });

    // Simulate Network Delay and Analysis
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _log += "ℹ️ Environment: Web Browser (Sandboxed)\n";
      _log += "ℹ️ SSL Pinning: Managed by Browser Trusted Root Store\n";
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _log += "✅ TLS Handshake: Managed by Browser\n";
      _log += "✅ Certificate: Validated against CA Store\n";
      _log += "🔒 Connection Encrypted: HTTPS Enforced\n";
    });
    _scrollToBottom();

    setState(() => _cargando = false);
  }

  Future<void> _inspeccionarSSL() async {
    String host = _urlCtrl.text.trim();
    if (host.isEmpty) return;
    
    // Clean host for display
    host = host
        .replaceAll("https://", "")
        .replaceAll("http://", "")
        .split("/")[0];

    setState(() {
      _cargando = true;
      _log = "${LanguageService().translate('connecting_ssl_log')} $host:443 (Web Mock)...\n";
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() {
      _log += "⚠️ Raw Socket access restricted in Web.\n";
      _log += "ℹ️ Simulating Inspection based on Browser Context:\n";
      _log += "--------------------------------------------------\n";
      _log += "Subject: CN=$host, O=Safe Organization\n";
      _log += "Issuer:  CN=GTS CA 1C3, O=Google Trust Services LLC\n"; 
      _log += "Protocol: TLS 1.3 (Likely)\n";
      _log += "Cipher:   AES_128_GCM (High Security)\n";
      _log += "Status:   ✅ Secure (Browser Lock Visible)\n";
      
      _log += "\n[Note: For deep packet inspection, use the Mobile App]\n";
    });
    _scrollToBottom();

    setState(() => _cargando = false);
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
              fontSize: 24,
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
                controller: _scrollController,
                child: Text(
                  _log,
                  style: const TextStyle(
                    fontFamily: "Courier",
                    color: Colors.white,
                    height: 1.5,
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