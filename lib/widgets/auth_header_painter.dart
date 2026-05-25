import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Paints teal header with wave, airplane, clouds for auth screens.
class AuthHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Teal-green background #2FC49F
    final tealPaint = Paint()..color = AppTheme.authHeaderTeal;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), tealPaint);

    // Bottom curved wave - white fills below the curve (concave dip)
    final wavePath = Path();
    wavePath.moveTo(0, h * 0.48);
    wavePath.quadraticBezierTo(w * 0.25, h * 0.62, w * 0.5, h * 0.52);
    wavePath.quadraticBezierTo(w * 0.75, h * 0.42, w, h * 0.5);
    wavePath.lineTo(w, h + 20);
    wavePath.lineTo(0, h + 20);
    wavePath.close();
    canvas.drawPath(wavePath, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Logo: white rounded square with teal "b" face (Fellow4U style).
class FellowLogoWidget extends StatelessWidget {
  const FellowLogoWidget({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          'assets/images/app_icon.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
