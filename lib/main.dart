import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/radar_screen.dart';
import 'screens/wan_screen.dart';
import 'screens/connections_screen.dart';
import 'screens/osint_screen.dart';
import 'screens/subdomain_screen.dart';
import 'screens/dirbuster_screen.dart';
import 'screens/sqli_screen.dart';
import 'screens/webspy_screen.dart';
import 'screens/ssl_screen.dart';
import 'screens/crypto_screen.dart';
import 'screens/generator_screen.dart';
import 'screens/history_screen.dart';
import 'screens/social_screen.dart';

import 'package:scanner_red/services/localization_service.dart';

import 'package:provider/provider.dart';
import 'providers/connections_provider.dart';

import 'screens/welcome_permission_screen.dart';

void main() {
  runApp(
    riverpod.ProviderScope(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageService()),
          ChangeNotifierProvider(create: (_) => ConnectionsProvider()),
        ],
        child: const Coms3App(),
      ),
    ),
  );
}

class Coms3App extends StatelessWidget {
  const Coms3App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: languageService.translate('app_title'),
          theme: AppTheme.darkTheme,
          home: const WelcomePermissionScreen(),
        );
      },
    );
  }
}

// --- SISTEMA DE AYUDA GLOBAL ---
void mostrarAyuda(BuildContext context, String titulo, String explicacion) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1B2332),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xFF00FFC8)),
      ),
      title: Row(
        children: [
          const Icon(Icons.school, color: Color(0xFF00FFC8)),
          const SizedBox(width: 10),
          Expanded(child: Text(titulo, style: const TextStyle(fontSize: 18))),
        ],
      ),
      content: SingleChildScrollView(
        child: Text(
          explicacion,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text(
            "ENTENDIDO",
            style: TextStyle(
              color: Color(0xFF00FFC8),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

class EstructuraPrincipal extends StatefulWidget {
  const EstructuraPrincipal({super.key});
  @override
  State<EstructuraPrincipal> createState() => _EstructuraPrincipalState();
}

class _EstructuraPrincipalState extends State<EstructuraPrincipal> {
  int _paginaActual = 0;

  List<Widget> _getPaginas() {
    return [
      DashboardScreen(
        onNavigate: (i) => setState(() => _paginaActual = i),
      ), // 0
      const PantallaRadar(), // 1
      const PantallaWan(), // 2
      const PantallaConexiones(), // 3
      const PantallaOsint(), // 4
      const PantallaSubdominios(), // 5
      const PantallaDirBuster(), // 6
      const PantallaSQLi(), // 7
      const PantallaWebSpy(), // 8
      const PantallaSSL(), // 9
      const PantallaCrypto(), // 10
      const PantallaGenerador(), // 11
      const HistoryScreen(), // 12
      const SocialScreen(), // 13
    ];
  }

  String _getTitulo() {
    switch (_paginaActual) {
      case 0:
        return LanguageService().translate('dashboard');
      case 1:
        return LanguageService().translate('lan_scanner');
      case 2:
        return LanguageService().translate('wan_monitor');
      case 3:
        return LanguageService().translate('connections');
      case 4:
        return LanguageService().translate('osint');
      case 5:
        return LanguageService().translate('subdomains');
      case 6:
        return LanguageService().translate('dir_buster');
      case 7:
        return LanguageService().translate('sql_injector');
      case 8:
        return LanguageService().translate('web_spy');
      case 9:
        return LanguageService().translate('ssl_inspector');
      case 10:
        return LanguageService().translate('crypto_lab');
      case 11:
        return LanguageService().translate('generator');
      case 12:
        return LanguageService().translate('history');
      case 13:
        return LanguageService().translate('social_tracker_title');
      default:
        return LanguageService().translate('app_title');
    }
  }

  void _mostrarInfoPagina() {
    String t = "", e = "";
    switch (_paginaActual) {
      case 0:
        t = LanguageService().translate('guide_dashboard_title');
        e = LanguageService().translate('guide_dashboard_desc');
        break;
      case 1:
        t = LanguageService().translate('guide_radar_title');
        e = LanguageService().translate('guide_radar_desc');
        break;
      case 2:
        t = LanguageService().translate('guide_wan_title');
        e = LanguageService().translate('guide_wan_desc');
        break;
      case 3:
        t = LanguageService().translate('guide_connections_title');
        e = LanguageService().translate('guide_connections_desc');
        break;
      case 4:
        t = LanguageService().translate('guide_osint_title');
        e = LanguageService().translate('guide_osint_desc');
        break;
      case 5:
        t = LanguageService().translate('guide_subdomain_title');
        e = LanguageService().translate('guide_subdomain_desc');
        break;
      case 6:
        t = LanguageService().translate('guide_dirbuster_title');
        e = LanguageService().translate('guide_dirbuster_desc');
        break;
      case 7:
        t = LanguageService().translate('guide_sqli_title');
        e = LanguageService().translate('guide_sqli_desc');
        break;
      case 8:
        t = LanguageService().translate('guide_webspy_title');
        e = LanguageService().translate('guide_webspy_desc');
        break;
      case 9:
        t = LanguageService().translate('guide_ssl_title');
        e = LanguageService().translate('guide_ssl_desc');
        break;
      case 10:
        t = LanguageService().translate('guide_crypto_title');
        e = LanguageService().translate('guide_crypto_desc');
        break;
      case 11:
        t = LanguageService().translate('guide_generator_title');
        e = LanguageService().translate('guide_generator_desc');
        break;
      case 12:
        t = LanguageService().translate('guide_history_title');
        e = LanguageService().translate('guide_history_desc');
        break;
      case 13:
        t = LanguageService().translate('guide_social_title');
        e = LanguageService().translate('guide_social_desc');
        break;
    }

    mostrarAyuda(context, t, e);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to language changes to trigger full rebuild
    Provider.of<LanguageService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTitulo(),
          style: const TextStyle(
            fontFamily: "Courier",
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          Consumer<LanguageService>(
            builder: (context, language, child) {
              return Row(
                children: [
                  Text(
                    "ES",
                    style: TextStyle(
                      color: language.currentLanguage == 'es'
                          ? const Color(0xFF00FFC8)
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: language.currentLanguage == 'en',
                    activeThumbColor: const Color(0xFF00FFC8),
                    inactiveThumbColor: Colors.grey,
                    onChanged: (val) {
                      language.changeLanguage(val ? 'en' : 'es');
                    },
                  ),
                  Text(
                    "EN",
                    style: TextStyle(
                      color: language.currentLanguage == 'en'
                          ? const Color(0xFF00FFC8)
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF00FFC8)),
            onPressed: _mostrarInfoPagina,
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF0A0E14),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF1B2332)),
                accountName: Text(
                  "Cosm3No1de Wifi Tool",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00FFC8),
                  ),
                ),
                accountEmail: Text("v23.0 - Ultimate Suite"),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Color(0xFF00FFC8),
                  child: Icon(Icons.security, color: Colors.black),
                ),
              ),
              _itemMenu(
                Icons.dashboard,
                LanguageService().translate('dashboard'),
                0,
              ),
              _itemMenu(
                Icons.radar,
                LanguageService().translate('lan_scanner'),
                1,
              ),
              _itemMenu(
                Icons.public,
                LanguageService().translate('wan_monitor'),
                2,
              ),
              _itemMenu(
                Icons.remove_red_eye,
                LanguageService().translate('connections'),
                3,
              ),
              const Divider(color: Colors.grey),
              _itemMenu(Icons.search, LanguageService().translate('osint'), 4),
              _itemMenu(
                Icons.travel_explore,
                LanguageService().translate('subdomains'),
                5,
              ),
              _itemMenu(
                Icons.folder_open,
                LanguageService().translate('dir_buster'),
                6,
              ),
              _itemMenu(
                Icons.bug_report,
                LanguageService().translate('sql_injector'),
                7,
              ),
              _itemMenu(Icons.http, LanguageService().translate('web_spy'), 8),
              _itemMenu(
                Icons.lock,
                LanguageService().translate('ssl_inspector'),
                9,
              ),
              const Divider(color: Colors.grey),
              _itemMenu(
                Icons.enhanced_encryption,
                LanguageService().translate('crypto_lab'),
                10,
              ),
              _itemMenu(
                Icons.vpn_key,
                LanguageService().translate('generator'),
                11,
              ),
              _itemMenu(
                Icons.history,
                LanguageService().translate('history'),
                12,
              ),
              _itemMenu(
                Icons.person_search,
                LanguageService().translate('social_tracker_title'),
                13,
              ),
            ],
          ),
        ),
      ),
      body: _getPaginas()[_paginaActual],
    );
  }

  Widget _itemMenu(IconData icon, String text, int index) {
    return ListTile(
      leading: Icon(
        icon,
        color: _paginaActual == index ? const Color(0xFF00FFC8) : Colors.grey,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: _paginaActual == index ? Colors.white : Colors.grey,
        ),
      ),
      selected: _paginaActual == index,
      selectedTileColor: const Color(
        0xFF00FFC8,
      ).withValues(alpha: 0.1), // ignore: deprecated_member_use
      onTap: () {
        setState(() => _paginaActual = index);
        Navigator.pop(context);
      },
    );
  }
}
