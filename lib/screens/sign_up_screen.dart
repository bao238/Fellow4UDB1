import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../core/network/exceptions/api_exception.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../widgets/auth_header_painter.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isTraveler = true;
  final _formKey = GlobalKey<FormState>();
  final _authController = AuthController();

  final _firstNameController = TextEditingController(text: 'Bao');
  final _lastNameController = TextEditingController(text: 'Nguyen');
  final _countryController = TextEditingController(text: 'Vietnam');
  final _emailController = TextEditingController(text: 'bao@example.com');
  final _usernameController = TextEditingController(text: 'bao12345');
  final _passwordController = TextEditingController(text: 'bao123456');
  final _confirmPasswordController = TextEditingController(text: 'bao123456');

  bool _loading = false;
  int? _statusCode;
  String _message = '';
  String? _error;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _countryController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      setState(() {
        _error = 'Confirm password does not match.';
        _statusCode = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _statusCode = null;
      _message = 'Creating account...';
    });

    try {
      final result = await _authController.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        country: _countryController.text.trim(),
        role: _isTraveler ? 'Traveler' : 'Guide',
      );

      if (!mounted) return;
      setState(() {
        _loading = false;
        _statusCode = result.statusCode;
        _message = result.message;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sign up successful. Username: ${_usernameController.text.trim()}',
          ),
          backgroundColor: AppTheme.authHeaderTeal,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pushReplacementNamed('/sign_in');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (error is ApiException) {
          _statusCode = error.statusCode;
          _error = error.message;
        } else {
          _error = error.toString();
        }
      });
    }
  }

  String _randomDigits(int count) {
    final buffer = StringBuffer();
    for (var i = 0; i < count; i++) {
      buffer.write(_random.nextInt(10));
    }
    return buffer.toString();
  }

  void _suggestNewCredentials() {
    final first = _firstNameController.text.trim().toLowerCase();
    final last = _lastNameController.text.trim().toLowerCase();
    final base = (first.isNotEmpty ? first : 'user') +
        (last.isNotEmpty ? last.substring(0, min(3, last.length)) : '');
    final suffix = _randomDigits(4);
    final username = '${base}_$suffix';
    final email = '${base}_$suffix@example.com';

    setState(() {
      _usernameController.text = username;
      _emailController.text = email;
      _error = null;
      _statusCode = null;
      _message = 'Generated new username/email. Try sign up again.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF9),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).padding.top + 148,
            width: double.infinity,
            child: Stack(
              children: [
                CustomPaint(
                  painter: AuthHeaderPainter(),
                  size: Size(
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).padding.top + 148,
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 20,
                  child: Image.asset('assets/images/plane.png', width: 76),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 72,
                  right: 42,
                  child: Image.asset('assets/images/cloud.png', width: 96),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: FellowLogoWidget(size: 50),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF26332F),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign up with SQL Server API',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.authHeaderTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _RoleButton(
                                  selected: _isTraveler,
                                  label: 'Traveler',
                                  icon: Icons.flight_takeoff_rounded,
                                  onTap: () => setState(() => _isTraveler = true),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _RoleButton(
                                  selected: !_isTraveler,
                                  label: 'Guide',
                                  icon: Icons.explore_rounded,
                                  onTap: () => setState(() => _isTraveler = false),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _AuthInput(
                                  controller: _firstNameController,
                                  label: 'First Name',
                                  hint: 'Bao',
                                  icon: Icons.badge_outlined,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _AuthInput(
                                  controller: _lastNameController,
                                  label: 'Last Name',
                                  hint: 'Nguyen',
                                  icon: Icons.badge_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _AuthInput(
                            controller: _countryController,
                            label: 'Country',
                            hint: 'Vietnam',
                            icon: Icons.flag_outlined,
                          ),
                          const SizedBox(height: 10),
                          _AuthInput(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'bao@example.com',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter email';
                              }
                              if (!value.contains('@')) return 'Invalid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          _AuthInput(
                            controller: _usernameController,
                            label: 'Username',
                            hint: 'Use this username to sign in',
                            icon: Icons.alternate_email_rounded,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _loading ? null : _suggestNewCredentials,
                              icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
                              label: const Text('Generate new username'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.authHeaderTeal,
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _AuthInput(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'At least 6 characters',
                            icon: Icons.lock_outline_rounded,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter password';
                              }
                              if (value.trim().length < 6) {
                                return 'Password must be at least 6 chars';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          _AuthInput(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            hint: 'Re-enter your password',
                            icon: Icons.verified_user_outlined,
                            obscureText: true,
                          ),
                          const SizedBox(height: 12),
                          if (_loading)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: LinearProgressIndicator(minHeight: 3),
                            ),
                          if (_statusCode != null ||
                              _message.isNotEmpty ||
                              _error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _StatusBanner(
                                statusCode: _statusCode,
                                message: _message,
                                error: _error,
                              ),
                            ),
                          if ((_error ?? '').toLowerCase().contains('username already exists') ||
                              (_error ?? '').toLowerCase().contains('email already exists'))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: OutlinedButton.icon(
                                onPressed: _loading ? null : _suggestNewCredentials,
                                icon: const Icon(Icons.restart_alt_rounded),
                                label: const Text('Use new random credentials'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.authHeaderTeal,
                                  side: BorderSide(color: AppTheme.authHeaderTeal),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(
                            height: 52,
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _loading ? null : _onSignUp,
                              icon: const Icon(
                                Icons.person_add_alt_1_rounded,
                                size: 18,
                              ),
                              label: const Text(
                                'SIGN UP',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.authHeaderTeal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'By Signing Up, you agree to Terms & Conditions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textLightGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 14, color: AppTheme.textGray),
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed('/sign_in');
                                },
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.authHeaderTeal,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.selected,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFEAF7F1) : const Color(0xFFF7FBF9),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppTheme.authHeaderTeal
                  : const Color(0xFFDCE8E3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? AppTheme.authHeaderTeal : AppTheme.textGray,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppTheme.authHeaderTeal : AppTheme.textGray,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthInput extends StatelessWidget {
  const _AuthInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator:
              validator ??
              (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter $label';
                }
                return null;
              },
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18),
            filled: true,
            fillColor: const Color(0xFFF7FBF9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDCE8E3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDCE8E3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.authHeaderTeal, width: 1.4),
            ),
          ),
          style: const TextStyle(fontSize: 14, color: AppTheme.textDark),
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.statusCode,
    required this.message,
    required this.error,
  });

  final int? statusCode;
  final String message;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;
    final bg = hasError ? const Color(0xFFFFF1F1) : const Color(0xFFEFF9F4);
    final border = hasError ? const Color(0xFFFFC8C8) : const Color(0xFFBFE9D2);
    final textColor = hasError
        ? const Color(0xFFC73737)
        : const Color(0xFF126847);
    final text = hasError
        ? 'Error (${statusCode ?? 'N/A'}): $error'
        : 'Status: ${statusCode ?? 'N/A'} | ${message.isEmpty ? 'Ready to sign up' : message}';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
