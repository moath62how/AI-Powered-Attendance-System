import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_colors.dart';
import '../../widgets/auth_atmosphere.dart';
import '../../widgets/auth_back_button.dart';
import 'data/repositories/auth_repository.dart';
import 'login_screen.dart';
import 'widgets/create_account/already_have_account_card.dart';
import 'widgets/create_account/create_account_header.dart';
import 'widgets/create_account/create_account_text_field.dart';
import 'widgets/create_account/password_match_row.dart';
import 'widgets/create_account/role_selector.dart';
import 'widgets/create_account/terms_checkbox.dart';

export 'widgets/create_account/role_selector.dart' show UserRole;

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
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRole _role = UserRole.student;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _idController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String get _idLabel => _role == UserRole.student ? 'Student ID' : 'Lecturer ID';

  String get _idHint =>
      _role == UserRole.student ? 'Enter your student ID' : 'Enter your lecturer ID';

  String get _emailHint =>
      _role == UserRole.student ? 'student@university.edu' : 'lecturer@university.edu';

  Future<void> _onSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the University Attendance Policy and Privacy Terms.'),
          backgroundColor: AppColors.ink,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Split full name into first / last name
    final nameParts = _nameController.text.trim().split(RegExp(r'\s+'));
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '.';

    final result = await AuthRepository.register(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _role == UserRole.student ? 'Student' : 'Lecturer',
      studentId: _idController.text.trim().isNotEmpty ? _idController.text.trim() : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    switch (result) {
      case AuthSuccess():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created! Welcome, ${result.data.fullName}. Please log in.'),
            backgroundColor: AppColors.trueColor,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      case AuthFailure():
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.message), backgroundColor: AppColors.wrong));
    }
  }

  void _goToLogin() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

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
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 12),
                                  const AuthBackButton(),
                                  const SizedBox(height: 20),
                                  const CreateAccountHeader(),
                                  const SizedBox(height: 20),
                                  _buildFormCard(),
                                  const SizedBox(height: 8),
                                  AlreadyHaveAccountCard(onLoginTap: _goToLogin),
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

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(27)),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            RoleSelector(
              selectedRole: _role,
              onRoleChanged: (newRole) => setState(() => _role = newRole),
            ),
            const SizedBox(height: 12),
            const CreateAccountFieldLabel(label: 'Full Name'),
            const SizedBox(height: 7),
            CreateAccountTextField(
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
            const CreateAccountFieldLabel(label: 'University Email'),
            const SizedBox(height: 7),
            CreateAccountTextField(
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
            CreateAccountFieldLabel(label: _idLabel),
            const SizedBox(height: 7),
            CreateAccountTextField(
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
            const CreateAccountFieldLabel(label: 'Phone Number'),
            const SizedBox(height: 7),
            CreateAccountTextField(
              controller: _phoneController,
              hint: '+20 1xx xxx xxxx',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            PasswordMatchRow(
              passwordController: _passwordController,
              confirmPasswordController: _confirmPasswordController,
              obscurePassword: _obscurePassword,
              obscureConfirm: _obscureConfirm,
              onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
              onToggleConfirm: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            const SizedBox(height: 12),
            TermsCheckbox(
              isAgreed: _agreedToTerms,
              onToggle: (val) => setState(() => _agreedToTerms = val),
            ),
            const SizedBox(height: 12),
            _buildSignUpButton(),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
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
}
