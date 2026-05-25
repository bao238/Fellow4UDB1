import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../core/network/exceptions/api_exception.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../widgets/auth_header_painter.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'emilys');
  final _passwordController = TextEditingController(text: 'emilyspass');
  final AuthController _authController = AuthController();

  bool _loading = false;
  String? _error;
  int? _statusCode;
  String _message = '';

  static const List<_DemoAccount> _demoAccounts = <_DemoAccount>[
    _DemoAccount(
      label: 'Emily',
      usernameOrEmail: 'emilys',
      password: 'emilyspass',
    ),
    _DemoAccount(
      label: 'Bao',
      usernameOrEmail: 'bao12345',
      password: 'bao123456',
    ),
    _DemoAccount(
      label: 'Admin',
      usernameOrEmail: 'admin',
      password: 'admin123',
    ),
  ];

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
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _applyDemo(_DemoAccount account) {
    _usernameController.text = account.usernameOrEmail;
    _passwordController.text = account.password;
    setState(() {
      _error = null;
      _statusCode = null;
      _message = 'Applied ${account.label} demo account.';
    });
  }

  Future<void> _onSignIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _error = null;
      _statusCode = null;
      _message = '';
    });

    try {
      final result = await _authController.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
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
            'Login success (${result.data?.username ?? 'unknown'}) - status ${result.statusCode}',
          ),
          backgroundColor: AppTheme.authHeaderTeal,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pushReplacementNamed('/explore');
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF26332F),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'SQL Server login for Fellow4U',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.authHeaderTeal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildDemoCard(),
                  const SizedBox(height: 14),
                  Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
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
                          _AuthInput(
                            label: 'Username or email',
                            hint: 'emilys or emily.johnson@example.com',
                            controller: _usernameController,
                            icon: Icons.person_outline_rounded,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter username or email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _AuthInput(
                            label: 'Password',
                            hint: 'Enter your password',
                            controller: _passwordController,
                            icon: Icons.lock_outline_rounded,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  '/forgot_password',
                                );
                              },
                              child: Text(
                                'Forgot Password',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textLightGray,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
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
                          SizedBox(
                            height: 52,
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _loading ? null : _onSignIn,
                              icon: const Icon(Icons.login_rounded, size: 18),
                              label: const Text(
                                'SIGN IN',
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
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppTheme.dividerGray)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or sign in with',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textLightGray,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: AppTheme.dividerGray)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialButton(
                        color: const Color(0xFF1877F2),
                        child: const Text(
                          'f',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _SocialButton(
                        color: const Color(0xFFFFE812),
                        child: const Text(
                          'TALK',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _SocialButton(
                        color: const Color(0xFF00B900),
                        child: const Text(
                          'LINE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 14, color: AppTheme.textGray),
                        children: [
                          const TextSpan(text: "Don't have an account? "),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(
                                  context,
                                ).pushReplacementNamed('/sign_up');
                              },
                              child: Text(
                                'Sign Up',
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
        ],
      ),
    );
  }

  Widget _buildDemoCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF9F4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCBECD9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, size: 16, color: AppTheme.authHeaderTeal),
              const SizedBox(width: 6),
              const Text(
                'Demo Accounts',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E2A26),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final account in _demoAccounts)
                ActionChip(
                  onPressed: _loading ? null : () => _applyDemo(account),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFD8E9E1)),
                  label: Text(
                    '${account.label}: ${account.usernameOrEmail}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuthInput extends StatelessWidget {
  const _AuthInput({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.obscureText = false,
    this.validator,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final bool obscureText;
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
          validator: validator,
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
        : 'Status: ${statusCode ?? 'N/A'} | ${message.isEmpty ? 'Ready to sign in' : message}';

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

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

class _DemoAccount {
  const _DemoAccount({
    required this.label,
    required this.usernameOrEmail,
    required this.password,
  });

  final String label;
  final String usernameOrEmail;
  final String password;
}
