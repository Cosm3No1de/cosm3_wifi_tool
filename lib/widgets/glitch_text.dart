import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GlitchText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const GlitchText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style)
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.5))
        .shake(hz: 4, curve: Curves.easeInOutCubic, duration: 1000.ms)
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.02, 1.02),
          duration: 1000.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .scale(
          begin: const Offset(1.02, 1.02),
          end: const Offset(1, 1),
          duration: 1000.ms,
          curve: Curves.easeInOut,
        );
  }
}
