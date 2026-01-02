import 'package:flutter/material.dart';
import '../theme.dart';

class CyberCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final VoidCallback? onTap;
  final Color? borderColor;

  const CyberCard({
    super.key,
    required this.child,
    this.title,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor ?? AppTheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (borderColor ?? AppTheme.primary).withValues(alpha: 0.1),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: TextStyle(
                  color: borderColor ?? AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Orbitron', // Fallback handled in theme
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
