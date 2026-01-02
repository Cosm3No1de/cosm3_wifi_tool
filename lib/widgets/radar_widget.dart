import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';

class RadarWidget extends StatefulWidget {
  final bool isScanning;
  const RadarWidget({super.key, required this.isScanning});

  @override
  State<RadarWidget> createState() => _RadarWidgetState();
}

class _RadarWidgetState extends State<RadarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    if (widget.isScanning) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant RadarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !oldWidget.isScanning) {
      _controller.repeat();
    } else if (!widget.isScanning && oldWidget.isScanning) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: CustomPaint(painter: RadarPainter(_controller)),
    );
  }
}

class RadarPainter extends CustomPainter {
  final Animation<double> animation;

  RadarPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final paint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw concentric circles (Grid)
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * (i / 4), paint);
    }

    // Draw Crosshairs
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );

    // Draw Sweep
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: pi * 2,
        colors: [
          Colors.transparent,
          AppTheme.primary.withValues(alpha: 0.1),
          AppTheme.primary.withValues(alpha: 0.5),
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(animation.value * 2 * pi),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, sweepPaint..style = PaintingStyle.fill);

    // Draw Blips (Simulated)
    if (animation.value > 0) {
      final random = Random();
      final blipPaint = Paint()
        ..color = AppTheme.accent
        ..style = PaintingStyle.fill;

      // Draw a random blip occasionally based on animation value to make it dynamic
      if (random.nextDouble() > 0.8) {
        double r = radius * sqrt(random.nextDouble());
        double theta = random.nextDouble() * 2 * pi;
        canvas.drawCircle(
          Offset(center.dx + r * cos(theta), center.dy + r * sin(theta)),
          3,
          blipPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) => true;
}
