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
  final Alignment labelAlignment;
  const DayHotspot({
    required this.dayId,
    required this.bounds,
    this.labelAlignment = Alignment.center,
  });
}

// The source PNGs are 1051 x 1496. Keep a 600-wide coordinate system
// with the same aspect ratio, including the transparent space in each layer.
const villageCanvas = Size(600, 600 * 1496 / 1051);
const villageBounds = Rect.fromLTWH(0, 0, 600, 600 * 1496 / 1051);

// Small lights use the same 600-wide coordinates as the image layers.
class VillageLight {
  final int dayId;
  final Offset position;
  final double radius;
  final double phase;
  const VillageLight(this.dayId, this.position,
      {this.radius = 1.2, this.phase = 0});
}

// Preview twinkle on the little tree inside the day 2 attic window.
const villageLights = <VillageLight>[
  VillageLight(2, Offset(119, 150), phase: 0),
  VillageLight(2, Offset(116, 154), phase: 0.2),
  VillageLight(2, Offset(121, 155), phase: 0.55),
  VillageLight(2, Offset(113, 160), phase: 0.75),
  VillageLight(2, Offset(122, 160), phase: 0.35),
];

List<AdventDay> villageDays(int year) => [
      AdventDay(
          dayId: 1,
          unlockAt: DateTime(year, 12, 1),
          gift: const AdventGift(
              '첫 번째 온기', '당신을 기다리던 빵집에 불이 켜졌어요.\n오늘의 선물은 따뜻한 응원 한 조각이에요.')),
      AdventDay(
          dayId: 2,
          unlockAt: DateTime(year, 12, 2),
          gift: const AdventGift(
              '창가의 작은 크리스마스', '다락집 창문에 따뜻한 불이 켜졌어요.\n작은 트리처럼 당신의 하루도 반짝이길!')),
      AdventDay(
          dayId: 12,
          unlockAt: DateTime(year, 12, 12),
          gift: const AdventGift(
              '함께 걷는 겨울', '손을 꼭 잡은 두 사람이 눈길을 걸어요.\n함께하는 발걸음마다 따뜻한 추억이 쌓이길!')),
    ];

const villageLayers = <SceneLayer>[
  SceneLayer(
      id: 'village',
      assetPath: 'assets/images/advent/Viliage_Day0.png',
      bounds: villageBounds,
      zIndex: 0,
      enterMotion: LayerMotion.none,
      exitMotion: LayerMotion.none),
  SceneLayer(
      id: 'day1_window',
      assetPath: 'assets/images/advent/Day1_Bakery Show Window.png',
      // Canvas sizes match, but the painted window is larger and lower in
      // Day1. Align it with Day0's dark window without modifying either PNG.
      bounds: Rect.fromLTWH(21, 93, 484, 599),
      zIndex: 1,
      dayId: 1,
      visibility: LayerVisibility.afterOpening,
      enterDuration: Duration(milliseconds: 1000)),
  SceneLayer(
      id: 'day2_attic_window',
      assetPath: 'assets/images/advent/Day02_Attic_Window.png',
      bounds: villageBounds,
      zIndex: 2,
      dayId: 2,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day12_walking_couple',
      assetPath: 'assets/images/advent/Day12_Walking_Couple.png',
      bounds: villageBounds,
      zIndex: 12,
      dayId: 12,
      visibility: LayerVisibility.afterOpening),
];

const villageHotspots = <DayHotspot>[
  // The bakery is the yellow building on the left, halfway down the village.
  DayHotspot(
      dayId: 1,
      bounds: Rect.fromLTWH(120, 305, 100, 100),
      labelAlignment: Alignment.centerLeft),
  // Upper-left attic window; keep the number beside the artwork.
  DayHotspot(
      dayId: 2,
      bounds: Rect.fromLTWH(65, 110, 110, 100),
      labelAlignment: Alignment.centerRight),
  // Left curved path; put the number beside the couple rather than over them.
  DayHotspot(
      dayId: 12,
      bounds: Rect.fromLTWH(60, 420, 120, 110),
      labelAlignment: Alignment.centerRight),
];
