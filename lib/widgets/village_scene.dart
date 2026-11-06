import 'package:flutter/material.dart';
import '../advent/village_config.dart';
import '../providers/advent_provider.dart';
import 'village_lights.dart';

class VillageScene extends StatelessWidget {
  final AdventProvider advent;
  final ValueChanged<int> onDayTap;
  const VillageScene({super.key, required this.advent, required this.onDayTap});

  @override
  Widget build(BuildContext context) {
    final layers = [...villageLayers]
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));
    return RepaintBoundary(
      key: const ValueKey('village-scene'),
      child: LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height:
              constraints.maxWidth * villageCanvas.height / villageCanvas.width,
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox.fromSize(
              size: villageCanvas,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(children: [
                  for (final layer in layers)
                    Positioned.fromRect(
                      rect: layer.bounds,
                      child: SceneImageLayer(
                        key: ValueKey('${layer.id}-${advent.resetVersion}'),
                        layer: layer,
                        visible: layer.isVisible(advent.openedDays),
                      ),
                    ),
                  Positioned.fill(
                    child: VillageLights(
                      lights: [
                        for (final light in villageLights)
                          if (advent.openedDays.contains(light.dayId)) light,
                      ],
                    ),
                  ),
                  for (final hotspot in villageHotspots)
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
              alignment: hotspot.labelAlignment,
              child: ExcludeSemantics(
                child: SizedBox(
                  width: 36,
                  height: 48,
                  child: Column(children: [
                    Container(
                      width: 34,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: (opened ? adventGold : adventRed)
                              .withValues(alpha: 0.55),
                          border: Border.all(
                              color: adventCream.withValues(alpha: 0.65),
                              width: 1),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text('${hotspot.dayId}',
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: opened ? adventGreen : adventCream)),
                    ),
                    const SizedBox(height: 2),
                    Icon(
                        opened
                            ? Icons.check_circle
                            : unlocked
                                ? Icons.auto_awesome
                                : Icons.lock,
                        color: adventCream.withValues(alpha: 0.8),
                        size: 12),
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
