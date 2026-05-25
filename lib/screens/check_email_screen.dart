import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_theme.dart';
import '../widgets/auth_header_painter.dart';
import 'sign_in_screen.dart';

class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F0F0),
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).padding.top + 140,
              width: double.infinity,
              child: Stack(
                children: [
                  CustomPaint(
                    painter: AuthHeaderPainter(),
                    size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).padding.top + 140),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 18,
                    right: 24,
                    child: Image.asset('assets/images/plane.png', width: 72),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 74,
                    right: 44,
                    child: Image.asset('assets/images/cloud.png', width: 88),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: FellowLogoWidget(size: 48),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Check Email',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please check your email for the instructions on how to reset your password.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.textGray,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Center(
                      child: Image.asset(
                        'assets/images/envelope.png',
                        width: 160,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 14, color: AppTheme.textGray),
                          children: [
                            const TextSpan(text: 'Back to '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamedAndRemoveUntil('/sign_in', (route) => false);
                                },
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.authHeaderTeal,
                                    fontWeight: FontWeight.w500,
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
      ),
    );
  }
}
