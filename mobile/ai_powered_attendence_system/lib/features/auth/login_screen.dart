import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_colors.dart';
import '../lecturer/my_courses_screen.dart';
import 'create_account_screen.dart';
import 'data/repositories/auth_repository.dart';
import 'forgot_password_screen.dart';
import 'widgets/login/dont_have_account_card.dart';
import 'widgets/login/login_atmosphere.dart';
import 'widgets/login/login_header.dart';
import 'widgets/login/login_method_toggle.dart';
import 'widgets/login/login_text_field.dart';

export 'widgets/login/login_method_toggle.dart' show LoginMethod;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginMethod _selectedMethod = LoginMethod.email;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _studentIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final identifier = _selectedMethod == LoginMethod.email
        ? _emailController.text.trim()
        : _studentIdController.text.trim();

    final result = await AuthRepository.login(
      identifier: identifier,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    switch (result) {
      case AuthSuccess():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, ${result.data.user.fullName}!'),
            backgroundColor: AppColors.ink,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MyCoursesScreen()),
          (route) => false,
        );
      case AuthFailure():
        setState(() => _errorMessage = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final blobSize = (w * 0.85).clamp(240.0, 480.0);

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
            // Atmospheric Glow Blobs
            LoginAtmosphere(size: size, blobSize: blobSize),

            // Foreground Content
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const LoginHeader(),
                          const SizedBox(height: 32),

                          // Segmented Method Selector (University Email / Student ID)
                          LoginMethodToggle(
                            selectedMethod: _selectedMethod,
                            onMethodChanged: (method) {
                              setState(() {
                                _selectedMethod = method;
                                _errorMessage = null;
                              });
                            },
                          ),
                          const SizedBox(height: 24),

                          // Whole identifier card — label + field animate together
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            transitionBuilder: (child, animation) {
                              final slide =
                                  Tween<Offset>(
                                    begin: const Offset(0.2, 0),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  );
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: slide,
                                  child: child,
                                ),
                              );
                            },
                            child: KeyedSubtree(
                              key: ValueKey(_selectedMethod),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedMethod == LoginMethod.email
                                        ? 'University Email *'
                                        : 'Student ID *',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  LoginTextField(
                                    controller:
                                        _selectedMethod == LoginMethod.email
                                        ? _emailController
                                        : _studentIdController,
                                    hintText:
                                        _selectedMethod == LoginMethod.email
                                        ? 'name@university.edu'
                                        : 'Enter your student ID',
                                    prefixIcon:
                                        _selectedMethod == LoginMethod.email
                                        ? Icons.mail_outline_rounded
                                        : Icons.badge_outlined,
                                    keyboardType:
                                        _selectedMethod == LoginMethod.email
                                        ? TextInputType.emailAddress
                                        : TextInputType.text,
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return _selectedMethod ==
                                                LoginMethod.email
                                            ? 'Please enter your university email'
                                            : 'Please enter your student ID';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Password Field Label
                          Text(
                            'Password *',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Password Text Field
                          LoginTextField(
                            controller: _passwordController,
                            hintText: 'Enter your password',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            hasError: _errorMessage != null,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),

                          // Error message if any
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.wrong,
                              ),
                            ),
                          ],

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                              child: Text(
                                'Forgot password?',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Log In CTA Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _onLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.ink,
                                foregroundColor: Colors.white,
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
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Log In',
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Don't have an account? Card
                          DontHaveAccountCard(
                            onCreateAccount: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CreateAccountScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
