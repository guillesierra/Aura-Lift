import 'package:flutter/material.dart';

class MuscleGroupIcon extends StatelessWidget {
  const MuscleGroupIcon({
    super.key,
    required this.muscleGroup,
    this.size = 58,
  });

  final String muscleGroup;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: CustomPaint(
        painter: _MuscleGroupPainter(
          muscleGroup: muscleGroup,
          bodyColor: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.22),
          outlineColor: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.42),
          highlightColor: Colors.redAccent,
        ),
      ),
    );
  }
}

class _MuscleGroupPainter extends CustomPainter {
  const _MuscleGroupPainter({
    required this.muscleGroup,
    required this.bodyColor,
    required this.outlineColor,
    required this.highlightColor,
  });

  final String muscleGroup;
  final Color bodyColor;
  final Color outlineColor;
  final Color highlightColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);

    final bodyPaint = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.fill;
    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final highlightPaint = Paint()
      ..color = highlightColor.withValues(alpha: 0.86)
      ..style = PaintingStyle.fill;

    _drawBody(canvas, bodyPaint, outlinePaint);
    _drawHighlights(canvas, highlightPaint, outlinePaint);

    canvas.restore();
  }

  void _drawBody(Canvas canvas, Paint bodyPaint, Paint outlinePaint) {
    canvas.drawCircle(const Offset(50, 13), 8.5, bodyPaint);
    canvas.drawCircle(const Offset(50, 13), 8.5, outlinePaint);

    final torso = RRect.fromRectAndRadius(
      const Rect.fromLTWH(34, 24, 32, 39),
      const Radius.circular(13),
    );
    canvas.drawRRect(torso, bodyPaint);
    canvas.drawRRect(torso, outlinePaint);

    final leftArm = Path()
      ..moveTo(35, 29)
      ..quadraticBezierTo(23, 35, 22, 53)
      ..quadraticBezierTo(22, 66, 29, 69)
      ..quadraticBezierTo(33, 56, 36, 34)
      ..close();
    final rightArm = Path()
      ..moveTo(65, 29)
      ..quadraticBezierTo(77, 35, 78, 53)
      ..quadraticBezierTo(78, 66, 71, 69)
      ..quadraticBezierTo(67, 56, 64, 34)
      ..close();
    canvas.drawPath(leftArm, bodyPaint);
    canvas.drawPath(rightArm, bodyPaint);
    canvas.drawPath(leftArm, outlinePaint);
    canvas.drawPath(rightArm, outlinePaint);

    final leftLeg = Path()
      ..moveTo(39, 61)
      ..lineTo(49, 61)
      ..lineTo(47, 90)
      ..quadraticBezierTo(42, 94, 37, 90)
      ..lineTo(36, 68)
      ..close();
    final rightLeg = Path()
      ..moveTo(51, 61)
      ..lineTo(61, 61)
      ..lineTo(64, 90)
      ..quadraticBezierTo(58, 94, 53, 90)
      ..lineTo(51, 61)
      ..close();
    canvas.drawPath(leftLeg, bodyPaint);
    canvas.drawPath(rightLeg, bodyPaint);
    canvas.drawPath(leftLeg, outlinePaint);
    canvas.drawPath(rightLeg, outlinePaint);
  }

  void _drawHighlights(Canvas canvas, Paint paint, Paint outlinePaint) {
    switch (_normalize(muscleGroup)) {
      case 'pecho':
        _rrect(canvas, const Rect.fromLTWH(37, 28, 11, 13), 5, paint);
        _rrect(canvas, const Rect.fromLTWH(52, 28, 11, 13), 5, paint);
      case 'espalda':
        final leftLat = Path()
          ..moveTo(36, 33)
          ..quadraticBezierTo(31, 42, 34, 56)
          ..lineTo(44, 57)
          ..lineTo(45, 35)
          ..close();
        final rightLat = Path()
          ..moveTo(64, 33)
          ..quadraticBezierTo(69, 42, 66, 56)
          ..lineTo(56, 57)
          ..lineTo(55, 35)
          ..close();
        canvas.drawPath(leftLat, paint);
        canvas.drawPath(rightLat, paint);
      case 'hombros':
        canvas.drawCircle(const Offset(33, 31), 6.8, paint);
        canvas.drawCircle(const Offset(67, 31), 6.8, paint);
      case 'biceps':
        _rrect(canvas, const Rect.fromLTWH(24, 36, 9, 20), 5, paint);
        _rrect(canvas, const Rect.fromLTWH(67, 36, 9, 20), 5, paint);
      case 'triceps':
        _rrect(canvas, const Rect.fromLTWH(24, 47, 8, 19), 5, paint);
        _rrect(canvas, const Rect.fromLTWH(68, 47, 8, 19), 5, paint);
      case 'piernas':
        _rrect(canvas, const Rect.fromLTWH(37, 63, 10, 20), 5, paint);
        _rrect(canvas, const Rect.fromLTWH(53, 63, 10, 20), 5, paint);
      case 'gemelos':
        _rrect(canvas, const Rect.fromLTWH(37, 79, 10, 13), 5, paint);
        _rrect(canvas, const Rect.fromLTWH(53, 79, 10, 13), 5, paint);
      case 'core':
        _rrect(canvas, const Rect.fromLTWH(42, 43, 16, 17), 6, paint);
      case 'trapecio':
        final traps = Path()
          ..moveTo(42, 22)
          ..lineTo(58, 22)
          ..lineTo(66, 31)
          ..lineTo(34, 31)
          ..close();
        canvas.drawPath(traps, paint);
      case 'cardio':
        _rrect(canvas, const Rect.fromLTWH(38, 29, 24, 18), 8, paint);
        final pulse = Path()
          ..moveTo(32, 52)
          ..lineTo(42, 52)
          ..lineTo(46, 44)
          ..lineTo(53, 60)
          ..lineTo(58, 52)
          ..lineTo(68, 52);
        canvas.drawPath(
          pulse,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.92)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      default:
        _rrect(canvas, const Rect.fromLTWH(42, 34, 16, 23), 7, paint);
    }
  }

  void _rrect(Canvas canvas, Rect rect, double radius, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      paint,
    );
  }

  String _normalize(String value) {
    return value.trim().toLowerCase();
  }

  @override
  bool shouldRepaint(covariant _MuscleGroupPainter oldDelegate) {
    return oldDelegate.muscleGroup != muscleGroup ||
        oldDelegate.bodyColor != bodyColor ||
        oldDelegate.outlineColor != outlineColor ||
        oldDelegate.highlightColor != highlightColor;
  }
}
