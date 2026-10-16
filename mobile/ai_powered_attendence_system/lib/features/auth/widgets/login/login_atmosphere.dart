import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Atmospheric Glow Blobs for the Login Screen (matching Figma node 148:403)
class LoginAtmosphere extends StatelessWidget {
  final Size size;
  final double blobSize;

  const LoginAtmosphere({
    super.key,
    required this.size,
    required this.blobSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: size.height * 0.06,
          left: -blobSize * 0.30,
          child: _AtmosphereBlob(color: AppColors.yellow, size: blobSize),
        ),
        Positioned(
          top: size.height * 0.10,
          right: -blobSize * 0.28,
          child: _AtmosphereBlob(
            color: AppColors.glowLavender,
            size: blobSize * 1.1,
          ),
        ),
        Positioned(
          top: size.height * 0.45,
          right: -blobSize * 0.32,
          child: _AtmosphereBlob(
            color: AppColors.blue,
            size: blobSize * 0.9,
          ),
        ),
      ],
    );
  }
}

class _AtmosphereBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _AtmosphereBlob({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.50),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}
