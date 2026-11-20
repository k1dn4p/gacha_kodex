import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'gacha_image.dart';

class TicketTearDialog extends StatefulWidget {
  // Tune these values while previewing the tear effect.
  static const double defaultRevealProgress = 0.5;
  static const double maxShakeOffset = 9;
  static const double revealScale = 1.08;
  static const Duration revealHoldDuration = Duration(milliseconds: 170);

  const TicketTearDialog({
    super.key,
    required this.unopenedImagePath,
    required this.openedImagePath,
    this.onOpened,
    this.commitOpening,
    this.prizeLevel,
    this.revealProgress = defaultRevealProgress,
  }) : assert(revealProgress > 0 && revealProgress < 1);

  final String unopenedImagePath;
  final String openedImagePath;
  final VoidCallback? onOpened;
  final Future<bool> Function()? commitOpening;
  final String? prizeLevel;
  final double revealProgress;

  static Future<bool> show(
    BuildContext context, {
    required String unopenedImagePath,
    required String openedImagePath,
    VoidCallback? onOpened,
    Future<bool> Function()? commitOpening,
    String? prizeLevel,
    double revealProgress = defaultRevealProgress,
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: '쿠지 열기',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return TicketTearDialog(
          unopenedImagePath: unopenedImagePath,
          openedImagePath: openedImagePath,
          onOpened: onOpened,
          commitOpening: commitOpening,
          prizeLevel: prizeLevel,
          revealProgress: revealProgress,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );

    return result ?? false;
  }

  @override
  State<TicketTearDialog> createState() => _TicketTearDialogState();
}

class _TicketTearDialogState extends State<TicketTearDialog>
    with TickerProviderStateMixin {
  late final AnimationController _tearController;
  late final AnimationController _shakeController;
  late final AnimationController _celebrationController;
  Timer? _revealTimer;
  bool _holdingReveal = false;
  bool _resumeOpening = false;
  double _pendingProgress = 0;
  bool _celebrated = false;
  bool _isOpened = false;
  bool _committing = false;
  bool _dragCancelled = false;

  Future<void> _commit() async {
    if (_committing) return;
    setState(() => _committing = true);
    try {
      final success =
          await (widget.commitOpening?.call() ?? Future.value(true));
      if (!mounted) return;
      if (success) {
        setState(() => _isOpened = true);
        widget.onOpened?.call();
      } else {
        _tearController.value = 0;
      }
    } catch (_) {
      if (mounted) {
        _tearController.value = 0;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('저장하지 못했어요. 다시 시도해 주세요.')));
      }
    } finally {
      if (mounted) setState(() => _committing = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _tearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )
      ..addListener(_updateEffects)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed &&
            _tearController.value == 1 &&
            !_isOpened &&
            mounted) {
          _commit();
        }
      });
  }

  void _updateEffects() {
    final progress = _tearController.value;
    if (progress > 0 && progress < 1 && !_holdingReveal) {
      if (!_shakeController.isAnimating) _shakeController.repeat();
    } else {
      _shakeController.stop();
    }
    if (progress == 0) {
      _celebrated = false;
      _celebrationController.reset();
    } else if (!_celebrated &&
        !_dragCancelled &&
        progress >= widget.revealProgress &&
        (widget.prizeLevel == 'A' || widget.prizeLevel == 'B')) {
      _celebrated = true;
      _celebrationController.forward(from: 0);
      _pendingProgress = progress;
      _resumeOpening = _tearController.isAnimating;
      _holdingReveal = true;
      _tearController.stop();
      _shakeController.stop();
      _tearController.value = widget.revealProgress;
      _revealTimer = Timer(TicketTearDialog.revealHoldDuration, () {
        if (!mounted) return;
        setState(() => _holdingReveal = false);
        _tearController.value = _pendingProgress;
        if (_resumeOpening && !_dragCancelled && !_isOpened) {
          _tearController.animateTo(1,
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic);
        }
      });
    }
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _tearController.dispose();
    _shakeController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _updateTear(DragUpdateDetails details, double width) {
    if (_isOpened || _committing || width <= 0) return;
    if (_holdingReveal) {
      _pendingProgress =
          (_pendingProgress + details.delta.dx / width).clamp(0.0, 1.0);
      return;
    }
    _tearController.value =
        (_tearController.value + details.delta.dx / width).clamp(0.0, 1.0);
  }

  void _finishTear(DragEndDetails details) {
    if (_isOpened || _committing) return;
    if (_dragCancelled) {
      _tearController.animateTo(0, duration: const Duration(milliseconds: 260));
      return;
    }

    if (_holdingReveal) {
      if (_pendingProgress >= 0.35 ||
          details.velocity.pixelsPerSecond.dx > 500) {
        _resumeOpening = true;
      } else {
        _revealTimer?.cancel();
        _holdingReveal = false;
        _resumeOpening = false;
        _celebrationController.reset();
        _tearController.animateTo(0,
            duration: const Duration(milliseconds: 260));
      }
      return;
    }

    final shouldOpen = _tearController.value >= 0.35 ||
        details.velocity.pixelsPerSecond.dx > 500;
    _tearController.animateTo(
      shouldOpen ? 1 : 0,
      curve: shouldOpen ? Curves.easeOutCubic : Curves.easeOut,
      duration: Duration(
        milliseconds: shouldOpen ? 420 : 260,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                key: const ValueKey('tear-celebration'),
                painter: _TicketCelebrationPainter(_celebrationController,
                    glow: true),
              ),
            ),
          ),
          Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.sizeOf(context)
                    .width
                    .clamp(280.0, 620.0)
                    .toDouble(),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 30,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isOpened ? '쿠지가 열렸어요!' : '쿠지를 뜯어주세요',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _isOpened ? '당첨 결과를 확인해 볼까요?' : '티켓을 오른쪽으로 밀어 뜯어주세요',
                        key: ValueKey(_isOpened),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onHorizontalDragUpdate: (details) =>
                                _updateTear(details, constraints.maxWidth),
                            onHorizontalDragEnd: _finishTear,
                            child: Listener(
                              onPointerDown: (_) => _dragCancelled = false,
                              onPointerCancel: (_) {
                                _dragCancelled = true;
                                _revealTimer?.cancel();
                                _holdingReveal = false;
                                _resumeOpening = false;
                                _celebrationController.reset();
                                if (!_isOpened && !_committing) {
                                  _tearController.animateTo(0,
                                      duration:
                                          const Duration(milliseconds: 260));
                                }
                              },
                              child: AnimatedBuilder(
                                animation: Listenable.merge([
                                  _tearController,
                                  _shakeController,
                                  _celebrationController,
                                ]),
                                builder: (context, child) {
                                  final progress = _tearController.value;
                                  final strength = progress <=
                                          widget.revealProgress
                                      ? math
                                          .pow(progress / widget.revealProgress,
                                              1.5)
                                          .toDouble()
                                      : (1 - progress) /
                                          (1 - widget.revealProgress);
                                  final elapsed = _celebrationController.value *
                                      _celebrationController
                                          .duration!.inMilliseconds;
                                  final holdMs = TicketTearDialog
                                      .revealHoldDuration.inMilliseconds
                                      .toDouble();
                                  final zoom = elapsed < 80
                                      ? Curves.easeOutCubic
                                          .transform(elapsed / 80)
                                      : elapsed < holdMs
                                          ? 1.0
                                          : 1 -
                                              Curves.easeOutCubic.transform(
                                                  ((elapsed - holdMs) / 260)
                                                      .clamp(0.0, 1.0));
                                  final shakeStrength =
                                      _holdingReveal ? 0.0 : strength;
                                  final phase =
                                      _shakeController.value * math.pi * 2;
                                  return Transform.translate(
                                    key: const ValueKey('tear-shake'),
                                    offset: Offset(
                                      math.sin(phase * 5) *
                                          TicketTearDialog.maxShakeOffset *
                                          shakeStrength,
                                      math.sin(phase * 7) *
                                          TicketTearDialog.maxShakeOffset *
                                          0.55 *
                                          shakeStrength,
                                    ),
                                    child: Transform.rotate(
                                      angle: math.sin(phase * 3) *
                                          0.025 *
                                          shakeStrength,
                                      child: Transform.scale(
                                        key:
                                            const ValueKey('tear-reveal-scale'),
                                        scale: 1 +
                                            (TicketTearDialog.revealScale - 1) *
                                                zoom,
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Positioned.fill(
                                              child: Image.asset(
                                                widget.openedImagePath,
                                                errorBuilder: missingGachaImage,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            // This image sets the stack's height from
                                            // its original aspect ratio, even when
                                            // fully clipped after opening.
                                            ClipPath(
                                              clipper: _RemainingTicketClipper(
                                                  progress),
                                              child: Image.asset(
                                                widget.unopenedImagePath,
                                                errorBuilder: missingGachaImage,
                                                width: constraints.maxWidth,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            if (progress > 0 && progress < 1)
                                              Positioned.fill(
                                                child: _PulledOpenedTicket(
                                                  imagePath:
                                                      widget.openedImagePath,
                                                  progress: progress,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ));
                      },
                    ),
                    const SizedBox(height: 20),
                    if (!_isOpened)
                      TextButton(
                        onPressed: _committing
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: Text(_committing ? '저장 중…' : '취소'),
                      ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      child: _isOpened
                          ? SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                style: FilledButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text(
                                  '결과 보기',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _TicketCelebrationPainter(_celebrationController,
                    glow: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketCelebrationPainter extends CustomPainter {
  _TicketCelebrationPainter(this.animation, {required this.glow})
      : super(repaint: animation);

  final Animation<double> animation;
  final bool glow;
  static const colors = [
    Color(0xffffd54f),
    Color(0xffff80ab),
    Color(0xff80deea),
    Color(0xffb388ff),
    Color(0xfffff1b8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    if (t <= 0 || t >= 1) return;
    final fade = ((1 - t) / 0.35).clamp(0.0, 1.0);
    final paint = Paint();
    if (glow) {
      final center = size.center(Offset.zero);
      final radius = size.longestSide * 0.65;
      final intensity = (t / 0.04).clamp(0.0, 1.0) * fade;
      final bounds = Rect.fromCircle(center: center, radius: radius);
      paint.shader = RadialGradient(colors: [
        Color.fromRGBO(255, 224, 126, 0.85 * intensity),
        Color.fromRGBO(255, 193, 7, 0.32 * intensity),
        const Color(0x00ffc107),
      ], stops: const [
        0,
        0.45,
        1
      ]).createShader(bounds);
      canvas.drawCircle(center, radius, paint);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(t * 0.28);
      paint.shader = RadialGradient(colors: [
        Color.fromRGBO(255, 241, 184, 0.5 * intensity),
        const Color(0x00ffe082),
      ]).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));
      for (var i = 0; i < 14; i++) {
        final angle = i * math.pi * 2 / 14;
        final path = Path()
          ..moveTo(0, 0)
          ..lineTo(math.cos(angle - 0.045) * radius,
              math.sin(angle - 0.045) * radius)
          ..lineTo(math.cos(angle + 0.045) * radius,
              math.sin(angle + 0.045) * radius)
          ..close();
        canvas.drawPath(path, paint);
      }
      canvas.restore();
      return;
    }
    // Fixed seed keeps each piece on a continuous trajectory across frames.
    final random = math.Random(42);
    for (var i = 0; i < 100; i++) {
      final fromLeft = i.isEven;
      final delay = random.nextDouble() * 0.10;
      final speedX = 0.18 + random.nextDouble() * 0.60;
      final speedY = 0.32 + random.nextDouble() * 0.35;
      final spin = random.nextDouble() * math.pi * 2;
      final width = 5 + random.nextDouble() * 5;
      final age = ((t - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (t <= delay) continue;
      final x = (fromLeft ? 0.03 : 0.97) * size.width +
          (fromLeft ? 1 : -1) * size.width * speedX * age +
          math.sin(age * 12 + spin) * 12;
      final y = size.height * (0.58 - speedY * age + 1.05 * age * age);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(spin + age * 10);
      canvas.scale(1, 0.35 + 0.65 * math.cos(age * 16 + spin).abs());
      paint.color = colors[i % colors.length].withAlpha((fade * 240).round());
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset.zero, width: width, height: width * 0.5),
              const Radius.circular(1)),
          paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _TicketCelebrationPainter oldDelegate) =>
      oldDelegate.animation != animation || oldDelegate.glow != glow;
}

class _RemainingTicketClipper extends CustomClipper<Path> {
  const _RemainingTicketClipper(this.progress);

  final double progress;

  @override
  Path getClip(Size size) {
    if (progress <= 0) return Path()..addRect(Offset.zero & size);
    if (progress >= 1) return Path();
    final x = size.width * progress;
    return Path()..addRect(Rect.fromLTRB(x, 0, size.width, size.height));
  }

  @override
  bool shouldReclip(covariant _RemainingTicketClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

class _PulledOpenedTicket extends StatelessWidget {
  const _PulledOpenedTicket({
    required this.imagePath,
    required this.progress,
  });

  final String imagePath;
  final double progress;

  @override
  Widget build(BuildContext context) {
    const scale = 0.8;
    return IgnorePointer(
      child: LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final tearX = width * progress;
        final sourceEdgeX = width * (1 - progress);
        final top = height * (1 - scale) / 2;
        final arcWidth = 6 + 4 * math.sin(progress * math.pi);
        final fadeIn = (progress / 0.08).clamp(0.0, 1.0);
        final fadeOut = ((1 - progress) / 0.18).clamp(0.0, 1.0);

        // The transformed image edge and curl share the same tearX anchor.
        return Opacity(
          opacity: fadeIn * fadeOut,
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Transform(
                  alignment: Alignment.topLeft,
                  transform: Matrix4.diagonal3Values(scale, scale, 1)
                    ..setTranslationRaw(tearX - sourceEdgeX * scale, top, 0),
                  child: ClipPath(
                    clipper: _PulledTicketClipper(progress),
                    child: Image.asset(imagePath,
                        errorBuilder: missingGachaImage, fit: BoxFit.contain),
                  ),
                ),
                Positioned(
                  left: tearX - arcWidth,
                  top: top,
                  width: arcWidth + 2,
                  height: height * scale,
                  child: const CustomPaint(painter: _TornPaperCurl()),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _PulledTicketClipper extends CustomClipper<Path> {
  const _PulledTicketClipper(this.progress);

  final double progress;

  @override
  Path getClip(Size size) {
    if (progress <= 0) return Path();
    if (progress >= 1) return Path()..addRect(Offset.zero & size);
    final x = size.width * (1 - progress);
    return Path()..addRect(Rect.fromLTRB(x, 0, size.width, size.height));
  }

  @override
  bool shouldReclip(covariant _PulledTicketClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

class _TornPaperCurl extends CustomPainter {
  const _TornPaperCurl();

  @override
  void paint(Canvas canvas, Size size) {
    final edgeX = size.width - 2;
    // A shallow open arc, attached to the pulled paper at both ends.
    final arc = Path()
      ..moveTo(edgeX, 2)
      ..cubicTo(
          0, size.height * 0.25, 0, size.height * 0.75, edgeX, size.height - 2);
    canvas.drawPath(
      arc.shift(const Offset(1, 0)),
      Paint()
        ..color = const Color(0x33000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawPath(
      arc,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xffcbd9a1), Color(0xfffffff4), Color(0xffdce6bd)],
          stops: [0, 0.55, 1],
        ).createShader(Offset.zero & size)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _TornPaperCurl oldDelegate) => false;
}
