import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/localization_service.dart';
import '../providers/connections_provider.dart';

class PantallaConexiones extends StatefulWidget {
  const PantallaConexiones({super.key});
  @override
  State<PantallaConexiones> createState() => _PantallaConexionesState();
}

class _PantallaConexionesState extends State<PantallaConexiones> {
  bool _modoAyuda = false;

  void _explicarConexion(ConnectionInfo info) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(
          LanguageService().translate('connection_details_title'),
          style: const TextStyle(color: AppTheme.primary),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detalleFila(
                LanguageService().translate('process_label'),
                info.processName,
              ),
              _detalleFila("PID:", info.pid),
              const Divider(color: Colors.grey),
              _detalleFila(
                LanguageService().translate('protocol_label'),
                info.protocol,
              ),
              _detalleFila("Local:", info.localAddress),
              _detalleFila("Remoto:", info.foreignAddress),
              _detalleFila(
                LanguageService().translate('state_label'),
                info.state,
              ),
              const SizedBox(height: 10),
              Text(
                _explicarEstado(info.state),
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                LanguageService().translate('tools_label'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _traceIp(info.foreignAddress);
                },
                icon: const Icon(Icons.public, color: AppTheme.primary),
                label: Text(
                  LanguageService().translate('trace_remote_ip_button'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                  foregroundColor: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LanguageService().translate('close_button')),
          ),
        ],
      ),
    );
  }

  Widget _detalleFila(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _explicarEstado(String estado) {
    if (estado.contains("ESTABLISHED")) {
      return LanguageService().translate('state_established');
    }
    if (estado.contains("LISTENING")) {
      return LanguageService().translate('state_listening');
    }
    if (estado.contains("TIME_WAIT")) {
      return LanguageService().translate('state_time_wait');
    }
    if (estado.contains("CLOSE_WAIT")) {
      return LanguageService().translate('state_close_wait');
    }
    return "";
  }

  Future<void> _traceIp(String address) async {
    final provider = Provider.of<ConnectionsProvider>(context, listen: false);

    // Extraer IP (remover puerto)
    String ip;
    if (address.startsWith('[')) {
      // IPv6: [2001:db8::1]:80 -> 2001:db8::1
      ip = address.split(']:')[0].replaceAll('[', '');
    } else {
      // IPv4: 192.168.1.1:443 -> 192.168.1.1
      ip = address.split(':')[0];
    }

    if (ip == "0.0.0.0" ||
        ip == "127.0.0.1" ||
        ip.startsWith("192.168") ||
        ip.startsWith("10.") ||
        ip == "::" ||
        ip == "::1" ||
        provider.isLocalIPv6(ip)) {
      _mostrarAlerta(LanguageService().translate('local_ip_error'));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.get(Uri.parse("http://ip-api.com/json/$ip"));
      if (!mounted) return;
      Navigator.pop(context); // Cerrar loading

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'fail') {
          _mostrarAlerta(
            "${LanguageService().translate('trace_error')}${data['message']}",
          );
          return;
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            title: Text(
              "${LanguageService().translate('trace_ip_title')}$ip",
              style: const TextStyle(color: AppTheme.primary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${LanguageService().translate('country_label')}${data['country']} (${data['countryCode']})",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "${LanguageService().translate('city_label')}${data['city']}",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "${LanguageService().translate('isp_label')}${data['isp']}",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "${LanguageService().translate('org_label')}${data['org']}",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "Lat/Lon: ${data['lat']} / ${data['lon']}",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "${LanguageService().translate('timezone_label')}${data['timezone']}",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(LanguageService().translate('close_button')),
              ),
            ],
          ),
        );
      } else {
        _mostrarAlerta(LanguageService().translate('api_fail'));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _mostrarAlerta("${LanguageService().translate('api_fail')}: $e");
      }
    }
  }

  void _mostrarAlerta(String mensaje) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        content: Text(mensaje, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectionsProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LanguageService().translate('active_connections_title'),
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Switch(
                            value: _modoAyuda,
                            activeTrackColor: AppTheme.primary,
                            onChanged: (v) => setState(() => _modoAyuda = v),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => provider.obtenerConexiones(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (_modoAyuda)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.primary),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              LanguageService().translate('connections_help'),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (provider.cargando && provider.conexiones.isEmpty)
              const LinearProgressIndicator(color: Colors.redAccent),
            if (provider.error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  provider.error,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            Expanded(
              child: Container(
                color: AppTheme.background,
                child:
                    provider.conexiones.isEmpty &&
                        !provider.cargando &&
                        provider.error.isEmpty
                    ? Center(
                        child: Text(
                          LanguageService().translate('no_connections_visible'),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.conexiones.length,
                        itemBuilder: (context, index) {
                          final info = provider.conexiones[index];
                          final esEstablecida = info.state == "ESTABLISHED";
                          return InkWell(
                            onTap: _modoAyuda
                                ? () => _explicarConexion(info)
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                color: esEstablecida
                                    ? Colors.green.withValues(alpha: 0.05)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  // Icono de protocolo
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: info.protocol.startsWith('TCP')
                                            ? Colors.blueAccent
                                            : Colors.orangeAccent,
                                      ),
                                    ),
                                    child: Text(
                                      info.protocol,
                                      style: TextStyle(
                                        color: info.protocol.startsWith('TCP')
                                            ? Colors.blueAccent
                                            : Colors.orangeAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          info.processName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "${info.localAddress} -> ${info.foreignAddress}",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 11,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        // Mostrar info IPv6 si aplica
                                        if (provider.isIPv6(
                                          info.foreignAddress,
                                        ))
                                          Text(
                                            provider.getDisplayInfo(
                                              info.foreignAddress,
                                            ),
                                            style: const TextStyle(
                                              color: AppTheme.primary,
                                              fontSize: 10,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        info.state,
                                        style: TextStyle(
                                          color: esEstablecida
                                              ? Colors.greenAccent
                                              : Colors.orange,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "PID: ${info.pid}",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
