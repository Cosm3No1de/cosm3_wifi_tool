import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';
import '../theme.dart';

class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> with SingleTickerProviderStateMixin {
  // Permission states: 0=Pending, 1=Authorized, 2=Denied
  int _locationStatus = 0;
  int _notificationStatus = 0;
  bool _isInitializing = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    
    // Check initial statuses without requesting
    _checkInitialStatuses();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkInitialStatuses() async {
    // On Web, checking status might not be as reliable without requesting, 
    // but we can try to see if we already have them.
    var loc = await Permission.location.status;
    var notif = await Permission.notification.status;

    if (mounted) {
      setState(() {
        _locationStatus = loc.isGranted ? 1 : 0;
        _notificationStatus = notif.isGranted ? 1 : 0;
      });
    }
  }

  Future<void> _initializeSystem() async {
    setState(() => _isInitializing = true);

    try {
      // Setup failsafe timeout for the entire permission block
      await Future.wait([
        // 1. Request Location with strict timeout
        Permission.location.request().timeout(
          const Duration(seconds: 3), 
          onTimeout: () => PermissionStatus.denied
        ).then((status) {
           if (mounted) setState(() => _locationStatus = status.isGranted ? 1 : 2);
           return status;
        }),
        
        // 2. Request Notification with strict timeout
        Permission.notification.request().timeout(
          const Duration(seconds: 3),
          onTimeout: () => PermissionStatus.denied
        ).then((status) {
           if (mounted) setState(() => _notificationStatus = status.isGranted ? 1 : 2);
           return status;
        })
      ]);

      // Artificial delay for "System Boot" effect
      await Future.delayed(const Duration(seconds: 1));

    } catch (e) {
      debugPrint("Boot Sequence Error: $e");
      // Continue anyway - failsafe
    } finally {
      if (mounted) {
         // Final safety check before nav
         // Navigate to Main App FAILSAVE
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const EstructuraPrincipal(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    }
  }

  Widget _buildStatusRow(String label, int status, IconData icon) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 1:
        statusColor = const Color(0xFF00FFC8); // Neon Green
        statusText = "AUTHORIZED";
        statusIcon = Icons.check_circle;
        break;
      case 2:
        statusColor = Colors.redAccent;
        statusText = "DENIED";
        statusIcon = Icons.cancel;
        break;
      default: // 0
        statusColor = Colors.grey;
        statusText = "PENDING";
        statusIcon = Icons.pending;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: "Courier",
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontFamily: "Courier",
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 10),
          Icon(statusIcon, color: statusColor, size: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Icon(
                  Icons.terminal,
                  size: 60,
                  color: AppTheme.primary.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "SYSTEM//BOOT_SEQUENCE",
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontFamily: "Courier",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "v23.0.4 - INITIALIZING MODULES...",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontFamily: "Courier",
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // Permissions List
              const Text(
                "> CHECKING_PERMISSIONS:",
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: "Courier",
                  fontSize: 12,
                ),
              ),
              const Divider(color: Colors.white24),
              const SizedBox(height: 10),
              
              _buildStatusRow("GEOLOCATION_MODULE", _locationStatus, Icons.map),
              _buildStatusRow("NOTIFICATION_UPLINK", _notificationStatus, Icons.notifications),

              const SizedBox(height: 50),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ElevatedButton(
                    onPressed: _isInitializing ? null : _initializeSystem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                      side: const BorderSide(color: AppTheme.primary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 0,
                    ),
                    child: _isInitializing
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20, 
                                height: 20, 
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)
                              ),
                              const SizedBox(width: 15),
                              FadeTransition(
                                opacity: _animation,
                                child: const Text(
                                  "INITIALIZING...",
                                  style: TextStyle(
                                    fontFamily: "Courier",
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              )
                            ],
                          )
                        : const Text(
                            "[ INITIALIZE SYSTEM ]",
                            style: TextStyle(
                              fontFamily: "Courier",
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              Center(
                child: Text(
                  _isInitializing 
                      ? "ESTABLISHING SECURE CONNECTION..."
                      : "WAITING FOR USER AUTHORIZATION",
                  style: TextStyle(
                    color: _isInitializing ? AppTheme.primary : Colors.grey,
                    fontFamily: "Courier",
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
