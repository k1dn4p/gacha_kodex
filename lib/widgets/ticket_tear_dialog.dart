import 'dart:math' as math;

import 'package:flutter/material.dart';

class TicketTearDialog extends StatefulWidget {
  const TicketTearDialog({
    super.key,
    required this.unopenedImagePath,
    required this.openedImagePath,
  });

  final String unopenedImagePath;
  final String openedImagePath;

  static Future<bool> show(
    BuildContext context, {
    required String unopenedImagePath,
    required String openedImagePath,
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
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _isOpened = true);
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
                    _isOpened
                        ? '당첨 결과를 확인해 볼까요?'
                        : '티켓을 오른쪽으로 밀어 뜯어주세요',
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
                                _PulledOpenedTicket(
                                  imagePath: widget.openedImagePath,
                                  progress: progress,
                                  travelDistance:
                                      constraints.maxWidth * 0.8,
                                ),
                                if (progress < 0.99)
                                  Positioned(
                                    left: constraints.maxWidth * progress - 14,
                                    top: 0,
                                    bottom: 0,
                                    child: IgnorePointer(
                                      child: _TornPaperCurl(
                                        progress: progress,
                                      ),
                                    ),
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
    final x = size.width * progress;
    const tooth = 5.0;
    final path = Path()..moveTo(x, 0);

    for (double y = 0; y < size.height; y += tooth) {
      path.lineTo(x + ((y ~/ tooth).isEven ? 2.5 : -2.5), y);
    }

    return path
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();
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
    required this.travelDistance,
  });

  final String imagePath;
  final double progress;
  final double travelDistance;

  @override
  Widget build(BuildContext context) {
    final lift = math.sin(progress * math.pi).abs();
    const scale = 0.8;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0015)
        ..translate(
          progress * travelDistance,
          -lift * 18,
          lift * 22,
        )
        ..rotateX(lift * 0.08)
        ..rotateZ(progress * 0.025)
        ..scale(scale),
      child: ClipPath(
        clipper: _PulledTicketClipper(progress),
        child: Image.asset(
          imagePath,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

class _PulledTicketClipper extends CustomClipper<Path> {
  const _PulledTicketClipper(this.progress);

  final double progress;

  @override
  Path getClip(Size size) {
    final x = size.width * (1 - progress);
    const tooth = 5.0;
    final path = Path()..moveTo(x, 0);

    for (double y = 0; y < size.height; y += tooth) {
      path.lineTo(x + ((y ~/ tooth).isEven ? 2.5 : -2.5), y);
    }

    return path
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant _PulledTicketClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

class _TornPaperCurl extends StatelessWidget {
  const _TornPaperCurl({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final curl = math.sin(progress * math.pi).abs();
    final angle = 0.15 + (curl * 0.05);

    return Transform(
      alignment: Alignment.centerRight,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0025)
        ..rotateY(-angle),
      child: Container(
        width: 30,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.20 + curl * 0.12),
              const Color(0xffe3edc5),
              Colors.white.withOpacity(0.9),
              const Color(0xffcbd9a1),
            ],
            stops: const [0, 0.24, 0.62, 1],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18 + curl * 0.20),
              blurRadius: 5 + curl * 10,
              spreadRadius: curl * 2,
              offset: Offset(-3 - curl * 6, 1),
            ),
          ],
        ),
      ),
    );
  }
}
