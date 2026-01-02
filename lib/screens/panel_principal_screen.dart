import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanner_red/services/ping_service.dart';
import 'package:scanner_red/widgets/security_alert_banner.dart';
import 'package:scanner_red/widgets/traffic_monitor_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class PanelPrincipalScreen extends ConsumerStatefulWidget {
  const PanelPrincipalScreen({super.key});

  @override
  ConsumerState<PanelPrincipalScreen> createState() =>
      _PanelPrincipalScreenState();
}

class _PanelPrincipalScreenState extends ConsumerState<PanelPrincipalScreen> {
  // Controlador para el campo de texto de la IP
  final TextEditingController _ipController = TextEditingController(
    text: '8.8.8.8',
  );

  @override
  void initState() {
    super.initState();
    // Inicia el monitoreo automáticamente al cargar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(pingServiceProvider.notifier)
          .startMonitoring(_ipController.text);
    });
  }

  @override
  void dispose() {
    _ipController.dispose();
    ref.read(pingServiceProvider.notifier).stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Observa el estado de alerta global
    final alertState = ref.watch(securityAlertProvider);
    final hostStatus = ref.watch(pingServiceProvider);

    // Configuración estética Neón
    const Color neonCian = Color(0xFF18FFFF); // Color principal

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cosm3no1de WiFi Tool',
          style: GoogleFonts.spaceMono(
            color: neonCian, // Título Neón
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: neonCian,
        ), // Icono del Drawer Neón
      ),
      drawer: _buildDrawer(
        context,
      ), // Implementación del Drawer (Ver nota abajo)
      body: Container(
        color: Colors.black87, // Fondo oscuro
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. **Componente de Alerta Persistente:** Muestra el banner solo si es CRITICAL
            if (alertState == SecurityAlertState.critical)
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: SecurityAlertBanner(
                  message:
                      'ADVERTENCIA: ANOMALÍA DE RED DETECTADA - ALTA LATENCIA',
                ),
              ),

            // Tarjeta de estado del ping
            Card(
              color: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: const BorderSide(color: neonCian, width: 1.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monitoreo Activo: ${hostStatus.ip}',
                      style: GoogleFonts.spaceMono(
                        color: neonCian,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(color: neonCian, height: 16),
                    Text(
                      'Estado: ${hostStatus.isAlive ? 'ONLINE' : 'FALLIDO'}',
                      style: GoogleFonts.spaceMono(
                        color: hostStatus.isAlive
                            ? const Color(0xFF00E676)
                            : const Color(0xFFFF1744), // Lima Neón o Rojo Neón
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Latencia: ${hostStatus.latencyMs == -1 ? 'N/A' : '${hostStatus.latencyMs} ms'}',
                      style: GoogleFonts.spaceMono(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Gráfico de Latencia en Tiempo Real',
              style: GoogleFonts.spaceMono(color: neonCian, fontSize: 16),
            ),
            const SizedBox(height: 10),

            // 3. **Gráfico de Monitoreo Dinámico:**
            const TrafficMonitorWidget(),
          ],
        ),
      ),
    );
  }

  // Widget para el Drawer (asegura estética Neón Cian/Lima)
  Widget _buildDrawer(BuildContext context) {
    const Color neonCian = Color(0xFF18FFFF);
    const Color neonLima = Color(0xFF00E676);

    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.black,
              border: Border(bottom: BorderSide(color: neonLima, width: 2)),
            ),
            child: Text(
              'CYBER TOOLS',
              style: GoogleFonts.spaceMono(
                color: neonLima,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _drawerItem(
            icon: Icons.dashboard_customize_rounded,
            title: 'Panel Principal',
            color: neonCian,
            onTap: () => Navigator.pop(context),
          ),
          _drawerItem(
            icon: Icons.network_check_rounded,
            title: 'Scanner LAN',
            color: neonCian,
            // Aquí iría la navegación al Scanner LAN Screen
            onTap: () {
              // Navegar a ScannerLANScreen (Donde se implementaría el Isolate y la lógica IPv6)
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // Componente reutilizable para las entradas del Drawer
  ListTile _drawerItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: GoogleFonts.spaceMono(color: color, fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}
