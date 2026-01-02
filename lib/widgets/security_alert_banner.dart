import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SecurityAlertBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const SecurityAlertBanner({super.key, required this.message, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      // Diseño Profesional: Rojo intenso de alerta con borde sutil
      decoration: BoxDecoration(
        color: const Color(0xFFC62828), // Rojo intenso (Material Red 800)
        border: Border.all(
          color: const Color(0xFFFF8A80),
          width: 1,
        ), // Rojo neón más claro para el borde
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66C62828), // Sombra para darle profundidad
            blurRadius: 8.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícono de advertencia para impacto visual
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF57F17), // Amarillo neón para contraste
            size: 24.0,
          ),
          const SizedBox(width: 8.0),
          // Texto en blanco o amarillo neón
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceMono(
                // Usando GoogleFonts
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8.0),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              iconSize: 20,
            ),
          ],
        ],
      ),
    );
  }
}
