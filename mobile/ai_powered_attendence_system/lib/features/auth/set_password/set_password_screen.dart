import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/app_colors.dart';
import '../../../widgets/auth_atmosphere.dart';
import '../../../widgets/auth_back_button.dart';
import '../login_screen.dart';
import 'widgets/password_field.dart';
import 'widgets/password_requirements.dart';

/// Set / Reset Password screen — Figma node 199:1315 (setPassword) & 202:1688 (confirmPassword)
class SetPasswordScreen extends StatefulWidget {
  final String? email;

  const SetPasswordScreen({super.key, this.email});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _rememberSafely = false;
  bool _isLoading = false;

  // ─── Validation ────────────────────────────────────────────────────────────

  bool get _hasMin8Chars => _newPasswordController.text.length >= 8;
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_newPasswordController.text);
  bool get _hasNoSpaces =>
      _newPasswordController.text.isNotEmpty &&
      !_newPasswordController.text.contains(' ');
  bool get _hasSpecialChar =>
      RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(_newPasswordController.text);

  bool get _isPasswordValid =>
      _hasMin8Chars && _hasNumber && _hasNoSpaces && _hasSpecialChar;

  bool get _doPasswordsMatch =>
      _newPasswordController.text.isNotEmpty &&
      _newPasswordController.text == _confirmPasswordController.text;

  bool get _isFormComplete => _isPasswordValid && _doPasswordsMatch;

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  Future<void> _onConfirm() async {
    if (!_formKey.currentState!.validate() || !_isFormComplete) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password set successfully! Please log in.'),
        backgroundColor: AppColors.trueColor,
      ),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthAtmosphere()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            const AuthBackButton(),
                            const SizedBox(height: 18),
                            _buildHeader(),
                            const SizedBox(height: 32),
                            _buildForm(),
                            const SizedBox(height: 16),
                            RememberSafelyCheckbox(
                              isChecked: _rememberSafely,
                              onToggle: () => setState(
                                () => _rememberSafely = !_rememberSafely,
                              ),
                            ),
                            const SizedBox(height: 14),
                            PasswordRequirementsList(
                              hasMin8Chars: _hasMin8Chars,
                              hasNumber: _hasNumber,
                              hasNoSpaces: _hasNoSpaces,
                              hasSpecialChar: _hasSpecialChar,
                              hasUserTyped: _newPasswordController.text.isNotEmpty,
                            ),
                            const Spacer(),
                            _buildConfirmButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Center(
          child: Text(
            'Set Password',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Set a strong password to keep\nyour account safe.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          PasswordField(
            controller: _newPasswordController,
            label: 'New Password',
            hintText: 'New Password',
            obscureText: _obscureNew,
            onToggleVisibility: () =>
                setState(() => _obscureNew = !_obscureNew),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please enter a password';
              if (!_isPasswordValid) return 'Password does not meet all criteria';
              return null;
            },
          ),
          const SizedBox(height: 20),
          PasswordField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hintText: 'Confirm Password',
            obscureText: _obscureConfirm,
            onToggleVisibility: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please confirm your password';
              if (val != _newPasswordController.text) return 'Passwords do not match';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEnabled = _isFormComplete && !_isLoading;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset > 0 ? 12 : 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: isEnabled ? _onConfirm : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled
                ? const Color(0xFF181818)
                : const Color(0xFFB7B7B7),
            foregroundColor: isEnabled ? Colors.white : const Color(0xFF5B5B5B),
            disabledBackgroundColor: const Color(0xFFB7B7B7),
            disabledForegroundColor: const Color(0xFF5B5B5B),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Confirm',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                ),
        ),
      ),
    );
  }
}
