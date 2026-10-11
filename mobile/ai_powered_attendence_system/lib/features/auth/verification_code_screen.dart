import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_colors.dart';
import '../../widgets/auth_atmosphere.dart';
import '../../widgets/auth_back_button.dart';
import 'set_password/set_password_screen.dart';

/// Verification Code (OTP) Screen — Figma node 178:592 & 178:593
/// User enters the 5-digit verification code sent to their email.
class VerificationCodeScreen extends StatefulWidget {
  final String email;

  const VerificationCodeScreen({
    super.key,
    this.email = 'student@university.edu',
  });

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  static const int _codeLength = 5;

  final List<TextEditingController> _controllers = List.generate(
    _codeLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _codeLength,
    (_) => FocusNode(),
  );

  bool _isLoading = false;

  bool get _isComplete => _controllers.every((c) => c.text.trim().isNotEmpty);

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (value.length > 1) {
        // Handle pasting multi-digit code
        final digits = value.replaceAll(RegExp(r'\D'), '');
        for (int i = 0; i < _codeLength && i < digits.length; i++) {
          _controllers[i].text = digits[i];
        }
        final targetIndex = (digits.length < _codeLength) ? digits.length : _codeLength - 1;
        _focusNodes[targetIndex].requestFocus();
      } else {
        if (index < _codeLength - 1) {
          _focusNodes[index + 1].requestFocus();
        } else {
          _focusNodes[index].unfocus();
        }
      }
    }
    setState(() {});
  }

  void _onKeyDown(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(() {});
    }
  }

  Future<void> _onConfirm() async {
    if (!_isComplete) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SetPasswordScreen(
          email: widget.email,
        ),
      ),
    );
  }

  // ignore: unused_element
  String get _enteredCode => _controllers.map((c) => c.text.trim()).join();

  Future<void> _onResend() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('New verification code sent to ${widget.email}'),
        backgroundColor: AppColors.ink,
      ),
    );
  }

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
                            const SizedBox(height: 38),
                            _buildOtpBoxes(),
                            const SizedBox(height: 18),
                            _buildResendPrompt(),
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
            'Verify Code',
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
            'Enter the verification code we sent to\n${widget.email}',
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

  Widget _buildOtpBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_codeLength, (index) {
        final hasValue = _controllers[index].text.isNotEmpty;

        return SizedBox(
          width: 60,
          height: 58,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) => _onKeyDown(index, event),
            child: TextFormField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFDFDFDF)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: hasValue ? const Color(0xFFB0B0B0) : const Color(0xFFDFDFDF),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.textPrimary,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (val) => _onDigitChanged(index, val),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResendPrompt() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Didn’t received code? ',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: _onResend,
            child: Text(
              'Resend',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEnabled = _isComplete && !_isLoading;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset > 0 ? 12 : 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: isEnabled ? _onConfirm : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isComplete ? const Color(0xFF181818) : const Color(0xFFB7B7B7),
            foregroundColor: _isComplete ? Colors.white : const Color(0xFF5B5B5B),
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
