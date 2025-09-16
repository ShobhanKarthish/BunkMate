import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/constants/ui_constants.dart';
import '../core/theme/app_theme.dart';

class ProgressRing extends StatefulWidget {
  final double percentage;
  final double minRequired;
  final double size;
  final double strokeWidth;
  final bool showPercentage;
  final TextStyle? textStyle;

  const ProgressRing({
    super.key,
    required this.percentage,
    required this.minRequired,
    this.size = UIConstants.progressRingSize,
    this.strokeWidth = UIConstants.progressRingStroke,
    this.showPercentage = true,
    this.textStyle,
  });

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: UIConstants.animationMedium,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.percentage / 100,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void didUpdateWidget(ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.percentage / 100,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getProgressColor() {
    if (widget.percentage >= widget.minRequired) {
      return AppTheme.attendanceGreen;
    } else if (widget.percentage >= widget.minRequired - 10) {
      return AppTheme.warningYellow;
    } else {
      return AppTheme.alertRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _RingPainter(
              progress: 1.0,
              color: Colors.grey.shade200,
              strokeWidth: widget.strokeWidth,
            ),
          ),
          // Progress ring
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: _animation.value,
                  color: _getProgressColor(),
                  strokeWidth: widget.strokeWidth,
                ),
              );
            },
          ),
          // Percentage text
          if (widget.showPercentage)
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final displayPercentage = (_animation.value * 100).round();
                return Text(
                  '$displayPercentage%',
                  style: widget.textStyle ??
                      TextStyle(
                        fontSize: widget.size * 0.2,
                        fontWeight: FontWeight.w700,
                        color: UIConstants.primaryText,
                        letterSpacing: -0.5,
                      ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw the arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      2 * math.pi * progress, // Progress amount
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
