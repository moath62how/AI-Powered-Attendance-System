import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';

/// Checkbox row: "Password saved safely?"
class RememberSafelyCheckbox extends StatelessWidget {
  final bool isChecked;
  final VoidCallback onToggle;

  const RememberSafelyCheckbox({
    super.key,
    required this.isChecked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          _Checkbox(isChecked: isChecked),
          const SizedBox(width: 8),
          Text(
            'Password saved safely?',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF343434),
            ),
          ),
        ],
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  final bool isChecked;
  const _Checkbox({required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: isChecked ? AppColors.textPrimary : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: isChecked ? AppColors.textPrimary : const Color(0xFF3B3B3B),
          width: 1.5,
        ),
      ),
      child: isChecked
          ? const Icon(Icons.check, size: 13, color: Colors.white)
          : null,
    );
  }
}

/// Live checklist showing which password requirements are satisfied.
///
/// [hasUserTyped] — once the user has started typing, unsatisfied rules
/// switch from neutral grey to red (matching Figma node 202:1422).
class PasswordRequirementsList extends StatelessWidget {
  final bool hasMin8Chars;
  final bool hasNumber;
  final bool hasNoSpaces;
  final bool hasSpecialChar;

  /// True as soon as the new-password field is non-empty.
  final bool hasUserTyped;

  const PasswordRequirementsList({
    super.key,
    required this.hasMin8Chars,
    required this.hasNumber,
    required this.hasNoSpaces,
    required this.hasSpecialChar,
    this.hasUserTyped = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.cardBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RequirementItem(
            label: 'Minimum 8 characters',
            isSatisfied: hasMin8Chars,
            hasUserTyped: hasUserTyped,
          ),
          const SizedBox(height: 8),
          _RequirementItem(
            label: 'One number required',
            isSatisfied: hasNumber,
            hasUserTyped: hasUserTyped,
          ),
          const SizedBox(height: 8),
          _RequirementItem(
            label: 'No Spaces allowed',
            isSatisfied: hasNoSpaces,
            hasUserTyped: hasUserTyped,
          ),
          const SizedBox(height: 8),
          _RequirementItem(
            label: 'Add a symbol [e.g., @, #, !]',
            isSatisfied: hasSpecialChar,
            hasUserTyped: hasUserTyped,
          ),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String label;
  final bool isSatisfied;
  final bool hasUserTyped;

  const _RequirementItem({
    required this.label,
    required this.isSatisfied,
    required this.hasUserTyped,
  });

  @override
  Widget build(BuildContext context) {
    // Colour logic matching Figma:
    //  • Satisfied           → #006C4A  (AppColors.trueColor)
    //  • Unsatisfied + typed → #A21015  (AppColors.wrong)
    //  • Unsatisfied + empty → #A7A7A7  (neutral grey)
    final Color color;
    final IconData icon;

    if (isSatisfied) {
      color = AppColors.trueColor;
      icon = Icons.check_circle_rounded;
    } else if (hasUserTyped) {
      color = AppColors.wrong;
      icon = Icons.cancel_rounded;
    } else {
      color = const Color(0xFFA7A7A7);
      icon = Icons.radio_button_unchecked_rounded;
    }

    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSatisfied ? FontWeight.w500 : FontWeight.w400,
            color: color,
          ),
        ),
      ],
    );
  }
}
