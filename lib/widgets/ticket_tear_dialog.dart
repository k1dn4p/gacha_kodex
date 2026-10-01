import 'dart:math' as math;

import 'package:flutter/material.dart';

class TicketTearDialog extends StatefulWidget {
  const TicketTearDialog({
    super.key,
    required this.unopenedImagePath,
    required this.openedImagePath,
    this.onOpened,
  });

  final String unopenedImagePath;
  final String openedImagePath;
  final VoidCallback? onOpened;

  static Future<bool> show(
    BuildContext context, {
    required String unopenedImagePath,
    required String openedImagePath,
    VoidCallback? onOpened,
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _tearController;
  bool _isOpened = false;

  @override
  void initState() {
    super.initState();
    _tearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed &&
            _tearController.value == 1 &&
            !_isOpened &&
            mounted) {
          setState(() => _isOpened = true);
          widget.onOpened?.call();
        }
      });
  }

  @override
  void dispose() {
    _tearController.dispose();
    super.dispose();
  }

  void _updateTear(DragUpdateDetails details, double width) {
    if (_isOpened || width <= 0) return;
    _tearController.value =
        (_tearController.value + details.delta.dx / width).clamp(0.0, 1.0);
  }

  void _finishTear(DragEndDetails details) {
    if (_isOpened) return;

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
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width:
                MediaQuery.sizeOf(context).width.clamp(280.0, 620.0).toDouble(),
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
                AspectRatio(
                  aspectRatio: 2.5,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onHorizontalDragUpdate: (details) =>
                            _updateTear(details, constraints.maxWidth),
                        onHorizontalDragEnd: _finishTear,
                        child: AnimatedBuilder(
                          animation: _tearController,
                          builder: (context, child) {
                            final progress = _tearController.value;
                            return Stack(
                              fit: StackFit.expand,
                              clipBehavior: Clip.none,
                              children: [
                                Image.asset(
                                  widget.openedImagePath,
                                  fit: BoxFit.fill,
                                ),
                                ClipPath(
                                  clipper: _RemainingTicketClipper(progress),
                                  child: Image.asset(
                                    widget.unopenedImagePath,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                if (progress > 0 && progress < 1)
                                  _PulledOpenedTicket(
                                    imagePath: widget.openedImagePath,
                                    progress: progress,
                                  ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: _isOpened
                      ? SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
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
    );
  }
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
                    child: Image.asset(imagePath, fit: BoxFit.fill),
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
