import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme.dart';

import '../widgets/glass_container.dart';

import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/glitch_text.dart';
import '../services/localization_service.dart';
import '../services/link_analyzer_service.dart';
import '../services/integrity_service.dart';
import '../services/security_monitor_service.dart';
import '../widgets/latency_monitor_widget.dart';
import '../widgets/security_alert_banner.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onNavigate;
  const DashboardScreen({super.key, required this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Network Info
  String _wifiName = LanguageService().translate('scanning');
  String _publicIp = LanguageService().translate('loading');
  String _localIp = LanguageService().translate('loading');
  String _connectionType = LanguageService().translate('unknown');

  // Graph Data
  final List<int> _latencyHistory = [];
  Timer? _timer;

  final int _maxPoints = 30;

  // Animation / Visuals
  bool _isLoading = true;
  bool _isLearningMode = false;
  bool _isCompromised = false;

  SecurityState _securityState = SecurityState.normal;

  @override
  void initState() {
    super.initState();
    _initGraphData();
    _loadNetworkInfo();
    _checkIntegrity();
    _startMonitoring();
  }

  @override
  void dispose() {
    _timer?.cancel();
    SecurityMonitorService().stopMonitoring();
    super.dispose();
  }

  void _initGraphData() {
    for (int i = 0; i < _maxPoints; i++) {
      _latencyHistory.add(0);
    }
  }

  // Traffic Stats (Now Latency Monitor)
  void _startMonitoring() {
    SecurityMonitorService().startMonitoring();
    SecurityMonitorService().statsStream.listen((stats) {
      if (!mounted) {
        return;
      }

      setState(() {
        _securityState = stats.securityState;

        _latencyHistory.removeAt(0);
        _latencyHistory.add(stats.latencyMs);
      });
    });
  }

  Future<void> _loadNetworkInfo() async {
    // 1. Connectivity Type
    final connectivityResult = await Connectivity().checkConnectivity();
    String type = LanguageService().translate('none');
    if (connectivityResult.contains(ConnectivityResult.wifi)) {
      type = LanguageService().translate('wifi');
    } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
      type = LanguageService().translate('mobile');
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      type = LanguageService().translate('ethernet');
    }

    // 2. Local Info
    String? wifiIp;
    String? wifiName;

    if (kIsWeb) {
      // Web Mode: Browser security blocks local IP/SSID access.
      // We return professional placeholder data.
      wifiName = "Secure Web Network";
      wifiIp = "Web Client";
    } else {
      // Mobile Mode: Request permissions and use native plugin
      final info = NetworkInfo();
      if (await Permission.location.request().isGranted) {
        try {
          wifiIp = await info.getWifiIP();
          wifiName = await info.getWifiName();
        } catch (_) {
          // Ignored
        }
      }
    }

    if (mounted) {
      setState(() {
        _connectionType = type;
        _localIp = wifiIp ?? LanguageService().translate('na');
        _wifiName =
            wifiName?.replaceAll('"', '') ?? LanguageService().translate('na');
      });
    }

    // 3. Public IP (Async)
    try {
      // Web: Use HTTPS compatible API (ipify) to avoid Mixed Content errors
      // Mobile: Use ip-api (http) which is reliable for native
      const url = kIsWeb
          ? 'https://api.ipify.org?format=json'
          : 'http://ip-api.com/json';

      final r = await http.get(Uri.parse(url));

      if (r.statusCode == 200) {
        final d = jsonDecode(r.body);
        // Map response based on provider
        final ip = kIsWeb ? d['ip'] : d['query'];

        if (mounted) {
          setState(() {
            _publicIp = ip;
            _isLoading = false;
          });
        }
      } else {
        throw Exception("API Error ${r.statusCode}");
      }
    } catch (e) {
      debugPrint('Error en _loadNetworkInfo: $e');
      if (mounted) {
        setState(() {
          // Fallback mechanism to keep UI clean
          _publicIp = kIsWeb ? "127.0.0.1 (Web)" : "Error";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkIntegrity() async {
    bool compromised = await IntegrityService.checkIntegrity();
    if (mounted) {
      setState(() {
        _isCompromised = compromised;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          _buildHeader(),
          if (_isCompromised) ...[
            const SizedBox(height: 24),
            Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    border: Border.all(color: Colors.red, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LanguageService().translate(
                                'security_alert_title',
                              ),
                              style: GoogleFonts.orbitron(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              LanguageService().translate(
                                'security_alert_desc',
                              ),
                              style: GoogleFonts.roboto(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .shimmer(duration: 1000.ms, color: Colors.red),
          ],
          // SECURITY ALERT BANNER
          if (_securityState == SecurityState.critical)
            SecurityAlertBanner(
              message:
                  "[ADVERTENCIA: ANOMALÍA DE RED DETECTADA - ALTA LATENCIA]",
              onDismiss: () {
                // Opcional: Permitir descartar o no.
                // Por seguridad, tal vez no deberíamos permitir descartar si sigue crítico.
                // Por ahora, lo dejamos visual.
              },
            ),

          const SizedBox(height: 24),

          // LATENCY MONITOR GRAPH
          const LatencyMonitorWidget(),
          _buildLearningInfo(
            LanguageService().translate('latency_learning_desc'),
          ),

          const SizedBox(height: 12),

          // STATUS GRID (Converted to Row for variable height in Learning Mode)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: _buildStatusCard(
                        Icons.wifi,
                        _wifiName,
                        LanguageService().translate('network_label'),
                        _connectionType,
                        AppTheme.primary,
                        description: LanguageService().translate(
                          'wifi_learning_desc',
                        ),
                      ),
                    ),
                    _buildLearningInfo(
                      LanguageService().translate('wifi_learning_desc'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: _buildStatusCard(
                        Icons.public,
                        LanguageService().translate('public_ip_label'),
                        _publicIp,
                        _localIp,
                        AppTheme.accent,
                        isLoading: _isLoading,
                        description: LanguageService().translate(
                          'public_ip_learning_desc',
                        ),
                      ),
                    ),
                    _buildLearningInfo(
                      LanguageService().translate('public_ip_learning_desc'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // TOOLS SECTION
          Text(
            LanguageService().translate('tools_utilities_header'),
            style: GoogleFonts.orbitron(
              color: AppTheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: AppTheme.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),

          _buildLearningInfo(LanguageService().translate('tools_section_desc')),
          const SizedBox(height: 16),

          // Action Grid
          // Action Grid
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
            children: [
              _buildActionBtn(
                Icons.radar,
                LanguageService().translate('lan_scanner'),
                () => _handleSafeNavigation(1, "LAN Scanner"),
                description: LanguageService().translate('lan_card_desc'),
              ),
              _buildActionBtn(
                Icons.speed,
                LanguageService().translate('speed_title'),
                () => _handleSafeNavigation(2, "Speed Test"),
                description: LanguageService().translate('speed_card_desc'),
              ),
              _buildActionBtn(
                Icons.security,
                LanguageService().translate('audit_title').replaceAll(': ', ''),
                () => _handleSafeNavigation(3, "Audit Tool"),
                description: LanguageService().translate('audit_guide_content'),
              ),
              _buildActionBtn(
                Icons.travel_explore,
                LanguageService().translate('ip_tracker'),
                () => _showIpTrackerDialog(context), // HTTP Safe
                description: LanguageService().translate('ip_tracker_desc'),
              ),
              _buildActionBtn(
                Icons.language,
                LanguageService().translate('osint_web_label'),
                () => _handleSafeNavigation(4, "OSINT Tool"),
                description: LanguageService().translate('osint_tool_desc'),
              ),
              _buildActionBtn(
                Icons.link,
                LanguageService().translate('link_analyzer'),
                () => _showLinkAnalyzerDialog(context), // HTTP Safe
                description: LanguageService().translate('vuln_tool_desc'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Learning Mode Toggle
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isLearningMode
                  ? AppTheme.primary
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.school,
                    color: _isLearningMode ? AppTheme.primary : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    LanguageService().translate('mode_learning'),
                    style: GoogleFonts.roboto(
                      color: _isLearningMode ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _isLearningMode,
                activeTrackColor: AppTheme.primary,
                onChanged: (val) => setState(() => _isLearningMode = val),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child:
                  Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.analytics_outlined,
                              size: 45,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GlitchText(
                                  LanguageService().translate(
                                    'network_monitor_title',
                                  ),
                                  style: GoogleFonts.orbitron(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                    shadows: [
                                      Shadow(
                                        color: AppTheme.primary.withValues(
                                          alpha: 0.8,
                                        ),
                                        blurRadius: 15,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  LanguageService().translate(
                                    'realtime_analysis_desc',
                                  ),
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    color: Colors.white70,
                                    letterSpacing: 1.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .slideX(begin: -0.2, end: 0, duration: 800.ms),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.success.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(20),
                color: AppTheme.success.withValues(alpha: 0.1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield, color: AppTheme.success, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    LanguageService().translate('secure_badge'),
                    style: GoogleFonts.orbitron(
                      color: AppTheme.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        _buildLearningInfo(LanguageService().translate('guide_dashboard_desc')),
      ],
    );
  }

  void _showIpTrackerDialog(BuildContext context) {
    final TextEditingController ipController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(
          LanguageService().translate('trace_ip_title').replaceAll(': ', ''),
          style: GoogleFonts.orbitron(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: ipController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: LanguageService().translate(
              'enter_ip',
            ), // Ensure this key exists or use a generic one
            hintStyle: const TextStyle(color: Colors.grey),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              LanguageService().translate('cancel_button_caps'),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              final ip = ipController.text.trim();
              if (ip.isNotEmpty) {
                Navigator.pop(context); // Close input dialog

                // Show loading dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
                );

                try {
                  final url = Uri.parse('http://ip-api.com/json/$ip');
                  final response = await http.get(url);

                  if (!context.mounted) return;

                  Navigator.pop(context); // Close loading dialog

                  if (response.statusCode == 200) {
                    final data = jsonDecode(response.body);
                    if (data['status'] == 'fail') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Error: ${data['message'] ?? 'Unknown error'}",
                          ),
                        ),
                      );
                    } else {
                      _showIpResultDialog(context, data);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("HTTP Error: ${response.statusCode}"),
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint('Error en _showIpTrackerDialog: $e');
                  Navigator.pop(context); // Close loading dialog if error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Connection Error: $e")),
                  );
                }
              }
            },
            child: Text(
              LanguageService().translate('trace_button'),
              style: const TextStyle(color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showIpResultDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(
          "${LanguageService().translate('ip_report_title')}: ${data['query']}",
          style: GoogleFonts.orbitron(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${LanguageService().translate('trace_country')} ${data['country']}",
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              "${LanguageService().translate('region_label')} ${data['regionName']}",
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              "${LanguageService().translate('trace_city')} ${data['city']}",
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              "${LanguageService().translate('trace_isp')} ${data['isp']}",
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              "${LanguageService().translate('trace_org')} ${data['org']}",
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              "${LanguageService().translate('trace_latlon')} ${data['lat']}, ${data['lon']}",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              LanguageService().translate('close_button'),
              style: const TextStyle(color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showLinkAnalyzerDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(
          LanguageService().translate('analyze_link'),
          style: GoogleFonts.orbitron(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: urlController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: LanguageService().translate('enter_link'),
            hintStyle: const TextStyle(color: Colors.grey),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              LanguageService().translate('cancel_button_caps'),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (urlController.text.isNotEmpty) {
                _runLinkAnalysis(context, urlController.text.trim());
              }
            },
            child: Text(
              LanguageService().translate('analyze'),
              style: const TextStyle(color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runLinkAnalysis(BuildContext context, String url) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
    );

    try {
      final result = await LinkAnalyzerService().analyzeLink(url);
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading

      // Show Result
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: Text(
            LanguageService().translate('link_analyzer'),
            style: GoogleFonts.orbitron(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResultRow(
                  LanguageService().translate('url_label'),
                  result.originalUrl,
                ),
                const SizedBox(height: 10),
                _buildResultRow(
                  LanguageService().translate('final_dest'),
                  result.finalUrl,
                ),
                const SizedBox(height: 10),
                Text(
                  "${LanguageService().translate('risk_score')}: ${result.riskScore}/100",
                  style: TextStyle(
                    color: result.riskScore > 50 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                LinearProgressIndicator(
                  value: result.riskScore / 100,
                  color: result.riskScore > 50 ? Colors.red : Colors.green,
                  backgroundColor: Colors.grey[800],
                ),
                const SizedBox(height: 15),
                Text(
                  LanguageService().translate('risk_factors'),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (result.riskFactors.isEmpty)
                  Text(
                    LanguageService().translate('safe'),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  ...result.riskFactors.map(
                    (e) => Text(
                      "• $e",
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                LanguageService().translate('ok_button'),
                style: const TextStyle(color: AppTheme.primary),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error en _runLinkAnalysis: $e');
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _buildResultRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildStatusCard(
    IconData icon,
    String title,
    String value,
    String subValue,
    Color color, {
    bool isLoading = false,
    required String description,
  }) {
    return InkWell(
      onTap: () {
        if (_isLearningMode) {
          _showLearningDialog(context, title, description);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title, // This is the SSID or IP now
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const Spacer(),
            isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                : Text(
                    value, // This is the label (e.g. "RED WIFI")
                    style: GoogleFonts.inter(
                      color: color.withValues(alpha: 0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
            Text(
              subValue,
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(
    IconData icon,
    String label,
    VoidCallback onTap, {
    required String description,
  }) {
    return InkWell(
      onTap: () {
        if (_isLearningMode) {
          _showLearningDialog(context, label, description);
        } else {
          onTap();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLearningDialog(
    BuildContext context,
    String title,
    String description,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.school,
                color: AppTheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.accent],
                ).createShader(bounds),
                child: Text(
                  title,
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        content: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: AppTheme.accent.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            gradient: LinearGradient(
              colors: [
                AppTheme.accent.withValues(alpha: 0.05),
                Colors.transparent,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: Text(
            description,
            style: GoogleFonts.firaCode(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              LanguageService().translate('close'),
              style: GoogleFonts.orbitron(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSafeNavigation(int index, String featureName) {
    if (kIsWeb) {
      // Check if we have a safe mock for this
      if (index == 9) {
        // SSL
        widget.onNavigate(index); // Safe
        return;
      }

      // For items where we want to enforce simulation awareness
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Web Mode: $featureName is running in simulated environment.",
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );

      // We still navigate because we trust our Service Mocks (ConnectionsProvider, ScannerService, etc.)
      widget.onNavigate(index);
    } else {
      widget.onNavigate(index);
    }
  }

  Widget _buildLearningInfo(String text) {
    if (!_isLearningMode) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.15),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.school, color: AppTheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.roboto(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
