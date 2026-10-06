import 'package:flutter/material.dart';

/// Soft atmospheric yellow and lavender radial glow painter matching Figma AuthShell.
class AuthAtmosphere extends StatelessWidget {
  const AuthAtmosphere({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      painter: _AuthShellPainter(),
      child: SizedBox.expand(),
    );
  }
}

class _AuthShellPainter extends CustomPainter {
  const _AuthShellPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Top-left warm radial glow
    final yellowRect = Rect.fromCircle(
      center: Offset(size.width * -0.10, size.height * 0.45),
      radius: size.width * 1.6,
    );
    final yellowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF6E8A9).withValues(alpha: 0.45),
          const Color(0xFFF6E8A9).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.50],
      ).createShader(yellowRect);
    canvas.drawCircle(
      Offset(size.width * -0.10, size.height * 0.45),
      size.width * 1.6,
      yellowPaint,
    );

    // Top-right lavender radial glow
    final lavenderRect = Rect.fromCircle(
      center: Offset(size.width * 0.86, size.height * 0.04),
      radius: size.width * 1.5,
    );
    final lavenderPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFDDD5F6).withValues(alpha: 0.75),
          const Color(0xFFDDD5F6).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.56],
      ).createShader(lavenderRect);
    canvas.drawCircle(
      Offset(size.width * 0.86, size.height * 0.04),
      size.width * 1.5,
      lavenderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
