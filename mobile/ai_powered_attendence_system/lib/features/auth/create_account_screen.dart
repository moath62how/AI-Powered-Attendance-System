import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_colors.dart';
import '../../widgets/auth_atmosphere.dart';
import '../../widgets/auth_back_button.dart';
import 'login_screen.dart';


enum _UserRole { student, lecturer }

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _UserRole _role = _UserRole.student;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String get _idLabel =>
      _role == _UserRole.student ? 'Student ID' : 'Lecturer ID';

  String get _idHint => _role == _UserRole.student
      ? 'Enter your student ID'
      : 'Enter your lecturer ID';

  String get _emailHint => _role == _UserRole.student
      ? 'student@university.edu'
      : 'lecturer@university.edu';

  // ─── Actions ───────────────────────────────────────────────────────────────

  Future<void> _onSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please agree to the University Attendance Policy and Privacy Terms.',
          ),
          backgroundColor: AppColors.ink,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Account created! Welcome, ${_nameController.text.trim()}.',
        ),
        backgroundColor: AppColors.trueColor,
      ),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _goToLogin() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            const Positioned.fill(child: AuthAtmosphere()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 12),
                                  const AuthBackButton(),
                                  const SizedBox(height: 20),
                                  _buildHeader(),
                                  const SizedBox(height: 20),
                                  _buildFormCard(),
                                  const SizedBox(height: 8),
                                  _buildAlreadyHaveAccount(),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
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
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UNIVERSITY ACCESS',
          style: GoogleFonts.inter(
            fontSize: 10,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w500,
            color: AppColors.badgeText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Create your\naccount',
          style: GoogleFonts.inter(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            height: 1.10,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Use your university credentials to get started',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ─── Form card ─────────────────────────────────────────────────────────────

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _buildRoleSelector(),
            const SizedBox(height: 12),
            _buildFieldLabel('Full Name'),
            const SizedBox(height: 7),
            _buildTextField(
              controller: _nameController,
              hint: 'Enter your full name',
              prefixIcon: Icons.person_outline_rounded,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildFieldLabel('University Email'),
            const SizedBox(height: 7),
            _buildTextField(
              controller: _emailController,
              hint: _emailHint,
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter your university email';
                }
                if (!val.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildFieldLabel(_idLabel),
            const SizedBox(height: 7),
            _buildTextField(
              controller: _idController,
              hint: _idHint,
              prefixIcon: Icons.badge_outlined,
              keyboardType: TextInputType.text,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter your $_idLabel';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildPasswordRow(),
            const SizedBox(height: 12),
            _buildTermsCheckbox(),
            const SizedBox(height: 12),
            _buildSignUpButton(),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  // ─── Role selector ─────────────────────────────────────────────────────────

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'I am a ',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF5C5A56),
            ),
            children: const [
              TextSpan(
                text: '*',
                style: TextStyle(color: AppColors.wrong),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _RoleButton(
                label: 'Student',
                icon: Icons.school_outlined,
                isSelected: _role == _UserRole.student,
                onTap: () => setState(() => _role = _UserRole.student),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RoleButton(
                label: 'Lecturer',
                icon: Icons.person_4_outlined,
                isSelected: _role == _UserRole.lecturer,
                onTap: () => setState(() => _role = _UserRole.lecturer),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Field label helper ────────────────────────────────────────────────────

  Widget _buildFieldLabel(String label) {
    return RichText(
      text: TextSpan(
        text: '$label ',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF5C5A56),
        ),
        children: const [
          TextSpan(
            text: '*',
            style: TextStyle(color: AppColors.wrong),
          ),
        ],
      ),
    );
  }

  // ─── Text field helper ─────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 13,
          color: AppColors.textSecondary.withValues(alpha: 0.65),
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Icon(prefixIcon, size: 19, color: AppColors.textSecondary),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 42,
          minHeight: 20,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFFBFAF8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: _inputBorder(AppColors.cardBorder),
        enabledBorder: _inputBorder(AppColors.cardBorder),
        focusedBorder: _inputBorder(AppColors.ink, width: 1.5),
        errorBorder: _inputBorder(AppColors.wrong, width: 1.2),
        focusedErrorBorder: _inputBorder(AppColors.wrong, width: 1.5),
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color, {double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  // ─── Password row (side by side) ───────────────────────────────────────────

  Widget _buildPasswordRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel('Password'),
              const SizedBox(height: 7),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
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
                  isObscured: _obscurePassword,
                  onToggle: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
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
              _buildFieldLabel('Confirm'),
              const SizedBox(height: 7),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (val != _passwordController.text) return "Doesn't match";
                  return null;
                },
                decoration: _passwordDecoration(
                  hint: 'Repeat',
                  isObscured: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ],
          ),
        ),
      ],
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

  // ─── Terms checkbox ────────────────────────────────────────────────────────

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: _agreedToTerms ? AppColors.ink : Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: _agreedToTerms
                      ? AppColors.ink
                      : AppColors.textSecondary,
                  width: 1.5,
                ),
              ),
              child: _agreedToTerms
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF464554),
                  height: 1.45,
                ),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'University Attendance Policy',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF464554),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Terms',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF464554),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sign Up button ────────────────────────────────────────────────────────

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                'Sign Up',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
      ),
    );
  }

  // ─── Already have account card ─────────────────────────────────────────────

  Widget _buildAlreadyHaveAccount() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account?',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _goToLogin,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEDEBE7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Log in',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Role Button widget
// ---------------------------------------------------------------------------

class _RoleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0EEEA) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.ink : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Radio circle indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.ink : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.ink : AppColors.textSecondary,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: Colors.white,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
