import 'package:flutter/material.dart';

const adventCream = Color(0xFFFAF5EB);
const adventGreen = Color(0xFF254F43);
const adventRed = Color(0xFF853E48);
const adventGold = Color(0xFFE7CB8E);

class AdventGift {
  final String title;
  final String message;
  const AdventGift(this.title, this.message);
}

class AdventDay {
  final int dayId;
  final DateTime unlockAt;
  final AdventGift gift;
  AdventDay({required this.dayId, required this.unlockAt, required this.gift})
      : assert(dayId >= 1 && dayId <= 25);
}

class AdventDayState {
  final AdventDay configuration;
  final bool isOpened;
  const AdventDayState(this.configuration, {required this.isOpened});
}

enum LayerVisibility { always, beforeOpening, afterOpening }

enum LayerMotion { none, fade, fadeScale }

class SceneLayer {
  final String id;
  final String assetPath;
  final Rect bounds;
  final int zIndex;
  final int? dayId;
  final LayerVisibility visibility;
  final LayerMotion enterMotion;
  final LayerMotion exitMotion;
  final Duration enterDuration;
  final Duration exitDuration;

  const SceneLayer({
    required this.id,
    required this.assetPath,
    required this.bounds,
    required this.zIndex,
    this.dayId,
    this.visibility = LayerVisibility.always,
    this.enterMotion = LayerMotion.fade,
    this.exitMotion = LayerMotion.fade,
    this.enterDuration = const Duration(milliseconds: 650),
    this.exitDuration = const Duration(milliseconds: 450),
  }) : assert(visibility == LayerVisibility.always || dayId != null);

  bool isVisible(Set<int> openedDays) {
    switch (visibility) {
      case LayerVisibility.always:
        return true;
      case LayerVisibility.beforeOpening:
        return !openedDays.contains(dayId);
      case LayerVisibility.afterOpening:
        return openedDays.contains(dayId);
    }
  }
}

class DayHotspot {
  final int dayId;
  final Rect bounds;
  const DayHotspot({required this.dayId, required this.bounds});
}

// All assets and hotspots share this coordinate system. No per-image cropping.
const bakeryCanvas = Size(600, 760);
const bakeryDoorBounds = Rect.fromLTWH(350, 350, 130, 230);

List<AdventDay> bakeryDays(int year) => [
      AdventDay(
          dayId: 1,
          unlockAt: DateTime(year, 12, 1),
          gift: const AdventGift(
              '첫 번째 온기', '당신을 기다리던 빵집에 불이 켜졌어요.\n오늘의 선물은 따뜻한 응원 한 조각이에요.')),
      AdventDay(
          dayId: 2,
          unlockAt: DateTime(year, 12, 2),
          gift: const AdventGift(
              '갓 구운 행복', '문을 열자 고소한 빵 냄새가 퍼져요.\n오늘은 좋아하는 빵으로 작은 휴식을 즐겨보세요.')),
      AdventDay(
          dayId: 3,
          unlockAt: DateTime(year, 12, 3),
          gift: const AdventGift(
              '작은 크리스마스', '초록 리스가 빵집을 장식했어요.\n당신의 하루에도 반짝이는 기쁨이 찾아오길!')),
    ];

const bakeryLayers = <SceneLayer>[
  SceneLayer(
      id: 'exterior',
      assetPath: 'assets/images/advent/exterior.png',
      bounds: Rect.fromLTWH(30, 140, 540, 520),
      zIndex: 0,
      enterMotion: LayerMotion.none,
      exitMotion: LayerMotion.none),
  SceneLayer(
      id: 'window_light',
      assetPath: 'assets/images/advent/window_light.png',
      bounds: Rect.fromLTWH(100, 360, 175, 165),
      zIndex: 1,
      dayId: 1,
      visibility: LayerVisibility.afterOpening,
      enterDuration: Duration(milliseconds: 1000)),
  SceneLayer(
      id: 'open_door',
      assetPath: 'assets/images/advent/open_door.png',
      bounds: bakeryDoorBounds,
      zIndex: 2,
      dayId: 2,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'closed_door',
      assetPath: 'assets/images/advent/closed_door.png',
      bounds: bakeryDoorBounds,
      zIndex: 3,
      dayId: 2,
      visibility: LayerVisibility.beforeOpening),
  SceneLayer(
      id: 'bread',
      assetPath: 'assets/images/advent/bread.png',
      bounds: Rect.fromLTWH(380, 448, 92, 110),
      zIndex: 4,
      dayId: 2,
      visibility: LayerVisibility.afterOpening,
      enterMotion: LayerMotion.fadeScale),
  SceneLayer(
      id: 'wreath',
      assetPath: 'assets/images/advent/wreath.png',
      bounds: Rect.fromLTWH(445, 258, 90, 90),
      zIndex: 5,
      dayId: 3,
      visibility: LayerVisibility.afterOpening,
      enterMotion: LayerMotion.fadeScale),
];

const bakeryHotspots = <DayHotspot>[
  DayHotspot(dayId: 1, bounds: Rect.fromLTWH(85, 345, 205, 195)),
  DayHotspot(dayId: 2, bounds: Rect.fromLTWH(335, 340, 160, 250)),
  DayHotspot(dayId: 3, bounds: Rect.fromLTWH(435, 245, 110, 110)),
];
