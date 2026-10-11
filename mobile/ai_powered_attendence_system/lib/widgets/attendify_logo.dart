import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/theme/app_colors.dart';

class AttendifyLogo extends StatelessWidget {
  const AttendifyLogo({
    super.key,
    this.markSize = 46,
    this.showWordmark = true,
  });

  final double markSize;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AttendifyMark(size: markSize),
        if (showWordmark) ...[
          const SizedBox(width: 10),
          Text(
            'Attendify',
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: -0.6,
              color: AppColors.ink,
            ),
          ),
        ],
      ],
    );
  }
}

class _AttendifyMark extends StatelessWidget {
  const _AttendifyMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.logoMark,
        borderRadius: BorderRadius.circular(size * 0.26),
      ),
      child: CustomPaint(painter: _BarsPainter()),
    );
  }
}

class _BarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    const relativeHeights = [0.38, 0.58, 0.78];
    final insetX = size.width * 0.22;
    final insetBottom = size.height * 0.20;
    final insetTop = size.height * 0.18;
    final gap = size.width * 0.07;
    final barWidth = (size.width - insetX * 2 - gap * 2) / 3;
    final maxHeight = size.height - insetTop - insetBottom;
    final radius = Radius.circular(barWidth * 0.45);

    for (var i = 0; i < 3; i++) {
      final barHeight = maxHeight * relativeHeights[i];
      final left = insetX + i * (barWidth + gap);
      final top = size.height - insetBottom - barHeight;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, barWidth, barHeight),
          radius,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
