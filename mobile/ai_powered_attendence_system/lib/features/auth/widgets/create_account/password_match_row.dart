import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import 'create_account_text_field.dart';

/// Side-by-side Password and Repeat Password inputs with visibility toggles
class PasswordMatchRow extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirm;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;

  const PasswordMatchRow({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onTogglePassword,
    required this.onToggleConfirm,
  });

  OutlineInputBorder _inputBorder(Color color, {double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  InputDecoration _passwordDecoration({
    required String hint,
    required bool isObscured,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textSecondary.withValues(alpha: 0.65),
      ),
      prefixIcon: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Icon(
          Icons.lock_outline_rounded,
          size: 18,
          color: AppColors.textSecondary,
        ),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 20),
      suffixIcon: GestureDetector(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(
            isObscured
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      filled: true,
      fillColor: const Color(0xFFFBFAF8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: _inputBorder(AppColors.cardBorder),
      enabledBorder: _inputBorder(AppColors.cardBorder),
      focusedBorder: _inputBorder(AppColors.ink, width: 1.5),
      errorBorder: _inputBorder(AppColors.wrong, width: 1.2),
      focusedErrorBorder: _inputBorder(AppColors.wrong, width: 1.5),
      errorStyle: GoogleFonts.inter(fontSize: 9),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CreateAccountFieldLabel(label: 'Password'),
              const SizedBox(height: 7),
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (val.length < 8) return 'Min 8 chars';
                  return null;
                },
                decoration: _passwordDecoration(
                  hint: 'Password',
                  isObscured: obscurePassword,
                  onToggle: onTogglePassword,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CreateAccountFieldLabel(label: 'Confirm'),
              const SizedBox(height: 7),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: obscureConfirm,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (val != passwordController.text) return "Doesn't match";
                  return null;
                },
                decoration: _passwordDecoration(
                  hint: 'Repeat',
                  isObscured: obscureConfirm,
                  onToggle: onToggleConfirm,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
