import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/constants.dart';

class ActivityRingWidget extends StatelessWidget {
  final double moveProgress;      // 0.0 - 1.0 (Red ring)
  final double exerciseProgress;  // 0.0 - 1.0 (Green ring)
  final double hydrationProgress; // 0.0 - 1.0 (Blue ring)
  final double size;

  const ActivityRingWidget({
    super.key,
    required this.moveProgress,
    required this.exerciseProgress,
    required this.hydrationProgress,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ActivityRingPainter(
        moveProgress:      moveProgress,
        exerciseProgress:  exerciseProgress,
        hydrationProgress: hydrationProgress,
      ),
    );
  }
}

class _ActivityRingPainter extends CustomPainter {
  final double moveProgress;
  final double exerciseProgress;
  final double hydrationProgress;

  _ActivityRingPainter({
    required this.moveProgress,
    required this.exerciseProgress,
    required this.hydrationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center      = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.095;
    final spacing     = strokeWidth * 1.15;

    final r1 = (size.width / 2) - (strokeWidth / 2);
    final r2 = r1 - spacing;
    final r3 = r2 - spacing;

    // Background tracks
    _drawTrack(canvas, center, r1, strokeWidth, AppColors.appleRed.withValues(alpha: 0.18));
    _drawTrack(canvas, center, r2, strokeWidth, AppColors.appleGreen.withValues(alpha: 0.18));
    _drawTrack(canvas, center, r3, strokeWidth, AppColors.appleBlue.withValues(alpha: 0.18));

    // Progress arcs
    _drawArc(canvas, center, r1, strokeWidth, AppColors.appleRed,   moveProgress);
    _drawArc(canvas, center, r2, strokeWidth, AppColors.appleGreen, exerciseProgress);
    _drawArc(canvas, center, r3, strokeWidth, AppColors.appleBlue,  hydrationProgress);
  }

  void _drawTrack(Canvas canvas, Offset center, double radius, double width, Color color) {
    final paint = Paint()
      ..color       = color
      ..style       = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap   = StrokeCap.round;
    canvas.drawCircle(center, radius, paint);
  }

  void _drawArc(Canvas canvas, Offset center, double radius, double width, Color color, double progress) {
    if (progress <= 0) return;
    final sweepAngle = (progress.clamp(0.0, 1.0)) * 2 * pi;
    final paint = Paint()
      ..color       = color
      ..style       = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap   = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ActivityRingPainter old) =>
      old.moveProgress      != moveProgress ||
      old.exerciseProgress  != exerciseProgress ||
      old.hydrationProgress != hydrationProgress;
}

class SingleRingWidget extends StatelessWidget {
  final double progress;
  final Color ringColor;
  final Color ringBgColor;
  final double size;
  final double strokeWidth;
  final Widget? child;

  const SingleRingWidget({
    super.key,
    required this.progress,
    required this.ringColor,
    required this.ringBgColor,
    this.size        = 120,
    this.strokeWidth = 14,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _SingleRingPainter(
              progress:    progress,
              ringColor:   ringColor,
              ringBgColor: ringBgColor,
              strokeWidth: strokeWidth,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _SingleRingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color ringBgColor;
  final double strokeWidth;

  _SingleRingPainter({
    required this.progress,
    required this.ringColor,
    required this.ringBgColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);

    final bgPaint = Paint()
      ..color       = ringBgColor
      ..style       = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap   = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (progress > 0) {
      final sweepAngle = (progress.clamp(0.0, 1.0)) * 2 * pi;
      final arcPaint = Paint()
        ..color       = ringColor
        ..style       = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap   = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SingleRingPainter old) =>
      old.progress    != progress ||
      old.ringColor   != ringColor ||
      old.ringBgColor != ringBgColor;
}
