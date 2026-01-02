import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'terminal_screen.dart';
import '../theme.dart';
import '../widgets/cyber_card.dart';
import '../services/localization_service.dart';
import '../services/pdf_service.dart';

import '../utils/audit_helper_web.dart'
    if (dart.library.io) '../utils/audit_helper_io.dart';

class PantallaAuditoria extends StatefulWidget {
  final String ipObjetivo;
  const PantallaAuditoria({super.key, required this.ipObjetivo});
  @override
  State<PantallaAuditoria> createState() => _PantallaAuditoriaState();
}

class _PantallaAuditoriaState extends State<PantallaAuditoria> {
  final List<String> _logs = [];
  final List<int> _open = [];
  final TextEditingController _startPortCtrl = TextEditingController(text: "1");
  final TextEditingController _endPortCtrl = TextEditingController(text: "100");
  final TextEditingController _macController = TextEditingController();
  bool _scanning = false;
  bool _wolSent = false;
  double _progress = 0.0;
  final AuditHelper _helper = AuditHelper();

  final Map<int, String> _commonPorts = {
    21: "FTP",
    22: "SSH",
    23: "Telnet",
    25: "SMTP",
    53: "DNS",
    80: "HTTP",
    110: "POP3",
    139: "NetBIOS",
    143: "IMAP",
    443: "HTTPS",
    445: "SMB",
    3306: "MySQL",
    3389: "RDP",
    5432: "PostgreSQL",
    8080: "HTTP-Proxy",
  };

  @override
  void initState() {
    super.initState();
    _quickScan();
  }

  Future<void> _quickScan() async {
    if (kIsWeb) {
      if (mounted) {
        setState(
          () => _logs.add("Web Mode: Port scanning requires native sockets."),
        );
      }
      return;
    }
    setState(() {
      _logs.clear();
      _open.clear();
      _logs.add(LanguageService().translate('scan_start_log'));
    });
    for (var p in _commonPorts.entries) {
      await _checkPort(p.key, p.value);
    }
    if (_open.isEmpty) {
      setState(
        () => _logs.add(LanguageService().translate('no_open_ports_log')),
      );
    } else {
      setState(
        () => _logs.add(LanguageService().translate('quick_scan_finished_log')),
      );
    }
  }

  Future<void> _scanRange() async {
    if (kIsWeb) {
      if (mounted) {
        setState(
          () => _logs.add("Web Mode: Port scanning requires native sockets."),
        );
      }
      return;
    }
    int start = int.tryParse(_startPortCtrl.text) ?? 1;
    int end = int.tryParse(_endPortCtrl.text) ?? 100;
    if (start > end) {
      return;
    }

    setState(() {
      _scanning = true;
      _progress = 0.0;
      _logs.add(
        "${LanguageService().translate('range_scan_start_log')} $start-$end...",
      );
    });

    int total = end - start + 1;
    for (int i = 0; i < total; i++) {
      if (!_scanning) {
        break;
      }
      int port = start + i;
      await _checkPort(port, _commonPorts[port] ?? "Unknown");
      setState(() => _progress = (i + 1) / total);
    }

    setState(() {
      _scanning = false;
      _logs.add(LanguageService().translate('range_scan_finished_log'));
    });
  }

  Future<void> _checkPort(int port, String serviceName) async {
    await _helper.checkPort(widget.ipObjetivo, port, (banner) {
      if (mounted) {
        setState(() {
          _open.add(port);
          String msg =
              "${LanguageService().translate('port_open_log')} $port ($serviceName) ${LanguageService().translate('open_suffix')}";
          if (banner.isNotEmpty) msg += " | $banner";
          _logs.add(msg);
        });
      }
    }, () {});
  }

  Future<void> _wol() async {
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Web Mode: Wake-on-LAN not supported.")),
        );
      }
      return;
    }
    String mac = _macController.text.trim();
    if (mac.length < 12) {
      return;
    }
    setState(() => _wolSent = true);

    try {
      await _helper.sendWol(mac);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LanguageService().translate('magic_packet_sent')),
            backgroundColor: AppTheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _wolSent = false);
    }
  }

  void _mostrarAyuda() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(
          LanguageService().translate('audit_guide_title'),
          style: const TextStyle(color: AppTheme.primary),
        ),
        content: SingleChildScrollView(
          child: Text(
            LanguageService().translate('audit_guide_content'),
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              LanguageService().translate('understood_button'),
              style: const TextStyle(color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${LanguageService().translate('audit_title')}${widget.ipObjetivo}",
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: AppTheme.primary),
            onPressed: () => PdfService().generateAuditReport(
              widget.ipObjetivo,
              _open,
              _logs,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppTheme.primary),
            onPressed: _mostrarAyuda,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CyberCard(
              title: LanguageService().translate('port_scanner_title'),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _startPortCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: LanguageService().translate(
                              'start_port_label',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _endPortCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: LanguageService().translate(
                              'end_port_label',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _scanning
                            ? () => setState(() => _scanning = false)
                            : _scanRange,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _scanning
                              ? Colors.red
                              : AppTheme.primary,
                        ),
                        child: Icon(_scanning ? Icons.stop : Icons.play_arrow),
                      ),
                    ],
                  ),
                  if (_scanning) ...[
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: _progress,
                      color: AppTheme.primary,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 15),
            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (c, i) => Text(
                  _logs[i],
                  style: TextStyle(
                    fontFamily: "Courier",
                    color:
                        _logs[i].contains(
                          LanguageService().translate('port_open_log'),
                        )
                        ? Colors.greenAccent
                        : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            if (_open.contains(22))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.all(15),
                  ),
                  icon: const Icon(Icons.terminal, color: Colors.black),
                  label: Text(
                    LanguageService().translate('connect_ssh_button'),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => TerminalScreen(ip: widget.ipObjetivo),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            CyberCard(
              title: LanguageService().translate('wol_title'),
              borderColor: AppTheme.accent,
              child: Column(
                children: [
                  TextField(
                    controller: _macController,
                    decoration: InputDecoration(
                      labelText: LanguageService().translate(
                        'mac_address_label',
                      ),
                      prefixIcon: const Icon(Icons.settings_ethernet),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _wolSent ? null : _wol,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                      ),
                      icon: const Icon(Icons.power_settings_new),
                      label: Text(
                        LanguageService().translate('wake_device_button'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
