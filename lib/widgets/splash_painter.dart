import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Paints splash background: teal, clouds, airplane + dashed path, ground, leaves, sun hat.
class SplashBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Teal background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = AppTheme.splashTeal,
    );

    // Keep only background + ground/leaves; cloud/plane/hat are image assets now

    // Ground / hills (wavy darker teal)
    final groundPaint = Paint()..color = AppTheme.splashTealDark;
    final groundPath = Path();
    groundPath.moveTo(0, h);
    groundPath.lineTo(0, h * 0.75);
    groundPath.quadraticBezierTo(w * 0.25, h * 0.65, w * 0.5, h * 0.72);
    groundPath.quadraticBezierTo(w * 0.75, h * 0.8, w, h * 0.7);
    groundPath.lineTo(w, h);
    groundPath.close();
    canvas.drawPath(groundPath, groundPaint);

    // Left leaves (two tall)
    final leafPaint = Paint()..color = AppTheme.splashTealDark;
    canvas.save();
    canvas.translate(w * 0.08, h * 0.82);
    canvas.rotate(-0.15);
    _drawLeaf(canvas, 12, 55, leafPaint);
    canvas.translate(18, -5);
    _drawLeaf(canvas, 10, 48, leafPaint);
    canvas.restore();

    // Right leaf (partial)
    canvas.save();
    canvas.translate(w * 0.92, h * 0.78);
    canvas.rotate(0.3);
    _drawLeaf(canvas, 35, 80, Paint()..color = AppTheme.splashTealMedium);
    canvas.restore();

    // Hat is an image asset now
  }

  void _drawLeaf(Canvas canvas, double width, double height, Paint p) {
    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(width * 0.5, height * 0.3, width * 0.4, height);
    path.quadraticBezierTo(0, height * 0.7, 0, 0);
    canvas.drawPath(path, p);
    for (int i = 1; i <= 3; i++) {
      final y = height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(width * 0.5, y), Paint()..color = const Color(0xFF15887E)..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
