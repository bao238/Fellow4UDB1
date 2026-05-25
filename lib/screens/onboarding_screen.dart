import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'sign_up_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSkip() {
    Navigator.of(context).pushReplacementNamed('/sign_up');
  }

  Future<void> _goToPage(int index) async {
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // Onboarding-01 label OUTSIDE white card
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Text(
                  'Onboarding-01',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMediumGray,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            // White card with rounded top corners
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (i) => setState(() => _currentPage = i),
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _OnboardingPage1(onNext: () => _goToPage(1)),
                            _OnboardingPage2(onNext: () => _goToPage(2)),
                            const _OnboardingPage3(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) {
                            final active = i == _currentPage;
                            return InkWell(
                              onTap: () => _goToPage(i),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: active ? AppTheme.onboardingTeal : const Color(0xFFE0E0E0),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _onSkip,
                            child: Text(
                              'SKIP',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textDark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
      ),
    );
  }
}

class _OnboardingPage1 extends StatelessWidget {
  const _OnboardingPage1({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                painter: _Page1IllustrationPainter(),
                size: Size(MediaQuery.of(context).size.width, 260),
              ),
              Positioned(
                top: 40,
                left: 58,
                child: Image.asset('assets/images/cloud.png', width: 70),
              ),
              Positioned(
                bottom: 18,
                left: 70,
                child: Image.asset('assets/images/woman.png', height: 170),
              ),
              Positioned(
                bottom: 10,
                left: 160,
                child: Image.asset('assets/images/man.png', height: 175),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            'Find a local guide easily',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'With Fellow4U, you can find a local guide for you trip easily and explore as the way you want.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.textGray,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.onboardingTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('NEXT'),
            ),
          ),
        ),
      ],
    );
  }
}

class _Page1IllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Organic teal blob (#2CD7B1) - soft flowing shape
    final blobPaint = Paint()..color = AppTheme.onboardingTeal;
    final blobPath = Path();
    blobPath.moveTo(w * 0.06, h * 0.52);
    blobPath.quadraticBezierTo(w * 0.08, h * 0.18, w * 0.38, h * 0.2);
    blobPath.quadraticBezierTo(w * 0.62, h * 0.18, w * 0.92, h * 0.28);
    blobPath.quadraticBezierTo(w * 0.96, h * 0.55, w * 0.88, h * 0.82);
    blobPath.quadraticBezierTo(w * 0.5, h * 0.94, w * 0.1, h * 0.88);
    blobPath.quadraticBezierTo(w * 0.02, h * 0.7, w * 0.06, h * 0.52);
    blobPath.close();
    canvas.drawPath(blobPath, blobPaint);
    // Details (cloud + people) are PNG assets now.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OnboardingPage2 extends StatelessWidget {
  const _OnboardingPage2({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                painter: _Page2IllustrationPainter(),
                size: Size(MediaQuery.of(context).size.width, 280),
              ),
              // Landmark cards
              Positioned(
                top: 36,
                left: 40,
                child: Image.asset('assets/images/card_ny.png', width: 110),
              ),
              Positioned(
                top: 18,
                right: 52,
                child: Image.asset('assets/images/card_paris.png', width: 110),
              ),
              // Woman back
              Positioned(
                bottom: 10,
                left: 120,
                child: Image.asset('assets/images/woman_back.png', height: 190),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Many tours around the world',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textGray,
                height: 1.45,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.onboardingTeal2,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('NEXT'),
            ),
          ),
        ),
      ],
    );
  }
}

class _Page2IllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Lower part: teal with soft wavy horizon (top = white); cards & woman are PNGs
    final wavePaint = Paint()..color = AppTheme.onboardingTeal2;
    final wavePath = Path();
    wavePath.moveTo(0, h + 20);
    wavePath.lineTo(0, h * 0.42);
    wavePath.quadraticBezierTo(w * 0.2, h * 0.52, w * 0.5, h * 0.46);
    wavePath.quadraticBezierTo(w * 0.8, h * 0.4, w, h * 0.48);
    wavePath.lineTo(w, h + 20);
    wavePath.close();
    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OnboardingPage3 extends StatelessWidget {
  const _OnboardingPage3();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 260,
          child: Image.asset(
            'assets/images/onboarding3.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            'Create a trip and get offers',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Fellow4U helps you save time and get offers from hundred local guides that suit your trip.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.textGray,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/sign_up');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2FE6A5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('GET STARTED'),
            ),
          ),
        ),
      ],
    );
  }
}

class _Page3IllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final teal = Paint()..color = const Color(0xFF2FE6A5);
    final blobPath = Path();
    blobPath.moveTo(w * 0.04, h * 0.56);
    blobPath.quadraticBezierTo(w * 0.12, h * 0.16, w * 0.42, h * 0.2);
    blobPath.quadraticBezierTo(w * 0.7, h * 0.18, w * 0.94, h * 0.32);
    blobPath.quadraticBezierTo(w * 0.98, h * 0.6, w * 0.88, h * 0.88);
    blobPath.quadraticBezierTo(w * 0.5, h * 0.94, w * 0.06, h * 0.86);
    blobPath.quadraticBezierTo(w * 0.0, h * 0.72, w * 0.04, h * 0.56);
    blobPath.close();
    canvas.drawPath(blobPath, teal);
    _drawCloud(canvas, w * 0.12, h * 0.16, 22, const Color(0xFFC1E0F5));
    // Yellow winding scroll with segments + location pin (top), person (middle), pin (lower)
    _drawYellowScroll(canvas, w * 0.5, h * 0.3);
    _drawWomanWithHat(canvas, w * 0.18, h * 0.54);
    _drawSpeechBubble(canvas, w * 0.12, h * 0.38);
    _drawSpeechBubble(canvas, w * 0.72, h * 0.34);
  }

  void _drawCloud(Canvas canvas, double x, double y, double r, Color c) {
    final p = Paint()..color = c;
    canvas.drawCircle(Offset(x - r * 0.45, y), r * 0.65, p);
    canvas.drawCircle(Offset(x, y - r * 0.2), r * 0.85, p);
    canvas.drawCircle(Offset(x + r * 0.5, y), r * 0.65, p);
  }

  void _drawYellowScroll(Canvas canvas, double cx, double cy) {
    final yellow = Paint()..color = const Color(0xFFFFD100);
    final dark = Paint()..color = const Color(0xFF424242);
    // Winding path as filled ribbon with segments
    final path = Path();
    path.moveTo(cx - 32, cy - 52);
    path.quadraticBezierTo(cx + 18, cy - 72, cx + 44, cy - 32);
    path.quadraticBezierTo(cx + 54, cy + 14, cx + 24, cy + 48);
    path.quadraticBezierTo(cx - 12, cy + 56, cx - 50, cy + 26);
    path.close();
    canvas.drawPath(path, yellow);
    // Segment lines (horizontal dividers)
    final linePaint = Paint()..color = const Color(0xFFE6C200)..strokeWidth = 1.5;
    canvas.drawLine(Offset(cx - 28, cy - 30), Offset(cx + 30, cy - 28), linePaint);
    canvas.drawLine(Offset(cx + 10, cy + 8), Offset(cx + 38, cy + 6), linePaint);
    canvas.drawLine(Offset(cx - 42, cy + 12), Offset(cx - 8, cy + 14), linePaint);
    // Location pin icon (top)
    canvas.drawCircle(Offset(cx - 28, cy - 48), 6, dark);
    canvas.drawCircle(Offset(cx - 28, cy - 54), 4, dark);
    // Person icon (middle)
    canvas.drawCircle(Offset(cx + 22, cy + 2), 8, dark);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + 22, cy + 18), width: 12, height: 16), dark);
    // Location pin (lower)
    canvas.drawCircle(Offset(cx - 44, cy + 22), 5, dark);
    canvas.drawCircle(Offset(cx - 44, cy + 16), 3, dark);
  }

  void _drawWomanWithHat(Canvas canvas, double x, double y) {
    final yellow = Paint()..color = const Color(0xFFFFD100);
    final brown = Paint()..color = const Color(0xFF8D6E63);
    final white = Paint()..color = Colors.white;
    // Wide-brim yellow hat
    canvas.drawOval(Rect.fromCenter(center: Offset(x + 18, y - 30), width: 36, height: 14), yellow);
    canvas.drawOval(Rect.fromCenter(center: Offset(x + 18, y - 26), width: 24, height: 10), yellow);
    canvas.drawCircle(Offset(x + 18, y - 22), 10, brown);
    canvas.drawRect(Rect.fromLTWH(x + 6, y - 12, 24, 16), white);
    final skirt = Path()
      ..moveTo(x + 2, y + 4)
      ..quadraticBezierTo(x + 18, y + 14, x + 34, y + 4)
      ..lineTo(x + 30, y + 22)
      ..lineTo(x + 6, y + 22)
      ..close();
    canvas.drawPath(skirt, yellow);
    canvas.drawRect(Rect.fromLTWH(x + 8, y + 20, 8, 6), yellow);
    canvas.drawRect(Rect.fromLTWH(x + 20, y + 20, 8, 6), yellow);
  }

  void _drawSpeechBubble(Canvas canvas, double x, double y) {
    final p = Paint()..color = const Color(0xFFFFD100);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 32, 24), const Radius.circular(8)),
      p,
    );
    canvas.drawLine(Offset(x + 10, y + 24), Offset(x + 18, y + 32), Paint()..color = const Color(0xFFFFD100)..strokeWidth = 2);
    canvas.drawLine(Offset(x + 14, y + 14), Offset(x + 24, y + 14), Paint()..color = const Color(0xFF555555)..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
