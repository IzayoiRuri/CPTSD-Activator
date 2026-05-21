import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';

/// 撒花特效 — 任务完成时全屏粒子动画
/// 强度根据 EffortLevel 分级：Light/Medium/Heavy
/// 遵循 DESIGN.md confetti 规范
class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback? onFinished;
  final int particleCount;
  final double durationSeconds;
  final double spread;
  final double velocity;

  const ConfettiOverlay({
    super.key,
    required this.child,
    this.onFinished,
    this.particleCount = 20,
    this.durationSeconds = 1.5,
    this.spread = 0.3,
    this.velocity = 1.0,
  });

  /// 根据任务强度创建撒花
  factory ConfettiOverlay.forEffort({
    required Widget child,
    required String effort,
    VoidCallback? onFinished,
  }) {
    switch (effort) {
      case 'light':
        return ConfettiOverlay(
          child: child,
          particleCount: 20,
          durationSeconds: 1.5,
          spread: 0.3,
          velocity: 0.7,
          onFinished: onFinished,
        );
      case 'medium':
        return ConfettiOverlay(
          child: child,
          particleCount: 50,
          durationSeconds: 2.5,
          spread: 0.5,
          velocity: 1.0,
          onFinished: onFinished,
        );
      case 'heavy':
        return ConfettiOverlay(
          child: child,
          particleCount: 100,
          durationSeconds: 3.5,
          spread: 0.8,
          velocity: 1.3,
          onFinished: onFinished,
        );
      default:
        return ConfettiOverlay(child: child, onFinished: onFinished);
    }
  }

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _overlayOpacity;
  List<_Particle> _particles = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (widget.durationSeconds * 1000).round()),
    );

    _overlayOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.15, curve: Curves.easeInOut),
      ),
    );

    _generateParticles();

    _controller.forward().then((_) {
      widget.onFinished?.call();
    });
  }

  void _generateParticles() {
    final colors = AppTheme.confettiColors;
    final screenW = 412.0; // max design width
    final screenH = 800.0;

    _particles = List.generate(widget.particleCount, (i) {
      final color = colors[_random.nextInt(colors.length)];
      final x = screenW / 2 + (_random.nextDouble() - 0.5) * screenW * widget.spread;
      final y = -20.0 - _random.nextDouble() * 100;
      final size = 4.0 + _random.nextDouble() * 4.0;
      final speed = 200.0 + _random.nextDouble() * 300.0 * widget.velocity;
      final angle = -pi / 2 + (_random.nextDouble() - 0.5) * pi * widget.spread;
      final rotation = _random.nextDouble() * 360;
      final rotationSpeed = (_random.nextDouble() - 0.5) * 720.0;

      return _Particle(
        x: x,
        y: y,
        size: size,
        color: color,
        speed: speed,
        angle: angle,
        rotation: rotation,
        rotationSpeed: rotationSpeed,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              children: [
                Expanded(
                  child: IgnorePointer(
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _ConfettiPainter(
                        particles: _particles,
                        progress: _controller.value,
                        duration: widget.durationSeconds,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        // Backdrop
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _overlayOpacity,
              builder: (context, _) {
                final fadeProgress = _controller.value;
                final backdropOpacity = fadeProgress < 0.15
                    ? fadeProgress / 0.15 * 0.15
                    : fadeProgress > 0.85
                        ? (1.0 - fadeProgress) / 0.15 * 0.15
                        : 0.15;
                return Container(
                  color: Colors.black.withOpacity(backdropOpacity),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double speed;
  final double angle;
  final double rotation;
  final double rotationSpeed;

  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
    required this.angle,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final double duration;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
    required this.duration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final dt = progress * duration;
      final dx = cos(p.angle) * p.speed * dt;
      final dy = sin(p.angle) * p.speed * dt + 0.5 * 200 * dt * dt;

      // Fade in last 30%
      final fadeProgress = progress > 0.7 ? (1.0 - progress) / 0.3 : 1.0;
      final opacity = fadeProgress.clamp(0.0, 1.0);

      if (opacity <= 0) continue;

      final paint = Paint()
        ..color = p.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(p.x + dx, p.y + dy);
      canvas.rotate(p.rotation + p.rotationSpeed * progress * pi / 180);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
