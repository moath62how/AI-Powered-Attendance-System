import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// Animated dots indicator for the onboarding flow
class DotsIndicator extends StatelessWidget {
  final int count;
  final int index;

  const DotsIndicator({
    super.key,
    required this.count,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(left: 4),
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? AppColors.ink : const Color(0xFFD5D3CE),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
