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

// Backgrounds and full-canvas overlays are 1051 x 1496. Cropped Daily_Open
// assets retain their native size and are placed with VillageRect below.
const villageSourceScale = 600 / 1051;
const villageCanvas = Size(600, 600 * 1496 / 1051);
const villageBounds = Rect.fromLTWH(0, 0, 600, 600 * 1496 / 1051);
const villageDailyAssetRoot = 'assets/images/advent/Daily_Open/';

/// Positions in the original PNG's pixels, scaled to the 600-wide scene.
class VillageRect extends Rect {
  const VillageRect(double left, double top, double width, double height)
      : super.fromLTWH(left * villageSourceScale, top * villageSourceScale,
            width * villageSourceScale, height * villageSourceScale);
}

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

const _villageGifts = <AdventGift>[
  AdventGift('첫 번째 온기', '당신을 기다리던 빵집에 불이 켜졌어요.\n오늘의 선물은 따뜻한 응원 한 조각이에요.'),
  AdventGift('창가의 작은 크리스마스', '다락집 창문에 따뜻한 불이 켜졌어요.\n작은 트리처럼 당신의 하루도 반짝이길!'),
  AdventGift(
      '쇼윈도 앞의 설렘', '장난감 가게에 불이 켜지고, 아이와 보호자가 구경하러 왔어요.\n작은 설렘이 가득한 하루 보내세요.'),
  AdventGift('마음을 전하는 편지', '우체국 창문이 밝아지고 우체통에 편지가 도착했어요.\n당신에게도 다정한 소식이 찾아오길!'),
  AdventGift('시간을 밝히는 불빛', '시계탑의 작은 창문들이 환해졌어요.\n기다리는 시간도 따뜻한 기억이 되길 바라요.'),
  AdventGift(
      '빨간 리본의 선물', '빵집 앞에 선물이 놓이고 트리에 빨간 장식이 달렸어요.\n당신을 위한 작은 기쁨도 준비되어 있어요.'),
  AdventGift('따뜻한 차 한 잔', '찻집 창가에 포근한 불빛이 켜졌어요.\n오늘은 잠시 쉬어 가도 괜찮아요.'),
  AdventGift('마음을 잇는 리본', '트리 둘레 울타리에 가랜드와 리본이 둘러졌어요.\n서로를 향한 마음도 이렇게 이어지길!'),
  AdventGift(
      '당신을 반기는 문', '주황집 문에 리스가 걸리고 현관에 작은 트리가 놓였어요.\n언제나 반가운 마음으로 당신을 기다릴게요.'),
  AdventGift('마을로 향하는 발걸음', '겨울옷을 입은 두 주민이 광장으로 걸어와요.\n함께라서 더 즐거운 하루가 되길!'),
  AdventGift(
      '발코니의 크리스마스 양말', '다락집 발코니에 양말과 가랜드가 달렸어요.\n당신의 양말에도 행복이 가득 담기길 바라요.'),
  AdventGift(
      '함께 걷는 겨울', '손을 꼭 잡은 두 사람이 눈길을 걸어요.\n트리 아래에도 불빛이 켜지고, 따뜻한 추억이 쌓여요.'),
  AdventGift('차 한 잔과 수다',
      '찻집 앞에서 친구들이 이야기를 나누고, 지붕에도 가랜드가 걸렸어요.\n소소한 대화 속 행복을 만나보세요.'),
  AdventGift('문 앞에 도착한 마음', '우체국 앞에 소포와 선물 꾸러미가 쌓였어요.\n누군가의 마음이 당신에게도 닿기를!'),
  AdventGift('별을 품은 창문', '시계탑 아치 창문에 별빛이 켜지고 가랜드가 걸렸어요.\n당신의 밤도 환하게 빛나길 바라요.'),
  AdventGift(
      '나란히 쉬는 시간', '벤치에 앉은 두 사람이 크리스마스 마을을 바라봐요.\n말없이 함께하는 순간도 소중한 선물이에요.'),
  AdventGift('함께 나르는 선물',
      '다락집 앞에 선물을 든 주민들이 나타나고 트리 아래에도 선물이 놓였어요.\n나누는 기쁨이 더 크게 돌아오길!'),
  AdventGift('가족의 겨울 산책',
      '손을 잡은 가족이 광장에 모이고 트리 가운데에도 불빛이 켜졌어요.\n당신 곁에도 따뜻한 사람이 함께하길 바라요.'),
  AdventGift(
      '다시 만나는 동심', '장난감 가게에 별 가랜드, 목마와 꼬마 기차가 더해졌어요.\n어릴 적 설렘을 오늘도 잊지 마세요.'),
  AdventGift(
      '조심조심, 선물 배달', '아이가 선물 상자를 옮기고 트리 아래 선물도 늘어났어요.\n정성껏 준비한 마음을 받아 주세요.'),
  AdventGift(
      '빵집의 크리스마스 인사', '위층 창문에 제빵사가 나타나고 빵집에도 가랜드가 걸렸어요.\n따뜻한 인사로 하루를 시작해 보세요.'),
  AdventGift('오래 남을 한 장', '사진사가 가족의 행복한 순간을 담으러 왔어요.\n오늘의 미소도 오래도록 기억되길!'),
  AdventGift(
      '문 앞의 크리스마스 리스', '우체국 지붕에 가랜드가, 문에는 리스가 달렸어요.\n당신을 기다리는 마음도 한층 더 환해졌어요.'),
  AdventGift('크리스마스이브의 하늘',
      '산타와 루돌프가 하늘을 지나고 트리 위쪽에도 불빛이 켜졌어요.\n오늘 밤, 기분 좋은 꿈을 꾸길 바라요.'),
  AdventGift('메리 크리스마스',
      '트리 꼭대기의 별이 빛나며 마을의 크리스마스가 완성됐어요.\n함께 기다려 줘서 고마워요. 메리 크리스마스!'),
];

List<AdventDay> villageDays(int year) => List.generate(
      _villageGifts.length,
      (index) => AdventDay(
        dayId: index + 1,
        unlockAt: DateTime(year, 12, index + 1),
        gift: _villageGifts[index],
      ),
    );

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
      assetPath: '${villageDailyAssetRoot}Day01_Bakery.png',
      bounds: VillageRect(55, 572, 250, 154),
      zIndex: 10,
      dayId: 1,
      visibility: LayerVisibility.afterOpening,
      enterDuration: Duration(milliseconds: 1000)),
  SceneLayer(
      id: 'day2_attic_window',
      assetPath: '${villageDailyAssetRoot}day02_purple_house_windows.png',
      bounds: VillageRect(116, 200, 119, 115),
      zIndex: 20,
      dayId: 2,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day3_toyshop',
      assetPath:
          '${villageDailyAssetRoot}day03_toyshop_showcase, parent, windows.png',
      bounds: VillageRect(767, 469, 245, 271),
      zIndex: 30,
      dayId: 3,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day4_postoffice',
      assetPath: '${villageDailyAssetRoot}day04_postoffice_window_mailbox.png',
      bounds: VillageRect(99, 1082, 104, 125),
      zIndex: 40,
      dayId: 4,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day5_clocktower_windows',
      assetPath: '${villageDailyAssetRoot}day05_clocktower_small_windows.png',
      bounds: VillageRect(905, 182, 52, 175),
      zIndex: 50,
      dayId: 5,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day6_bakery_boxes',
      assetPath: '${villageDailyAssetRoot}day06_bakery_entrance_boxes.png',
      bounds: VillageRect(173, 656, 82, 53),
      zIndex: 60,
      dayId: 6,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day6_tree_ornaments',
      assetPath: '${villageDailyAssetRoot}day06_tree_red_ornaments.png',
      bounds: villageBounds,
      zIndex: 61,
      dayId: 6,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day7_teashop_windows',
      assetPath: '${villageDailyAssetRoot}day07_teashop_main_windows.png',
      bounds: VillageRect(716, 1085, 274, 100),
      zIndex: 70,
      dayId: 7,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day8_tree_fence',
      assetPath: '${villageDailyAssetRoot}day08_tree_fence_garland_ribbons.png',
      bounds: VillageRect(305, 846, 427, 117),
      zIndex: 80,
      dayId: 8,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day9_orange_house',
      assetPath:
          '${villageDailyAssetRoot}day09_orange_house_entrance_decor.png',
      bounds: villageBounds,
      zIndex: 90,
      dayId: 9,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day10_residents',
      assetPath: '${villageDailyAssetRoot}day10_upper_path_residents.png',
      bounds: VillageRect(609, 325, 103, 123),
      zIndex: 100,
      dayId: 10,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day11_balcony',
      assetPath: '${villageDailyAssetRoot}day11_purple_house_balcony_decor.png',
      bounds: villageBounds,
      zIndex: 110,
      dayId: 11,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day12_walking_couple',
      assetPath: '${villageDailyAssetRoot}Day12_Walking_Couple.png',
      bounds: villageBounds,
      zIndex: 120,
      dayId: 12,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day12_tree_bottom_lights',
      assetPath: '${villageDailyAssetRoot}day12_tree_bottom_lights.png',
      bounds: VillageRect(338, 726, 370, 151),
      zIndex: 121,
      dayId: 12,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day13_friends',
      assetPath: '${villageDailyAssetRoot}day13_teashop_chatting_friends.png',
      bounds: VillageRect(718, 1161, 152, 161),
      zIndex: 130,
      dayId: 13,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day13_teashop_garland',
      assetPath: '${villageDailyAssetRoot}day13_teashop_roof_garland.png',
      bounds: VillageRect(784, 1053, 208, 39),
      zIndex: 131,
      dayId: 13,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day14_parcels',
      assetPath: '${villageDailyAssetRoot}day14_postoffice_parcels.png',
      bounds: VillageRect(141, 1174, 91, 77),
      zIndex: 140,
      dayId: 14,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day15_clocktower_arch',
      assetPath: '${villageDailyAssetRoot}day15_clocktower_arch_window.png',
      bounds: VillageRect(814, 228, 98, 102),
      zIndex: 150,
      dayId: 15,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day16_bench_couple',
      assetPath: '${villageDailyAssetRoot}day16_plaza_bench_couple.png',
      bounds: villageBounds,
      zIndex: 160,
      dayId: 16,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day17_gift_walkers',
      assetPath: '${villageDailyAssetRoot}day17_purple_house_gift_walkers.png',
      bounds: VillageRect(219, 336, 94, 114),
      zIndex: 170,
      dayId: 17,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day17_tree_gifts',
      assetPath: '${villageDailyAssetRoot}day17_tree_gifts_first.png',
      bounds: VillageRect(396, 830, 127, 74),
      zIndex: 171,
      dayId: 17,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day18_family',
      assetPath: '${villageDailyAssetRoot}day18_plaza_family.png',
      bounds: VillageRect(381, 938, 232, 188),
      zIndex: 180,
      dayId: 18,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day18_tree_middle_lights',
      assetPath: '${villageDailyAssetRoot}day18_tree_middle_lights.png',
      bounds: VillageRect(343, 623, 320, 189),
      zIndex: 181,
      dayId: 18,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day19_toyshop_decor',
      assetPath: '${villageDailyAssetRoot}day19_toyshop_horse_garland.png',
      bounds: VillageRect(787, 499, 243, 208),
      zIndex: 190,
      dayId: 19,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day20_gift_kid',
      assetPath: '${villageDailyAssetRoot}day20_tree_gift_kid.png',
      bounds: VillageRect(228, 858, 129, 114),
      zIndex: 200,
      dayId: 20,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day20_tree_gifts',
      assetPath: '${villageDailyAssetRoot}day20_tree_gifts_second.png',
      bounds: VillageRect(532, 824, 110, 83),
      zIndex: 201,
      dayId: 20,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day21_bakery_upper',
      assetPath:
          '${villageDailyAssetRoot}day21_bakery_upper_window_garland.png',
      bounds: VillageRect(27, 477, 261, 93),
      zIndex: 210,
      dayId: 21,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day22_photographer',
      assetPath: '${villageDailyAssetRoot}day22_plaza_photographer.png',
      bounds: villageBounds,
      zIndex: 220,
      dayId: 22,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day23_postoffice_decor',
      assetPath: '${villageDailyAssetRoot}day23_postoffice_door_wreath.png',
      bounds: VillageRect(109, 1019, 185, 127),
      zIndex: 230,
      dayId: 23,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day24_santa',
      assetPath: '${villageDailyAssetRoot}day24_sky_santa_rudolph.png',
      bounds: VillageRect(431, 35, 326, 93),
      zIndex: 240,
      dayId: 24,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day24_tree_upper_lights',
      assetPath: '${villageDailyAssetRoot}day24_tree_upper_lights.png',
      bounds: VillageRect(417, 499, 225, 159),
      zIndex: 241,
      dayId: 24,
      visibility: LayerVisibility.afterOpening),
  SceneLayer(
      id: 'day25_tree_star',
      assetPath: '${villageDailyAssetRoot}day25_tree_top_star_and_glow.png',
      bounds: VillageRect(426, 374, 181, 136),
      zIndex: 250,
      dayId: 25,
      visibility: LayerVisibility.afterOpening),
];

// One target per date, even when that date reveals multiple image layers.
// Tree + other object days use the other object: 6 boxes, 12 couple,
// 17 walkers, 18 family, 20 child, 24 Santa. Only 8 (fence) and 25 (star)
// need a target on the tree itself. Targets do not overlap each other.
const villageHotspots = <DayHotspot>[
  DayHotspot(dayId: 1, bounds: VillageRect(310, 567, 84, 90)),
  DayHotspot(dayId: 2, bounds: VillageRect(223, 214, 84, 90)),
  DayHotspot(dayId: 3, bounds: VillageRect(965, 565, 84, 90)),
  DayHotspot(dayId: 4, bounds: VillageRect(26, 1067, 84, 90)),
  DayHotspot(dayId: 5, bounds: VillageRect(945, 239, 84, 90)),
  DayHotspot(dayId: 6, bounds: VillageRect(172, 673, 84, 90)),
  DayHotspot(dayId: 7, bounds: VillageRect(965, 1096, 84, 90)),
  DayHotspot(dayId: 8, bounds: VillageRect(498, 885, 84, 90)),
  DayHotspot(dayId: 9, bounds: VillageRect(578, 271, 84, 90)),
  DayHotspot(dayId: 10, bounds: VillageRect(698, 366, 84, 90)),
  DayHotspot(dayId: 11, bounds: VillageRect(236, 313, 84, 90)),
  DayHotspot(dayId: 12, bounds: VillageRect(53, 809, 84, 90)),
  DayHotspot(dayId: 13, bounds: VillageRect(846, 1265, 84, 90)),
  DayHotspot(dayId: 14, bounds: VillageRect(162, 1227, 84, 90)),
  DayHotspot(dayId: 15, bounds: VillageRect(771, 262, 84, 90)),
  DayHotspot(dayId: 16, bounds: VillageRect(932, 874, 84, 90)),
  DayHotspot(dayId: 17, bounds: VillageRect(135, 380, 84, 90)),
  DayHotspot(dayId: 18, bounds: VillageRect(454, 1126, 84, 90)),
  DayHotspot(dayId: 19, bounds: VillageRect(965, 688, 84, 90)),
  DayHotspot(dayId: 20, bounds: VillageRect(292, 941, 84, 90)),
  DayHotspot(dayId: 21, bounds: VillageRect(258, 448, 84, 90)),
  DayHotspot(dayId: 22, bounds: VillageRect(640, 1096, 84, 90)),
  DayHotspot(dayId: 23, bounds: VillageRect(297, 1089, 84, 90)),
  DayHotspot(dayId: 24, bounds: VillageRect(745, 62, 84, 90)),
  DayHotspot(dayId: 25, bounds: VillageRect(582, 435, 84, 90)),
];
