import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../advent/bakery_config.dart';
import '../providers/advent_provider.dart';

class BakeryScene extends StatelessWidget {
  final AdventProvider advent;
  final ValueChanged<int> onDayTap;
  const BakeryScene({super.key, required this.advent, required this.onDayTap});

  @override
  Widget build(BuildContext context) {
    final layers = [...bakeryLayers]
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));
    return RepaintBoundary(
      key: const ValueKey('bakery-scene'),
      child: LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height:
              constraints.maxWidth * bakeryCanvas.height / bakeryCanvas.width,
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox.fromSize(
              size: bakeryCanvas,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(children: [
                  const Positioned.fill(
                      child: CustomPaint(painter: _WinterSky())),
                  for (final layer in layers)
                    Positioned.fromRect(
                      rect: layer.bounds,
                      child: SceneImageLayer(
                        key: ValueKey('${layer.id}-${advent.resetVersion}'),
                        layer: layer,
                        visible: layer.isVisible(advent.openedDays),
                      ),
                    ),
                  for (final hotspot in bakeryHotspots)
                    Positioned.fromRect(
                      rect: hotspot.bounds,
                      child: _DayTarget(
                        hotspot: hotspot,
                        opened: advent.openedDays.contains(hotspot.dayId),
                        unlocked: advent.canOpen(hotspot.dayId),
                        showBorder: advent.showHotspots,
                        onTap: advent.isSaving
                            ? null
                            : () => onDayTap(hotspot.dayId),
                      ),
                    ),
                ]),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// Initial/restored visibility is applied directly. Only a visibility CHANGE
// on an existing layer animates; rebuilding or reopening a gift does not.
class SceneImageLayer extends StatefulWidget {
  final SceneLayer layer;
  final bool visible;
  const SceneImageLayer(
      {super.key, required this.layer, required this.visible});

  @override
  State<SceneImageLayer> createState() => _SceneImageLayerState();
}

class _SceneImageLayerState extends State<SceneImageLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  LayerMotion _motion = LayerMotion.none;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, value: widget.visible ? 1 : 0);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(covariant SceneImageLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visible == widget.visible) return;
    final config = widget.layer;
    _motion = widget.visible ? config.enterMotion : config.exitMotion;
    final duration =
        widget.visible ? config.enterDuration : config.exitDuration;
    if (_motion == LayerMotion.none || duration == Duration.zero) {
      _controller.value = widget.visible ? 1 : 0;
    } else {
      _controller.animateTo(widget.visible ? 1 : 0, duration: duration);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: FadeTransition(
          key: ValueKey('opacity-${widget.layer.id}'),
          opacity: _opacity,
          child: ScaleTransition(
            scale: _motion == LayerMotion.fadeScale
                ? Tween<double>(begin: 0.92, end: 1).animate(_opacity)
                : const AlwaysStoppedAnimation(1),
            child: Image.asset(widget.layer.assetPath,
                key: ValueKey('asset-${widget.layer.id}'), fit: BoxFit.fill),
          ),
        ),
      ),
    );
  }
}

class _DayTarget extends StatelessWidget {
  final DayHotspot hotspot;
  final bool opened;
  final bool unlocked;
  final bool showBorder;
  final VoidCallback? onTap;
  const _DayTarget(
      {required this.hotspot,
      required this.opened,
      required this.unlocked,
      required this.showBorder,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = opened
        ? '선물 다시 보기'
        : unlocked
            ? '선물 열기'
            : '아직 잠겨 있어요';
    return Semantics(
      label: '${hotspot.dayId}일, $status',
      button: true,
      child: Tooltip(
        message: '${hotspot.dayId}일 · $status',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: ValueKey('day-${hotspot.dayId}'),
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: showBorder
                    ? Border.all(color: Colors.cyanAccent, width: 3)
                    : null,
              ),
              alignment: Alignment.center,
              child: ExcludeSemantics(
                child: SizedBox(
                  width: 60,
                  height: 72,
                  child: Column(children: [
                    Container(
                      width: 54,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: opened ? adventGold : adventRed,
                          border: Border.all(color: adventCream, width: 2),
                          borderRadius: BorderRadius.circular(16)),
                      child: Text('${hotspot.dayId}',
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: opened ? adventGreen : adventCream)),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                        opened
                            ? Icons.check_circle
                            : unlocked
                                ? Icons.auto_awesome
                                : Icons.lock,
                        color: adventCream,
                        size: 18),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Static atmosphere is independent of day state and image layers.
class _WinterSky extends CustomPainter {
  const _WinterSky();
  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(
        bounds,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF203C4D), Color(0xFF658589)],
          ).createShader(bounds));
    canvas.drawCircle(const Offset(475, 88), 32, Paint()..color = adventCream);
    final snow = Paint()..color = Colors.white.withValues(alpha: 0.65);
    final random = math.Random(24);
    for (var i = 0; i < 65; i++) {
      canvas.drawCircle(
          Offset(random.nextDouble() * size.width,
              random.nextDouble() * size.height),
          1.5 + random.nextDouble() * 2,
          snow);
    }
    canvas.drawOval(const Rect.fromLTWH(-100, 610, 800, 250),
        Paint()..color = const Color(0xFFE4ECE9));
    canvas.drawOval(const Rect.fromLTWH(80, 615, 450, 45),
        Paint()..color = const Color(0xFFC4D7D5));
  }

  @override
  bool shouldRepaint(covariant _WinterSky oldDelegate) => false;
}
