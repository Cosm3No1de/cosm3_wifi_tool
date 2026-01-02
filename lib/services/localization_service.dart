import 'package:flutter/material.dart';

class AppTranslations {
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Cosm3No1de Wifi Tool',
      'dashboard': 'Dashboard',
      'lan_scanner': 'LAN Scanner',
      'wan_monitor': 'WAN Monitor',
      'connections': 'Connections',
      'osint': 'OSINT DNS',
      'subdomains': 'Subdomains',
      'dir_buster': 'Dir Buster',
      'sql_injector': 'SQL Injector',
      'web_spy': 'Web Spy',
      'ssl_inspector': 'SSL Inspector',
      'crypto_lab': 'Crypto Lab',
      'generator': 'Generator',
      'history': 'History',
      'guide_dashboard_title': 'GUIDE: DASHBOARD',
      'guide_dashboard_desc':
          'This is your command center.\n\n1. **Current Network**: See your WiFi name and Public IP.\n2. **Quick Actions**: Use big buttons for LAN Scanner or Speed Test.\n3. **Tools**: Shortcuts to security utilities below.',
      'guide_radar_title': 'GUIDE: LAN SCANNER',
      'guide_radar_desc':
          'Detect who is connected to your WiFi.\n\n1. Press **SCAN** to start.\n2. Wait for the progress bar.\n3. See a list of devices with IP, MAC, and Vendor.\n4. **Tap a device** to open Port Audit.\n5. Use the Share icon to export.',
      'guide_wan_title': 'GUIDE: WAN MONITOR',
      'guide_wan_desc':
          'Analyze your internet quality.\n\n1. Automatically loads Public IP, ISP, and Country.\n2. Press **START TEST** to measure download speed.\n3. The gauge shows real-time Mbps.',
      'guide_connections_title': 'GUIDE: CONNECTIONS',
      'guide_connections_desc':
          'Discover where your device connects.\n\n1. Press **Refresh** (top right).\n2. See active TCP/UDP connections.\n3. **RED** (ESTABLISHED) means data transfer.\n4. Useful to find spyware or hidden apps.',
      'guide_osint_title': 'GUIDE: OSINT DNS',
      'guide_osint_desc':
          'Get public info about a domain.\n\n1. Enter domain (e.g. google.com).\n2. Press **Check**.\n3. System queries DNS records (A, MX, NS, TXT).\n4. Check log for IPs and mail servers.',
      'guide_subdomain_title': 'GUIDE: SUBDOMAINS',
      'guide_subdomain_desc':
          'Find hidden subdomains.\n\n1. Enter main domain.\n2. Press **Play** to start dictionary attack.\n3. App tests common words (admin, mail...).\n4. Found subdomains appear in green.',
      'guide_dirbuster_title': 'GUIDE: DIR BUSTER',
      'guide_dirbuster_desc':
          'Discover hidden files on a web server.\n\n1. Enter Base URL.\n2. Press **Play**.\n3. Searches for paths like /admin, /backup.zip.\n4. Found (200 OK) are marked.',
      'guide_sqli_title': 'GUIDE: SQL INJECTOR',
      'guide_sqli_desc':
          'Test database security.\n\n1. Enter URL with params (site.com?id=1).\n2. Press **START ATTACK**.\n3. App injects quotes to provoke errors.\n4. DB Errors mean VULNERABLE.',
      'guide_webspy_title': 'GUIDE: WEB SPY',
      'guide_webspy_desc':
          'Analyze server configuration.\n\n1. Enter site URL.\n2. Press **Bug Icon**.\n3. Downloads HTTP Headers.\n4. Look for missing security headers like X-Frame-Options.',
      'guide_ssl_title': 'GUIDE: SSL INSPECTOR',
      'guide_ssl_desc':
          'Verify HTTPS security.\n\n1. Enter domain.\n2. Press **Magnifier**.\n3. See Issuer and Expiry date.\n4. Warns if expired or self-signed.',
      'guide_crypto_title': 'GUIDE: CRYPTO LAB',
      'guide_crypto_desc':
          'Encoding tools.\n\n1. Enter text.\n2. Choose: Base64 (Hide), MD5/SHA (Hash), URL Enc (Links).',
      'guide_generator_title': 'GUIDE: GENERATOR',
      'guide_generator_desc':
          'Create strong passwords.\n\n1. Set length.\n2. Toggle Numbers/Symbols.\n3. Press **GENERATE**.\n4. Copy to clipboard.',
      'guide_history_title': 'GUIDE: HISTORY',
      'guide_history_desc':
          'Past scans.\n\n1. LAN Scans saved automatically.\n2. Tap card for details.\n3. Trash icon deletes all.',
      'guide_social_title': 'GUIDE: SOCIAL TRACKER',
      'guide_social_desc':
          'Find digital footprints.\n\n1. Enter username.\n2. Checks existence on social platforms.\n3. Tap result to open profile.',
      'system_status': 'SYSTEM STATUS',
      'current_network': 'CURRENT NETWORK',
      'public_ip': 'Public IP',
      'local_ip': 'Local IP',
      'location': 'Location',
      'quick_actions': 'QUICK ACTIONS',
      'command_center': 'COMMAND CENTER',
      'system_online': 'SYSTEM ONLINE | MONITORING ACTIVE',
      'secure_badge': 'SECURE',
      'network_traffic': 'NETWORK TRAFFIC (LIVE)',
      'traffic_graph_desc':
          'This graph shows the live data usage of your network. Spikes mean high activity.',
      'network_label': 'NETWORK',
      'public_ip_label': 'PUBLIC IP',
      'tools_utilities_header': 'TOOLS & UTILITIES',
      'osint_web_label': 'OSINT WEB',
      'security_tools': 'SECURITY TOOLS',
      'ip_tracker': 'IP TRACKER',
      'enter_ip': 'Enter IP (e.g. 8.8.8.8)',
      'trace_ip': 'Trace Remote IP',
      'mode_learning': 'LEARNING MODE',
      'mode_learning_desc':
          'Enable this mode to see simple explanations for each tool.',
      'change_language': 'Change Language',
      'scanning': 'Scanning...',
      'wifi': 'WiFi',
      'mobile': 'Mobile',
      'ethernet': 'Ethernet',
      'none': 'None',
      'na': 'N/A',
      'security_alert_title': 'SECURITY ALERT: DEVICE COMPROMISED',
      'security_alert_desc':
          'Root/Jailbreak access detected. The integrity of the environment cannot be guaranteed.',
      'network_anomaly_title': 'NETWORK ANOMALY DETECTED',
      'network_anomaly_desc':
          'High latency detected (>500ms). Possible network interference or attack.',
      'analyze_link': 'Analyze Link',
      'enter_link': 'Enter Link',
      'analyze': 'ANALYZE',
      'final_dest': 'Final Destination',
      'risk_score': 'Risk Score',
      'risk_factors': 'Risk Factors',
      'safe': 'Safe',
      'ip_report_title': 'IP REPORT',
      'network_monitor_title': 'NETWORK MONITOR',
      'realtime_analysis_desc': 'Real-time Traffic Analysis',
      // Radar
      'ip_label': 'IP: ',
      'scan_button': 'SCAN',
      'scan_saved': 'Scan saved to history',
      'network_report_title': '🛡️ NETWORK REPORT\n\n',
      'ping_start': 'Ping...',
      'ping_response': 'Resp: ',
      'ping_end': '--- END ---',
      'ping_title': 'Ping ',
      'close_button': 'CLOSE',
      // WAN
      'public_identity': 'PUBLIC IDENTITY',
      'isp_label': 'ISP: ',
      'loc_label': 'Loc: ',
      'speed_title': 'SPEED',
      'download_label': 'DOWNLOAD',
      'ready_status': 'Ready.',
      'downloading_status': 'Downloading...',
      'test_ok_status': 'Test OK',
      'server_error_status': 'Server Error',
      'network_error_status': 'Network Error',
      'measuring_button': 'MEASURING...',
      'start_test_button': 'START TEST',
      // Connections
      'active_connections_title': 'ACTIVE CONNECTIONS',
      'connections_help':
          'Shows real-time TCP/UDP connections. The trash button closes the associated process.',
      'no_connections_visible': 'No active connections visible.',
      'connection_details_title': 'Connection Details',
      'tools_label': 'Tools:',
      'process_closed_success': 'Process closed successfully',
      'error_closing': 'Error closing: ',
      'exception_closing': 'Exception closing: ',
      'process_label': 'Process: ',
      'protocol_label': 'Protocol: ',
      'state_label': 'State: ',
      'state_established':
          '✅ ESTABLISHED: Active connection transferring data.',
      'state_listening': '👂 LISTENING: Waiting for incoming connections.',
      'state_time_wait':
          '⏳ TIME_WAIT: Connection closed recently, waiting for cleanup.',
      'state_close_wait':
          '🛑 CLOSE_WAIT: Remote closed, waiting for local close.',
      'local_ip_error': 'Local or Private IP, cannot be geographically traced.',
      'trace_error': 'Could not trace: ',
      'trace_ip_title': 'IP Trace: ',
      'country_label': 'Country: ',
      'city_label': 'City: ',
      'org_label': 'Org: ',
      'timezone_label': 'Timezone: ',
      'api_fail': 'API Failure',
      'android_connections_warning':
          'No connections found. Android 10+ restricts access to /proc/net without Root.',
      'android_error': 'Android Error: ',
      'connections_platform_warning':
          'This feature is optimized for Desktop (Windows). On Android/iOS network access is restricted by the OS.',
      'cancel_button': 'Cancel',
      'close_confirm': 'Are you sure you want to close process',
      'trace_remote_ip_button': 'Trace Remote IP',

      // OSINT Screen
      'osint_title': 'DNS / WHOIS',
      'domain_label': 'Domain',
      'enter_domain_log': 'Enter a domain...',
      'consulting_dns_log': '🔎 Consulting DNS for',
      'error_log': 'Error in',

      // Subdomain Screen
      'subdomain_title': 'SUBDOMAIN FINDER',
      'domain_hint': 'Domain (e.g. google.com)',
      'waiting_target_log': 'Waiting for target...',
      'starting_attack_log': '🚀 Starting Dictionary Attack on:',
      'testing_log': 'Testing:',
      'found_log': '✅ FOUND:',
      'finished_log': '🏁 Finished. Total found:',

      // DirBuster Screen
      'dirbuster_title': 'WEB DIRECTORY HUNTER',
      'url_base_label': 'Base URL',
      'dirbuster_waiting_log': 'Search for hidden files on a web server...',
      'dirbuster_starting_log': '🚀 Starting DirBuster on:',
      'found_200_log': '✅ FOUND (200):',
      'forbidden_403_log': '🔒 FORBIDDEN (403):',
      'scan_finished_log': '🏁 Scan finished.',

      // SQLi Screen
      'sqli_title': 'SQL INJECTION HUNTER',
      'target_url_label': 'Target URL',
      'sqli_waiting_log': 'Enter a URL with parameters (e.g. ?id=1)...',
      'sqli_starting_log': '💉 Starting SQL injection...',
      'url_params_warning': '⚠️ The URL must have parameters.',
      'vulnerable_log': '🔥 VULNERABLE! Error:',
      'safe_log': '✅ Seems safe.',
      'connection_error_log': '❌ Connection error.',
      'start_attack_button': 'START ATTACK',
      'stop_button': 'STOP',

      // Web Spy Screen
      'webspy_title': 'HEADER AUDIT',
      'enter_url_log': 'Enter a URL...',
      'connecting_log': '📡 Connecting to',
      'status_log': '✅ STATUS:',
      'headers_log': '--- HEADERS ---',
      'error_label': '❌ Error:',
      'url_label': 'URL',

      // SSL Screen
      'ssl_title': 'SSL/TLS INSPECTOR',
      'enter_domain_hint': 'Enter a domain...',
      'connecting_ssl_log': '🔒 Connecting to',
      'secure_connection_log':
          '✅ SECURE CONNECTION ESTABLISHED\n----------------------------------\n',
      'subject_label': '👤 SUBJECT:',
      'issuer_label': '🏢 ISSUER:',
      'expires_label': '📅 EXPIRES:',
      'expired_cert_warning': '\n❌ DANGER! CERTIFICATE EXPIRED',
      'valid_cert_status': '\n🔰 STATUS: Valid',
      'cert_error_log': '⚠️ Could not retrieve certificate.',
      'ssl_error_log': '❌ SSL Error:',

      // Crypto Screen
      'input_text_label': 'Input Text',
      'output_placeholder': 'Result here...',
      'invalid_format_error': 'Error: Invalid format',

      // Generator Screen
      'copied_snack': 'Copied!',
      'numbers_label': 'Numbers',
      'symbols_label': 'Symbols',
      'generate_button': 'GENERATE KEY',

      // History Screen
      'history_title': 'SCAN HISTORY',
      'delete_history_title': 'Delete history?',
      'cancel_button_caps': 'CANCEL',
      'delete_button_caps': 'DELETE',
      'no_history_msg': 'No saved history.',
      'scan_label': 'Scan:',
      'devices_found_label': 'devices found',

      // Terminal Screen
      'terminal_title': 'REMOTE SHELL',
      'console_ready_log': '🟢 CONSOLE READY.\n',
      'missing_creds_log': '❌ Missing credentials',
      'closed_log': '✅ Closed.',
      'service_stopped_log': '✅ Service stopped.',
      'ssh_guide_title': 'GUIDE: SSH',
      'ssh_guide_content':
          'Remote control via command line.\n\n1. **Credentials**:\n   - Expand the top section.\n   - Enter the User (e.g. root) and Password of the remote host.\n\n2. **Commands**:\n   - Type Linux commands (e.g. "ls -la", "reboot", "whoami").\n   - Press the Send button.\n\n3. **Output**:\n   - The server response will appear in the black console.',
      'understood_button': 'UNDERSTOOD',
      'ssh_creds_title': 'SSH Credentials',
      'user_label': 'User',
      'password_label': 'Password',
      'command_hint': 'Command...',

      // Audit Screen
      'audit_title': 'AUDIT: ',
      'audit_guide_title': 'GUIDE: AUDIT',
      'audit_guide_content':
          'Advanced tools for a specific device.\n\n1. **Port Scanner**:\n   - Define a range (e.g. 1-100).\n   - Press Play to search for open ports.\n   - If one is found, it will try to read what service is running there (Banner Grabbing).\n\n2. **SSH**:\n   - If port 22 is open, the "CONNECT SSH" button will appear.\n   - Use it to access the remote terminal.\n\n3. **Wake On LAN**:\n   - If you know the MAC Address of the computer, write it down.\n   - Press "WAKE DEVICE" to send a magic packet to wake it up (if supported).',
      'port_scanner_title': 'PORT SCANNER',
      'start_port_label': 'Start',
      'end_port_label': 'End',
      'connect_ssh_button': 'CONNECT SSH',
      'wol_title': 'WAKE ON LAN',
      'mac_address_label': 'MAC Address (AA:BB:CC:DD:EE:FF)',
      'wake_device_button': 'WAKE DEVICE',
      'magic_packet_sent': '⚡ Magic Packet Sent',
      'scan_start_log': '🚀 Starting quick scan of common ports...',
      'no_open_ports_log': '🔒 No common ports open.',
      'quick_scan_finished_log': '🏁 Quick scan finished.',
      'range_scan_start_log': '🚀 Starting range scan',
      'range_scan_finished_log': '🏁 Range scan finished.',
      'port_open_log': '🔓',
      'open_suffix': 'OPEN',
      // Dashboard Extras
      'unknown': 'Unknown',
      'loading': 'Loading...',
      'no_wifi': 'No WiFi',
      'error': 'Error',
      'scan_lan_card_title': 'SCAN LAN',
      'speed_test_card_title': 'SPEED TEST',
      'lan_card_desc':
          'Discover who is connected to your WiFi. Use it to see if neighbors are stealing internet.',
      'speed_card_desc':
          'Measure how fast your internet is for watching videos or downloading things.',
      'ip_tracker_desc':
          'Enter an IP address to know which country it is from, its city, and which internet company uses it.',
      'osint_tool_title': 'OSINT & DNS',
      'osint_tool_desc':
          'Search for public information about a webpage, like who owns it or where it is hosted.',
      'vuln_tool_title': 'Web Vulnerabilities',
      'vuln_tool_desc':
          'Test if a webpage has basic errors that a hacker could use.',
      'ssl_tool_title': 'SSL Audit',
      'ssl_tool_desc':
          'Check if the security padlock of a webpage is real and secure.',
      'trace_country': 'Country: ',
      'trace_city': 'City: ',
      'trace_isp': 'ISP: ',
      'trace_org': 'Org: ',
      'trace_latlon': 'Lat/Lon: ',
      'trace_timezone': 'Timezone: ',
      'trace_error_api': 'API Failure',
      'trace_error_exception': 'Exception: ',
      'ok_button': 'OK',
      'current_network_desc':
          "Here you see which WiFi you are connected to and your 'license plate' (IP) on the internet. It's like your home address but digital.",
      'social_tracker_title': 'SOCIAL TRACKER',
      'social_tracker_desc':
          'Find if a username exists across multiple social platforms.',
      'enter_username': 'Enter username...',
      'no_profiles_found': 'No profiles found.',
      'found_profiles': 'Profiles Found',
      'ipv6_local': 'Local Traffic (IPv6 Link-Local)',
      'ipv6_global': 'IPv6 Global - Ready to Trace',
      'ipv4_standard': 'IPv4 - Standard Trace',
      'latency_learning_desc':
          'Measures network response time. High values (red spikes) mean lag in games and calls.',
      'wifi_learning_desc':
          'Shows your WiFi name and local IP (your ID inside the house).',
      'public_ip_learning_desc':
          'Your ID on the Internet. Websites and hackers see you with this number.',
      'region_label': 'Region: ',
      'trace_button': 'TRACE',
      'link_analyzer': 'LINK ANALYZER',
    },
    'es': {
      'app_title': 'Scanner Red & Hacking',
      'dashboard': 'Panel Principal',
      'lan_scanner': 'Escáner LAN',
      'wan_monitor': 'Monitor WAN',
      'connections': 'Conexiones',
      'osint': 'OSINT DNS',
      'guide_dashboard_desc':
          'Este es tu centro de comando.\n\n1. **Red Actual**: Mira tu nombre WiFi e IP Pública.\n2. **Acciones Rápidas**: Botones grandes para Escáner LAN o Test de Velocidad.\n3. **Herramientas**: Accesos directos a utilidades de seguridad abajo.',
      'mode_learning': 'MODO APRENDIZAJE',
      'mode_learning_desc':
          'Activa este modo para ver explicaciones sencillas de cada herramienta.',
      'tools_section_desc':
          'Aquí encontrarás utilidades para escanear, auditar y proteger tu red. Toca cada una para usarla.',
      'traffic_graph_desc':
          'Este gráfico muestra el uso de datos en vivo de tu red. Los picos significan alta actividad.',
      'network_label': 'RED WIFI',
      'public_ip_label': 'IP PÚBLICA',
      'ip_label': 'IP: ',
      'scanning': 'Escaneando...',
      'wifi': 'WiFi',
      'mobile': 'Datos Móviles',
      'ethernet': 'Ethernet',
      'none': 'Ninguno',
      'na': 'N/A',
      'security_alert_title': 'ALERTA DE SEGURIDAD: DISPOSITIVO COMPROMETIDO',
      'security_alert_desc':
          'Acceso Root/Jailbreak detectado. La integridad del entorno no puede garantizarse.',
      'network_anomaly_title': 'ANOMALÍA DE RED DETECTADA',
      'network_anomaly_desc':
          'Alta latencia detectada (>500ms). Posible interferencia o ataque de red.',
      'analyze_link': 'Analizar Enlace',
      'enter_link': 'Ingresar Enlace',
      'analyze': 'ANALIZAR',
      'final_dest': 'Destino Final',
      'risk_score': 'Puntaje de Riesgo',
      'risk_factors': 'Factores de Riesgo',
      'safe': 'Seguro',
      'ip_report_title': 'REPORTE IP',
      'network_monitor_title': 'MONITOR DE RED',
      'realtime_analysis_desc': 'Análisis de Tráfico en Tiempo Real',
      'tools_utilities_header': 'HERRAMIENTAS Y UTILIDADES',
      'osint_web_label': 'OSINT WEB',
      'scan_button': 'ESCANEAR',
      'scan_saved': 'Escaneo guardado en historial',
      'network_report_title': '🛡️ REPORTE DE RED\n\n',
      'ping_start': 'Ping...',
      'ping_response': 'Resp: ',
      'ping_end': '--- FIN ---',
      'ping_title': 'Ping ',
      'close_button': 'CERRAR',
      'speed_title': 'VELOCIDAD',
      'ip_tracker': 'RASTREADOR IP',
      'link_analyzer': 'ANALIZADOR DE ENLACES',
      'secure_badge': 'SEGURO',
      'region_label': 'Región: ',
      'trace_button': 'RASTREAR',
      'trace_ip_title': 'Rastreo IP',
      'enter_ip': 'Ingresa IP...',
      'ipv6_local': 'Tráfico Local (IPv6 Link-Local)',
      'ipv6_global': 'IPv6 Global - Listo para rastreo',
      'ipv4_standard': 'IPv4 - Rastreo estándar',
      'latency_learning_desc':
          'Mide el tiempo de respuesta de tu red. Si es alto (picos rojos), tendrás "lag" en juegos y llamadas.',
      'wifi_learning_desc':
          'Muestra el nombre de tu WiFi y la IP local (tu identificación dentro de la casa).',
      'public_ip_learning_desc':
          'Es tu identificación en Internet. Sitios web y hackers te ven con este número.',
      // Connections
      'active_connections_title': 'CONEXIONES ACTIVAS',
      'connections_help':
          'Muestra conexiones TCP/UDP en tiempo real. El botón de basura cierra el proceso asociado.',
      'no_connections_visible': 'No hay conexiones activas visibles.',
      'connection_details_title': 'Detalles de Conexión',
      'tools_label': 'Herramientas:',
      'process_closed_success': 'Proceso cerrado exitosamente',
      'error_closing': 'Error al cerrar: ',
      'exception_closing': 'Excepción al cerrar: ',
      'process_label': 'Proceso: ',
      'protocol_label': 'Protocolo: ',
      'state_label': 'Estado: ',
      'state_established':
          '✅ ESTABLISHED: Conexión activa y transfiriendo datos.',
      'state_listening': '👂 LISTENING: Esperando conexiones entrantes.',
      'state_time_wait':
          '⏳ TIME_WAIT: Conexión cerrada recientemente, esperando limpieza.',
      'state_close_wait':
          '🛑 CLOSE_WAIT: El remoto cerró, esperando que local cierre.',
      'local_ip_error':
          'IP Local o Privada, no se puede rastrear geográficamente.',
      'trace_error': 'No se pudo rastrear: ',
      'country_label': 'País: ',
      'city_label': 'Ciudad: ',
      'org_label': 'Org: ',
      'timezone_label': 'Timezone: ',
      'api_fail': 'Fallo en la API',
      'android_connections_warning':
          'No se encontraron conexiones. Android 10+ restringe el acceso a /proc/net sin Root.',
      'android_error': 'Error en Android: ',
      'connections_platform_warning':
          'Esta función está optimizada para Escritorio (Windows). En Android/iOS el acceso a conexiones de red está restringido por el sistema operativo.',
      'cancel_button': 'Cancelar',
      'close_confirm': '¿Estás seguro de que quieres cerrar el proceso',
      'trace_remote_ip_button': 'Rastrear IP Remota',

      // OSINT Screen
      'osint_title': 'DNS / WHOIS',
      'domain_label': 'Dominio',
      'enter_domain_log': 'Introduce un dominio...',
      'consulting_dns_log': '🔎 Consultando DNS para',
      'error_log': 'Error en',

      // Subdomain Screen
      'subdomain_title': 'SUBDOMAIN FINDER',
      'domain_hint': 'Dominio (ej: google.com)',
      'waiting_target_log': 'Esperando objetivo...',
      'starting_attack_log': '🚀 Iniciando Ataque de Diccionario a:',
      'testing_log': 'Probando:',
      'found_log': '✅ ENCONTRADO:',
      'finished_log': '🏁 Finalizado. Total encontrados:',

      // DirBuster Screen
      'dirbuster_title': 'WEB DIRECTORY HUNTER',
      'url_base_label': 'URL Base',
      'dirbuster_waiting_log': 'Busca archivos ocultos en un servidor web...',
      'dirbuster_starting_log': '🚀 Iniciando DirBuster en:',
      'found_200_log': '✅ ENCONTRADO (200):',
      'forbidden_403_log': '🔒 PROHIBIDO (403):',
      'scan_finished_log': '🏁 Escaneo finalizado.',

      // SQLi Screen
      'sqli_title': 'SQL INJECTION HUNTER',
      'target_url_label': 'URL Objetivo',
      'sqli_waiting_log': 'Introduce una URL con parámetros (ej: ?id=1)...',
      'sqli_starting_log': '💉 Iniciando inyección SQL...',
      'url_params_warning': '⚠️ La URL debe tener parámetros.',
      'vulnerable_log': '🔥 VULNERABLE! Error:',
      'safe_log': '✅ Parece segura.',
      'connection_error_log': '❌ Error conexión.',
      'start_attack_button': 'INICIAR ATAQUE',
      'stop_button': 'DETENER',

      // Web Spy Screen
      'webspy_title': 'AUDITORÍA DE CABECERAS',
      'enter_url_log': 'Introduce una URL...',
      'connecting_log': '📡 Conectando a',
      'status_log': '✅ ESTADO:',
      'headers_log': '--- CABECERAS ---',
      'error_label': '❌ Error:',
      'url_label': 'URL',

      // SSL Screen
      'ssl_title': 'INSPECTOR SSL/TLS',
      'enter_domain_hint': 'Ingresa un dominio...',
      'connecting_ssl_log': '🔒 Conectando a',
      'secure_connection_log':
          '✅ CONEXIÓN SEGURA ESTABLECIDA\n----------------------------------\n',
      'subject_label': '👤 SUJETO:',
      'issuer_label': '🏢 EMISOR:',
      'expires_label': '📅 EXPIRA:',
      'expired_cert_warning': '\n❌ ¡PELIGRO! CERTIFICADO EXPIRADO',
      'valid_cert_status': '\n🔰 ESTADO: Vigente',
      'cert_error_log': '⚠️ No se pudo recuperar el certificado.',
      'ssl_error_log': '❌ Error SSL:',

      // Crypto Screen
      'input_text_label': 'Texto de entrada',
      'output_placeholder': 'Resultado aquí...',
      'invalid_format_error': 'Error: Formato inválido',

      // Generator Screen
      'copied_snack': 'Copiado!',
      'numbers_label': 'Números',
      'symbols_label': 'Símbolos',
      'generate_button': 'GENERAR CLAVE',

      // History Screen
      'history_title': 'HISTORIAL DE ESCANEOS',
      'delete_history_title': '¿Borrar historial?',
      'cancel_button_caps': 'CANCELAR',
      'delete_button_caps': 'BORRAR',
      'no_history_msg': 'No hay historial guardado.',
      'scan_label': 'Escaneo:',
      'devices_found_label': 'dispositivos encontrados',

      // Terminal Screen
      'terminal_title': 'SHELL REMOTA',
      'console_ready_log': '🟢 CONSOLA LISTA.\n',
      'missing_creds_log': '❌ Faltan credenciales',
      'closed_log': '✅ Cerrado.',
      'service_stopped_log': '✅ Servicio detenido.',
      'ssh_guide_title': 'GUÍA: SSH',
      'ssh_guide_content':
          'Control remoto por línea de comandos.\n\n1. **Credenciales**:\n   - Despliega la sección superior.\n   - Ingresa el Usuario (ej: root) y la Contraseña del equipo remoto.\n\n2. **Comandos**:\n   - Escribe comandos Linux (ej: "ls -la", "reboot", "whoami").\n   - Presiona el botón de Enviar.\n\n3. **Salida**:\n   - La respuesta del servidor aparecerá en la consola negra.',
      'understood_button': 'ENTENDIDO',
      'ssh_creds_title': 'Credenciales SSH',
      'user_label': 'Usuario',
      'password_label': 'Password',
      'command_hint': 'Comando...',

      // Audit Screen
      'audit_title': 'AUDITORÍA: ',
      'audit_guide_title': 'GUÍA: AUDITORÍA',
      'audit_guide_content':
          'Herramientas avanzadas para un dispositivo específico.\n\n1. **Escáner de Puertos**:\n   - Define un rango (ej: 1-100).\n   - Presiona Play para buscar puertos abiertos.\n   - Si encuentra uno, intentará leer qué servicio corre ahí (Banner Grabbing).\n\n2. **SSH**:\n   - Si el puerto 22 está abierto, aparecerá el botón "CONECTAR SSH".\n   - Úsalo para acceder a la terminal remota.\n\n3. **Wake On LAN**:\n   - Si conoces la MAC Address del equipo, escríbela.\n   - Presiona "ENCENDER EQUIPO" para enviarle un paquete mágico que lo despierte (si lo soporta).',
      'port_scanner_title': 'ESCANER DE PUERTOS',
      'start_port_label': 'Inicio',
      'end_port_label': 'Fin',
      'connect_ssh_button': 'CONECTAR SSH',
      'wol_title': 'WAKE ON LAN',
      'mac_address_label': 'MAC Address (AA:BB:CC:DD:EE:FF)',
      'wake_device_button': 'ENCENDER EQUIPO',
      'magic_packet_sent': '⚡ Paquete Mágico Enviado',
      'scan_start_log': '🚀 Iniciando escaneo rápido de puertos comunes...',
      'no_open_ports_log': '🔒 Ningún puerto común abierto.',
      'quick_scan_finished_log': '🏁 Escaneo rápido finalizado.',
      'range_scan_start_log': '🚀 Iniciando escaneo de rango',
      'range_scan_finished_log': '🏁 Escaneo de rango finalizado.',
      'port_open_log': '🔓',
      'open_suffix': 'ABIERTO',
      // Dashboard Extras
      'unknown': 'Unknown',
      'loading': 'Loading...',
      'no_wifi': 'No WiFi',
      'error': 'Error',
      'scan_lan_card_title': 'ESCANEAR LAN',
      'speed_test_card_title': 'TEST DE VELOCIDAD',
      'lan_card_desc':
          'Descubre quién está conectado a tu WiFi. Úsalo para ver si los vecinos te roban internet.',
      'speed_card_desc':
          'Mide qué tan rápido es tu internet para ver videos o descargar cosas.',
      'ip_tracker_desc':
          'Ingresa una dirección IP para saber de qué país es, su ciudad y qué compañía de internet la usa.',
      'osint_tool_title': 'OSINT y DNS',
      'osint_tool_desc':
          'Busca información pública sobre una página web, como quién es el dueño o dónde está alojada.',
      'vuln_tool_title': 'Vulnerabilidades Web',
      'vuln_tool_desc':
          'Prueba si una página web tiene errores básicos que un hacker podría usar.',
      'ssl_tool_title': 'Auditoría SSL',
      'ssl_tool_desc':
          'Verifica si el candado de seguridad de una página web es real y seguro.',
      'trace_country': 'País: ',
      'trace_city': 'Ciudad: ',
      'trace_isp': 'ISP: ',
      'trace_org': 'Org: ',
      'trace_latlon': 'Lat/Lon: ',
      'trace_timezone': 'Zona Horaria: ',
      'trace_error_api': 'Fallo API',
      'trace_error_exception': 'Excepción: ',
      'ok_button': 'OK',
      'current_network_desc':
          "Aquí ves a qué WiFi estás conectado y tu 'matrícula' (IP) en internet. Es como la dirección de tu casa pero digital.",
      'social_tracker_title': 'RASTREADOR SOCIAL',
      'social_tracker_desc':
          'Busca si un nombre de usuario existe en múltiples redes sociales.',
      'enter_username': 'Ingresa usuario...',
      'no_profiles_found': 'No se encontraron perfiles.',
      'found_profiles': 'Perfiles Encontrados',
    },
  };

  static String get(String key, String langCode) {
    return _localizedValues[langCode]?[key] ?? key;
  }
}

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  String _currentLanguage = 'es';

  String get currentLanguage => _currentLanguage;

  void changeLanguage(String langCode) {
    if (_currentLanguage != langCode) {
      _currentLanguage = langCode;
      notifyListeners();
    }
  }

  String translate(String key) {
    return AppTranslations.get(key, _currentLanguage);
  }
}
