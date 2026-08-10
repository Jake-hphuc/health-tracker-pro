import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Vẽ một vòng tròn tiến trình đơn lẻ (như Apple Activity Ring)
class _RingPainter extends CustomPainter {
  final double progress;  // 0.0 → 1.0
  final Color ringColor;
  final Color bgColor;
  final double strokeWidth;

  const _RingPainter({
    required this.progress,
    required this.ringColor,
    required this.bgColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect   = Rect.fromCircle(center: center, radius: radius);

    // Background ring
    final bgPaint = Paint()
      ..color       = bgColor
      ..strokeWidth = strokeWidth
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    // Glow shadow
    final glowPaint = Paint()
      ..color       = ringColor.withValues(alpha: 0.35)
      ..strokeWidth = strokeWidth + 6
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round
      ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawArc(rect, -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0), false, glowPaint);

    // Foreground ring (gradient via shader)
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    final shader = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + (sweepAngle > 0 ? sweepAngle : 0.001),
      colors: [ringColor, ringColor.withValues(alpha: 0.7)],
    ).createShader(rect);

    final fgPaint = Paint()
      ..shader      = shader
      ..strokeWidth = strokeWidth
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, fgPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.ringColor != ringColor;
}

// ============================================================
/// Widget 3 vòng tròn đồng tâm kiểu Apple Watch Activity Ring
// ============================================================
class ActivityRingWidget extends StatefulWidget {
  final double moveProgress;     // Vận động (đỏ) — ngoài cùng
  final double exerciseProgress; // Thể dục  (xanh lá) — giữa
  final double hydrationProgress;// Nước uống (xanh dương) — trong cùng

  final double size;
  final Widget? centerWidget;

  const ActivityRingWidget({
    super.key,
    required this.moveProgress,
    required this.exerciseProgress,
    required this.hydrationProgress,
    this.size = 200,
    this.centerWidget,
  });

  @override
  State<ActivityRingWidget> createState() => _ActivityRingWidgetState();
}

class _ActivityRingWidgetState extends State<ActivityRingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    const sw1 = 20.0; // outer
    const sw2 = 20.0; // middle
    const sw3 = 20.0; // inner
    const gap  = 10.0;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final t = _anim.value;
        return SizedBox(
          width:  s,
          height: s,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring — Vận động (đỏ)
              CustomPaint(
                size: Size(s, s),
                painter: _RingPainter(
                  progress:    widget.moveProgress * t,
                  ringColor:   AppColors.appleRed,
                  bgColor:     AppColors.appleRed.withValues(alpha: 0.15),
                  strokeWidth: sw1,
                ),
              ),

              // Middle ring — Thể dục (xanh lá)
              CustomPaint(
                size: Size(s - (sw1 + gap) * 2, s - (sw1 + gap) * 2),
                painter: _RingPainter(
                  progress:    widget.exerciseProgress * t,
                  ringColor:   AppColors.appleGreen,
                  bgColor:     AppColors.appleGreen.withValues(alpha: 0.15),
                  strokeWidth: sw2,
                ),
              ),

              // Inner ring — Nước (xanh dương)
              CustomPaint(
                size: Size(s - (sw1 + sw2 + gap * 2) * 2,
                           s - (sw1 + sw2 + gap * 2) * 2),
                painter: _RingPainter(
                  progress:    widget.hydrationProgress * t,
                  ringColor:   AppColors.appleBlue,
                  bgColor:     AppColors.appleBlue.withValues(alpha: 0.15),
                  strokeWidth: sw3,
                ),
              ),

              // Center content
              if (widget.centerWidget != null) widget.centerWidget!,
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
/// Widget vòng tròn đơn dùng cho màn hình chi tiết
// ============================================================
class SingleRingWidget extends StatefulWidget {
  final double progress;
  final Color  color;
  final double size;
  final double strokeWidth;
  final Widget child;

  const SingleRingWidget({
    super.key,
    required this.progress,
    required this.color,
    required this.child,
    this.size = 180,
    this.strokeWidth = 18,
  });

  @override
  State<SingleRingWidget> createState() => _SingleRingWidgetState();
}

class _SingleRingWidgetState extends State<SingleRingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(SingleRingWidget old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _RingPainter(
              progress:    widget.progress * _anim.value,
              ringColor:   widget.color,
              bgColor:     widget.color.withValues(alpha: 0.12),
              strokeWidth: widget.strokeWidth,
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}
