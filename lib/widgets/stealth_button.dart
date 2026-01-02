import 'package:flutter/material.dart';
import '../services/stealth_service.dart';
import '../theme.dart';

class StealthButton extends StatelessWidget {
  const StealthButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        StealthService.activate(context);
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppTheme.accent.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.accent, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withValues(alpha: 0.4),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.dangerous, color: AppTheme.accent, size: 30),
      ),
    );
  }
}
