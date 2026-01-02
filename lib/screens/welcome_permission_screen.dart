import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart'; // To access EstructuraPrincipal
import '../theme.dart';

class WelcomePermissionScreen extends StatefulWidget {
  const WelcomePermissionScreen({super.key});

  @override
  State<WelcomePermissionScreen> createState() => _WelcomePermissionScreenState();
}

class _WelcomePermissionScreenState extends State<WelcomePermissionScreen> {
  bool _isLoading = false;

  Future<void> _handleStart() async {
    setState(() => _isLoading = true);

    try {
      // Solicitar permisos necesarios para la app
      await Permission.location.request();
      // Podemos añadir más solicitudes aquí si es necesario
      
    } catch (e) {
      debugPrint("Error en inicio: $e");
    } finally {
      if (mounted) {
        // Navegación fluida al Dashboard
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
                const EstructuraPrincipal(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutQuart;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2), // Espacio superior
            
            // --- CABECERA ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    "¡Qué bueno verte!",
                    style: GoogleFonts.outfit( // Usando una fuente moderna y amigable si disponible, o fallback
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Tu navaja suiza para el análisis de redes está lista.",
                    style: GoogleFonts.dmSans(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const Spacer(flex: 3), // Espacio medio-superior

            // --- CUERPO / IMAGEN CENTRAL ---
            // Usamos un contenedor estilizado o Icono grande ya que no tengo assets de imagen garantizados
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.2),
                    AppTheme.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    blurRadius: 30,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.rocket_launch_rounded, // Icono positivo y moderno
                  size: 80,
                  color: AppTheme.primary,
                ),
              ),
            ),
            
            const Spacer(flex: 3), // Espacio medio-inferior

            // --- ACCIÓN ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.black, // Contraste alto para legibilidad
                    elevation: 8,
                    shadowColor: AppTheme.primary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 24, 
                        width: 24, 
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5)
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Comenzar ahora",
                            style: GoogleFonts.dmSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                ),
              ),
            ),

            const Spacer(flex: 2), // Espacio inferior

            // --- PIE DE PÁGINA ---
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                "todos los derechos reservados Cosm3No1de.dev",
                style: GoogleFonts.firaCode(
                  color: Colors.white24,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
