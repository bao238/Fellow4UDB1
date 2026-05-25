import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../widgets/splash_painter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.splashTeal,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    _navigationTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/onboarding');
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: SplashBackgroundPainter(),
            ),
          ),
          const Center(
            child: Image(
              image: AssetImage('assets/images/logo.png'),
              width: 220,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: topPadding + 40,
            left: 28,
            child: const Image(
              image: AssetImage('assets/images/cloud.png'),
              width: 90,
            ),
          ),
          Positioned(
            top: topPadding + 120,
            right: 28,
            child: const Image(
              image: AssetImage('assets/images/plane.png'),
              width: 56,
            ),
          ),
          Positioned(
            bottom: 70,
            right: 54,
            child: const Image(
              image: AssetImage('assets/images/hat.png'),
              width: 90,
            ),
          ),
        ],
      ),
    );
  }
}
