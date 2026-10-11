import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';

/// Soft yellow / lavender glow behind the splash logo.
class SplashAtmosphere extends StatelessWidget {
  const SplashAtmosphere({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      painter: _AtmospherePainter(),
      child: SizedBox.expand(),
    );
  }
}

class _AtmospherePainter extends CustomPainter {
  const _AtmospherePainter();

  @override
  void paint(Canvas canvas, Size size) {
    void blob({
      required Offset center,
      required double radius,
      required Color color,
    }) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: 0.55), color.withValues(alpha: 0)],
        ).createShader(rect);
      canvas.drawCircle(center, radius, paint);
    }

    blob(
      center: Offset(size.width * 0.38, size.height * 0.40),
      radius: size.width * 0.55,
      color: AppColors.yellow,
    );
    blob(
      center: Offset(size.width * 0.34, size.height * 0.46),
      radius: size.width * 0.42,
      color: AppColors.glowPeach,
    );
    blob(
      center: Offset(size.width * 0.68, size.height * 0.50),
      radius: size.width * 0.50,
      color: AppColors.glowLavender,
    );
    blob(
      center: Offset(size.width * 0.58, size.height * 0.58),
      radius: size.width * 0.38,
      color: AppColors.lightGreen,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
