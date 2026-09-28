import 'dart:math' as math;
import 'package:flutter/material.dart';

class CyberRadarHero extends StatefulWidget {
  final double size;

  const CyberRadarHero({
    super.key,
    this.size = 230,
  });

  @override
  State<CyberRadarHero> createState() => _CyberRadarHeroState();
}

class _CyberRadarHeroState extends State<CyberRadarHero>
    with TickerProviderStateMixin {
  late AnimationController _sweepController;
  late AnimationController _reticleController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    // 3.5s 360-degree radar sweep beam
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat();

    // 24s slow tactical outer ring rotation
    _reticleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    // 2s gentle breathing pulse for core beacon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sweepController.dispose();
    _reticleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tactical SOC status badge
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final opacity = 0.5 + (_pulseController.value * 0.5);
              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.12 * opacity),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00E676).withValues(alpha: opacity),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E676).withValues(alpha: opacity),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SOC RADAR ACTIVE // 0-LATENCY PROBE',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: primaryColor.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Main Animated Radar Dial
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Ambient Background Luminescence
                Container(
                  width: widget.size * 0.95,
                  height: widget.size * 0.95,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        primaryColor.withValues(alpha: 0.15),
                        primaryColor.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),

                // 2. Slow Rotating Segmented Azimuth Ring
                AnimatedBuilder(
                  animation: _reticleController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _reticleController.value * 2 * math.pi,
                      child: CustomPaint(
                        size: Size(widget.size, widget.size),
                        painter: _AzimuthReticlePainter(primaryColor: primaryColor),
                      ),
                    );
                  },
                ),

                // 3. Static Concentric Grid & Crosshairs
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _RadarGridPainter(primaryColor: primaryColor),
                ),

                // 4. Continuous Sweeping Radar Beam with reactive blips
                AnimatedBuilder(
                  animation: _sweepController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: _RadarSweepPainter(
                        sweepAngle: _sweepController.value * 2 * math.pi,
                        primaryColor: primaryColor,
                      ),
                    );
                  },
                ),

                // 5. Pulsing Target Lock Center Core
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 0.94 + (_pulseController.value * 0.12);
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0A0D12),
                          border: Border.all(
                            color: primaryColor,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.radar,
                          size: 24,
                          color: primaryColor,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for static concentric range rings and crosshair axes
class _RadarGridPainter extends CustomPainter {
  final Color primaryColor;

  _RadarGridPainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (size.width / 2) * 0.88;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    // Outer boundary circle
    ringPaint
      ..color = primaryColor.withValues(alpha: 0.28)
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, maxRadius, ringPaint);

    // Intermediate range rings
    ringPaint
      ..color = primaryColor.withValues(alpha: 0.16)
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, maxRadius * 0.66, ringPaint);

    ringPaint
      ..color = primaryColor.withValues(alpha: 0.12)
      ..strokeWidth = 0.8;
    canvas.drawCircle(center, maxRadius * 0.36, ringPaint);

    // Coordinate crosshairs (horizontal and vertical axis)
    final axisPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(center.dx - maxRadius, center.dy),
      Offset(center.dx + maxRadius, center.dy),
      axisPaint,
    );

    canvas.drawLine(
      Offset(center.dx, center.dy - maxRadius),
      Offset(center.dx, center.dy + maxRadius),
      axisPaint,
    );

    // Diagonal quadrant ticks
    final tickPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.3)
      ..strokeWidth = 1.2;

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi) / 4;
      final start = Offset(
        center.dx + (maxRadius - 6) * math.cos(angle),
        center.dy + (maxRadius - 6) * math.sin(angle),
      );
      final end = Offset(
        center.dx + maxRadius * math.cos(angle),
        center.dy + maxRadius * math.sin(angle),
      );
      canvas.drawLine(start, end, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for the slowly rotating outer reticle ring with segmented dashes
class _AzimuthReticlePainter extends CustomPainter {
  final Color primaryColor;

  _AzimuthReticlePainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final reticleRadius = (size.width / 2) * 0.96;

    final dashPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Draw 16 segmented notches around perimeter
    const totalDashes = 16;
    for (int i = 0; i < totalDashes; i++) {
      final angle = (i * 2 * math.pi) / totalDashes;
      final isMajor = i % 4 == 0;
      final len = isMajor ? 9.0 : 5.0;

      final p1 = Offset(
        center.dx + (reticleRadius - len) * math.cos(angle),
        center.dy + (reticleRadius - len) * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + reticleRadius * math.cos(angle),
        center.dy + reticleRadius * math.sin(angle),
      );

      dashPaint.strokeWidth = isMajor ? 2.5 : 1.5;
      dashPaint.color = primaryColor.withValues(alpha: isMajor ? 0.65 : 0.3);
      canvas.drawLine(p1, p2, dashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for sweeping radar beam and reactive threat blips
class _RadarSweepPainter extends CustomPainter {
  final double sweepAngle;
  final Color primaryColor;

  // Static positions of simulated threat blips (angle, radiusRatio, color)
  static const List<_BlipTarget> blips = [
    _BlipTarget(0.95, 0.72, Color(0xFF00E676)), // Green Safe Node
    _BlipTarget(2.55, 0.52, Color(0xFFFFB300)), // Amber Suspicious Node
    _BlipTarget(4.80, 0.78, Color(0xFFFF1744)), // Crimson Threat Node
  ];

  _RadarSweepPainter({
    required this.sweepAngle,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (size.width / 2) * 0.88;

    // 1. Radar Sweep Sector & Ray using canvas rotation (100% web-safe, no negative startAngle)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(sweepAngle);

    final localRect = Rect.fromCircle(center: Offset.zero, radius: maxRadius);
    final sweepGradient = SweepGradient(
      center: Alignment.center,
      startAngle: 0.0,
      endAngle: math.pi / 3,
      colors: [
        primaryColor.withValues(alpha: 0.22),
        primaryColor.withValues(alpha: 0.04),
        Colors.transparent,
      ],
      stops: const [0.0, 0.55, 1.0],
    );

    final sweepPaint = Paint()
      ..shader = sweepGradient.createShader(localRect)
      ..style = PaintingStyle.fill;

    // Draw sector trailing by 60 degrees behind the leading ray
    canvas.drawArc(
      localRect,
      -(math.pi / 3),
      math.pi / 3,
      true,
      sweepPaint,
    );

    // Leading sweep ray line along local 0 angle
    final rayPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.85)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawLine(Offset.zero, Offset(maxRadius, 0), rayPaint);
    canvas.restore();

    // 2. Reactive Simulated Threat Blip Nodes
    for (final blip in blips) {
      // Calculate angular distance between sweep beam and blip
      double diff = (sweepAngle - blip.angle) % (2 * math.pi);
      if (diff < 0) diff += 2 * math.pi;

      // Brightness spikes when beam passes (0 to 0.8 rad tail)
      double intensity = 0.0;
      if (diff < 0.75) {
        intensity = (1.0 - (diff / 0.75)).clamp(0.0, 1.0);
      }

      final blipCenter = Offset(
        center.dx + (maxRadius * blip.distanceRatio) * math.cos(blip.angle),
        center.dy + (maxRadius * blip.distanceRatio) * math.sin(blip.angle),
      );

      // Resting dot
      final restingPaint = Paint()
        ..color = blip.color.withValues(alpha: 0.25 + (0.75 * intensity))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(blipCenter, 3.2, restingPaint);

      // Glowing ping halo when illuminated by sweep
      if (intensity > 0.05) {
        final glowPaint = Paint()
          ..color = blip.color.withValues(alpha: 0.4 * intensity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        canvas.drawCircle(blipCenter, 4.0 + (6.0 * (1.0 - intensity)), glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RadarSweepPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle || oldDelegate.primaryColor != primaryColor;
  }
}

class _BlipTarget {
  final double angle;
  final double distanceRatio;
  final Color color;

  const _BlipTarget(this.angle, this.distanceRatio, this.color);
}
