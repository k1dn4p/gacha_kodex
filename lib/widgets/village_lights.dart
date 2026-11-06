import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../advent/village_config.dart';

/// A separate repaint boundary keeps the PNG scene from repainting each tick.
class VillageLights extends StatefulWidget {
  final List<VillageLight> lights;
  const VillageLights({super.key, required this.lights});

  @override
  State<VillageLights> createState() => _VillageLightsState();
}

class _VillageLightsState extends State<VillageLights>
    with SingleTickerProviderStateMixin {
  late final _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  void _updateAnimation() {
    final animate = widget.lights.isNotEmpty &&
        !MediaQuery.disableAnimationsOf(context);
    if (animate && !_clock.isAnimating) {
      _clock.repeat();
    } else if (!animate) {
      _clock.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant VillageLights oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimation();
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _LightPainter(widget.lights, _clock),
          ),
        ),
      );
}

class _LightPainter extends CustomPainter {
  final List<VillageLight> lights;
  final Animation<double> clock;
  _LightPainter(this.lights, this.clock) : super(repaint: clock);

  @override
  void paint(Canvas canvas, Size size) {
    for (final light in lights) {
      // Different phases prevent the lights from flashing all together.
      final wave = (1 + math.sin((clock.value + light.phase) * 2 * math.pi)) / 2;
      final brightness = 0.25 + 0.75 * wave * wave;
      final haloRadius = light.radius * 4;
      final halo = Paint()
        ..shader = RadialGradient(colors: [
          adventGold.withValues(alpha: brightness * 0.65),
          adventGold.withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(
            center: light.position, radius: haloRadius));
      canvas.drawCircle(light.position, haloRadius, halo);
      canvas.drawCircle(
        light.position,
        light.radius * (0.7 + wave * 0.3),
        Paint()..color = const Color(0xFFFFF4CE).withValues(alpha: brightness),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LightPainter oldDelegate) =>
      oldDelegate.lights != lights || oldDelegate.clock != clock;
}
