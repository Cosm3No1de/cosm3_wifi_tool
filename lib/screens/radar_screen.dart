import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import '../services/scanner_service.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:dart_ping/dart_ping.dart';
import '../models/device_model.dart';
import '../theme.dart';
import '../services/history_service.dart';
import '../services/localization_service.dart';
import '../services/oui_service.dart';
import '../widgets/radar_widget.dart';
import '../widgets/glass_container.dart';
import '../widgets/fade_in_slide.dart';
import '../services/pdf_service.dart';
import '../services/port_service.dart';
import 'audit_screen.dart';
import 'terminal_screen.dart';

import '../utils/mac_helper_web.dart'
    if (dart.library.io) '../utils/mac_helper_io.dart'
    as mac_helper;

class PantallaRadar extends StatefulWidget {
  const PantallaRadar({super.key});
  @override
  State<PantallaRadar> createState() => _PantallaRadarState();
}

class _PantallaRadarState extends State<PantallaRadar> {
  final List<DispositivoRed> _listaDispositivos = [];
  bool _escaneando = false;
  double _progreso = 0.0;
  String _miIp = "Unknown";
  final HistoryService _historyService = HistoryService();

  @override
  void initState() {
    super.initState();
    _prepararPermisos();
  }

  Future<void> _prepararPermisos() async {
    if (kIsWeb) {
      setState(() => _miIp = "Escaneando segmento 192.168.1.x (Modo Web)");
      return;
    }
    await Permission.location.request();
    if (!kIsWeb) {
      await OUIService().loadOUIData(); // Load OUI data only on mobile
    }
    final info = NetworkInfo();
    final wifiIp = await info.getWifiIP();
    setState(() => _miIp = wifiIp ?? "Sin WiFi");
  }

  Future<String> _buscarVendedor(String mac) async {
    if (mac.length < 8 || mac.contains("Restringido")) {
      return "N/A";
    }

    // 1. Local Lookup
    final localVendor = OUIService().lookup(mac);
    if (localVendor != null) {
      return localVendor;
    }

    // 2. Online Lookup (Fallback)
    try {
      final response = await http.get(
        Uri.parse("https://api.macvendors.com/$mac"),
      );
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return "Genérico";
  }

  Future<String> _obtenerMacAddress(String ip) async {
    return await mac_helper.getMacAddress(ip);
  }

  Future<void> _escanearRed() async {
    if (kIsWeb) {
      setState(() {
        _escaneando = true;
        _listaDispositivos.clear();
        _miIp =
            "Escaneando segmento 192.168.1.x mediante heurística HTTP..."; // Feedback as requested
        _progreso = 0.0;
      });

      // Fixed Web Subnet for Blind Scan
      const String subnet = "192.168.1";

      final stream = ScannerService().scanSubnet(
        subnet,
        onProgress: (p) => setState(() => _progreso = p),
        onStatus: (status) {
          if (mounted) setState(() => _miIp = status);
        },
      );

      stream.listen(
        (String foundIp) {
          String ip = foundIp;
          String nombre = "Dispositivo Web";
          String mac = "N/A (Web)";
          String vendor = "Desconocido";

          if (ip.endsWith(".1")) {
            nombre = "Posible Gateway";
            vendor = "Router / Gateway";
          } else {
            // Heuristic naming
            nombre = "Dispositivo $ip";
          }

          // Check if it's me
          // In web we don't know our own IP for sure in this context easily,
          // but we can assume we aren't scanning ourselves successfully usually or it's irrelevant.

          final dispositivo = DispositivoRed(
            ip: ip,
            nombre: nombre,
            mac: mac,
            vendedor: vendor,
          );

          if (mounted) {
            setState(() => _listaDispositivos.add(dispositivo));
          }
        },
        onDone: () async {
          setState(() => _escaneando = false);
          if (_listaDispositivos.isEmpty) {
            // Optional: Add a "No devices found" placeholder or feedback
          }
        },
      );
      return;
    }

    setState(() {
      _listaDispositivos.clear();
      _escaneando = true;
      _progreso = 0.0;
    });
    // Custom Helper for Subnet (assuming Class C)
    final String subnet = _miIp.substring(0, _miIp.lastIndexOf('.'));

    final stream = ScannerService().scanSubnet(
      subnet,
      onProgress: (p) => setState(() => _progreso = p),
    );

    stream.listen(
      (String foundIp) async {
        String ip = foundIp;
        String nombre =
            ip; // Default to IP since we don't do reverse DNS safely yet

        String macReal = await _obtenerMacAddress(ip);
        String vendor = await _buscarVendedor(macReal);
        if (nombre == ip) {
          if (ip.endsWith(".1")) {
            nombre = "Gateway / Router";
          } else if (ip == _miIp) {
            nombre = "Mi Dispositivo";
          }
        }
        final dispositivo = DispositivoRed(
          ip: ip,
          nombre: nombre,
          mac: macReal,
          vendedor: vendor,
        );
        if (mounted) {
          setState(() => _listaDispositivos.add(dispositivo));
        }
      },
      onDone: () async {
        setState(() => _escaneando = false);
        if (_listaDispositivos.isNotEmpty) {
          await _historyService.saveScan(_listaDispositivos);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(LanguageService().translate('scan_saved')),
              ),
            );
          }
        }
      },
    );
  }

  void _hacerPing(String ip) {
    showDialog(
      context: context,
      builder: (ctx) => DialogPing(targetIp: ip),
    );
  }

  Future<void> _escanearPuertos(DispositivoRed device) async {
    setState(() => device.isScanningPorts = true);
    device.openPorts.clear();

    final stream = PortService().scanPorts(device.ip, start: 1, end: 1000);
    stream.listen(
      (result) {
        if (result.isOpen) {
          if (mounted) {
            setState(() {
              String info = "${result.port}";
              if (result.banner.isNotEmpty) info += " (${result.banner})";
              device.openPorts.add(info);
            });
          }
        }
      },
      onDone: () {
        if (mounted) setState(() => device.isScanningPorts = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${LanguageService().translate('ip_label')}$_miIp",
                    style: const TextStyle(
                      fontFamily: "Courier",
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.white,
                        ),
                        onPressed: _listaDispositivos.isEmpty
                            ? null
                            : () => PdfService().generateRadarReport(
                                _listaDispositivos,
                              ),
                      ),
                      if (!_escaneando)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            foregroundColor: AppTheme.primary,
                          ),
                          icon: const Icon(Icons.radar),
                          label: Text(
                            LanguageService().translate('scan_button'),
                          ),
                          onPressed: _escanearRed,
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(child: RadarWidget(isScanning: _escaneando)),
              if (_escaneando)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    "${(_progreso * 100).toInt()}%",
                    style: const TextStyle(
                      fontFamily: "Courier",
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _listaDispositivos.length,
            itemBuilder: (context, index) {
              final device = _listaDispositivos[index];
              return FadeInSlide(
                duration: const Duration(milliseconds: 500),
                child: GlassContainer(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          device.ip == _miIp
                              ? Icons.person
                              : Icons.devices_other,
                          color: AppTheme.primary,
                        ),
                        title: Text(
                          device.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "${device.ip}\n${device.mac} | ${device.vendedor}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (device.isScanningPorts)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              IconButton(
                                icon: const Icon(
                                  Icons.security,
                                  color: Colors.orange,
                                ),
                                tooltip: "Scan Ports (1-1000)",
                                onPressed: () => _escanearPuertos(device),
                              ),
                            IconButton(
                              icon: const Icon(
                                Icons.network_check,
                                color: AppTheme.primary,
                              ),
                              onPressed: () => _hacerPing(device.ip),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PantallaAuditoria(ipObjetivo: device.ip),
                            ),
                          );
                        },
                      ),
                      if (device.openPorts.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),
                          child: Wrap(
                            spacing: 5,
                            children: [
                              ...device.openPorts.map(
                                (p) => Chip(
                                  label: Text(
                                    p,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: AppTheme.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                              if (device.openPorts.any(
                                (p) => p.contains("22") || p.contains("SSH"),
                              ))
                                ActionChip(
                                  avatar: const Icon(
                                    Icons.terminal,
                                    size: 14,
                                    color: Colors.black,
                                  ),
                                  label: const Text(
                                    "SSH",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                                  ),
                                  backgroundColor: AppTheme.accent,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (c) =>
                                            TerminalScreen(ip: device.ip),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class DialogPing extends StatefulWidget {
  final String targetIp;
  const DialogPing({super.key, required this.targetIp});

  @override
  State<DialogPing> createState() => _DialogPingState();
}

class _DialogPingState extends State<DialogPing> {
  String _log = "";
  Ping? _ping;
  @override
  void initState() {
    super.initState();
    _log = LanguageService().translate('ping_start');
    _ping = Ping(widget.targetIp, count: 5);
    _ping!.stream.listen((event) {
      if (mounted) {
        setState(() {
          if (event.response != null) {
            _log +=
                "\n${LanguageService().translate('ping_response')}${event.response!.time!.inMilliseconds}ms";
          } else if (event.summary != null) {
            _log += "\n${LanguageService().translate('ping_end')}";
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _ping?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        borderRadius: BorderRadius.circular(15),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${LanguageService().translate('ping_title')}${widget.targetIp}",
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              height: 200,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _log,
                  style: const TextStyle(
                    fontFamily: "Courier",
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                LanguageService().translate('close_button'),
                style: const TextStyle(color: AppTheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
