import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scanner_red/main.dart';
import 'package:scanner_red/services/biometric_service.dart';
import 'package:scanner_red/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _isAuthenticating = false;
  String _statusMessage = "System Locked";

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _statusMessage = "Authenticating...";
    });

    bool authenticated = await _biometricService.authenticate();

    if (authenticated) {
      setState(() => _statusMessage = "Access Granted");
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const EstructuraPrincipal()),
        );
      }
    } else {
      setState(() {
        _isAuthenticating = false;
        _statusMessage = "Access Denied";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cardColor,
                    border: Border.all(
                      color: _statusMessage == "Access Denied"
                          ? Colors.red
                          : AppTheme.primary,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (_statusMessage == "Access Denied"
                                    ? Colors.red
                                    : AppTheme.primary)
                                .withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _statusMessage == "Access Denied"
                        ? Icons.lock_outline
                        : Icons.fingerprint,
                    size: 60,
                    color: _statusMessage == "Access Denied"
                        ? Colors.red
                        : AppTheme.primary,
                  ),
                )
                .animate(target: _isAuthenticating ? 1 : 0)
                .shimmer(duration: 1500.ms, color: Colors.white24)
                .animate(target: _statusMessage == "Access Denied" ? 1 : 0)
                .shake(hz: 4, curve: Curves.easeInOutCubic),
            const SizedBox(height: 40),
            Text(
              "SECURITY CHECK",
              style: GoogleFonts.orbitron(
                color: Colors.white54,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _statusMessage,
              style: GoogleFonts.firaCode(
                color: _statusMessage == "Access Denied"
                    ? Colors.red
                    : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!_isAuthenticating) ...[
              const SizedBox(height: 40),
              TextButton.icon(
                onPressed: _authenticate,
                icon: const Icon(Icons.lock_open, color: AppTheme.primary),
                label: Text(
                  "UNLOCK SYSTEM",
                  style: GoogleFonts.inter(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  side: BorderSide(
                    color: AppTheme.primary.withValues(alpha: 0.5),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
