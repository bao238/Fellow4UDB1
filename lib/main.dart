import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'screens/check_email_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/tour_detail_screen.dart';
import 'screens/trips_screen.dart';

void main() {
  runApp(const Fellow4UApp());
}

class Fellow4UApp extends StatelessWidget {
  const Fellow4UApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppTheme.primaryTeal,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Fellow4U',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _AppScrollBehavior(),
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: AppTheme.backgroundLight,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          foregroundColor: AppTheme.textDark,
          elevation: 0,
          centerTitle: false,
        ),
        splashFactory: InkRipple.splashFactory,
      ),
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/sign_in': (context) => const SignInScreen(),
        '/sign_up': (context) => const SignUpScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/check_email': (context) => const CheckEmailScreen(),
        '/explore': (context) => const ExploreScreen(),
        '/trips': (context) => const TripsScreen(),
        '/chat': (context) => const ChatScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/tour_detail': (context) => const TourDetailScreen(
          title: 'Da Nang - Ba Na - Hoi An',
          imageAsset: 'assets/images/journey_danang.png',
          price: '\$400.00',
        ),
      },
    );
  }
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
  };
}
