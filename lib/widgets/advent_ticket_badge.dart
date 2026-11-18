import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/advent_provider.dart';
import '../providers/app_settings_provider.dart';

class AdventTicketBadge extends StatefulWidget {
  final int celebrationId;
  const AdventTicketBadge({super.key, this.celebrationId = 0});

  @override
  State<AdventTicketBadge> createState() => _AdventTicketBadgeState();
}

class _AdventTicketBadgeState extends State<AdventTicketBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sparkle;

  @override
  void initState() {
    super.initState();
    _sparkle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
  }

  @override
  void didUpdateWidget(covariant AdventTicketBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.celebrationId != oldWidget.celebrationId) {
      if (!MediaQuery.disableAnimationsOf(context)) {
        _sparkle.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _sparkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!context.watch<AppSettingsProvider>().adventCalendar) {
      return const SizedBox.shrink();
    }
    final advent = context.watch<AdventProvider>();
    final balance = advent.isLoading ? '…' : '${advent.ticketBalance}';
    return Semantics(
      label: advent.isLoading ? '보유 티켓 불러오는 중' : '보유 티켓 $balance장',
      liveRegion: true,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(left: 4, right: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _sparkle,
                builder: (context, child) {
                  final pulse = math.sin(_sparkle.value * math.pi * 3).abs();
                  return CustomPaint(
                    key: const ValueKey('ticket-sparkle'),
                    foregroundPainter: _TicketSparklePainter(_sparkle.value),
                    child: Transform.scale(
                      scale: 1 + pulse * 0.18,
                      child: child,
                    ),
                  );
                },
                child: SizedBox(
                  width: 52,
                  height: 48,
                  child: Center(
                    child: Image.asset(
                      'assets/images/advent/ticket.png',
                      width: 44,
                      height: 36,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                balance,
                key: const ValueKey('advent-ticket-balance'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketSparklePainter extends CustomPainter {
  final double progress;
  const _TicketSparklePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final envelope = math.sin(progress * math.pi);
    final center = size.center(Offset.zero);
    final glow = Paint()
      ..shader = RadialGradient(colors: [
        const Color(0xFFFFD35A).withValues(alpha: envelope * 0.45),
        const Color(0xFFFFD35A).withValues(alpha: 0),
      ]).createShader(Rect.fromCircle(center: center, radius: 26));
    canvas.drawCircle(center, 26, glow);

    const positions = [
      Offset(0.12, 0.25),
      Offset(0.76, 0.12),
      Offset(0.93, 0.52),
      Offset(0.68, 0.86),
      Offset(0.18, 0.79),
    ];
    for (var i = 0; i < positions.length; i++) {
      final twinkle =
          math.sin(progress * math.pi * 7 - i * 1.3).clamp(0.0, 1.0);
      final strength = twinkle * envelope;
      final radius = 2 + 5 * strength;
      final point = Offset(
        size.width * positions[i].dx,
        size.height * positions[i].dy - 4 * progress,
      );
      final star = Path();
      for (var tip = 0; tip < 8; tip++) {
        final angle = tip * math.pi / 4 - math.pi / 2;
        final length = tip.isEven ? radius : radius * 0.25;
        final x = point.dx + math.cos(angle) * length;
        final y = point.dy + math.sin(angle) * length;
        if (tip == 0) {
          star.moveTo(x, y);
        } else {
          star.lineTo(x, y);
        }
      }
      star.close();
      canvas.drawPath(
        star,
        Paint()..color = const Color(0xFFFFD35A).withValues(alpha: strength),
      );
      canvas.drawCircle(
        point,
        strength * 1.5,
        Paint()..color = Colors.white.withValues(alpha: strength),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TicketSparklePainter oldDelegate) =>
      progress != oldDelegate.progress;
}
