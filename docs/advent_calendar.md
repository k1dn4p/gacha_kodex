# 크리스마스 마을: 1~25일

2026-11-14 기준. `assets/images/advent/Daily_Open/`의 32개 PNG를 25일에 모두 연결했다. 이전 1일·2일·12일 이미지도 이 폴더의 파일로 교체했다. 과거 제작 계획보다 이 문서와 실제 `village_config.dart`를 우선한다.

## 실행

```sh
flutter pub get
flutter run -d chrome
```

설정에서 **크리스마스 어드벤트 모드**를 켜고 **Calendar** 탭으로 이동한다. `Daily_Open/` 폴더를 pubspec에 새로 등록했으므로 이전 앱은 완전히 종료하고 다시 실행한다.

## 날짜와 이미지

파일명은 `Daily_Open/` 기준이며 대소문자와 공백을 그대로 유지한다. 같은 날짜의 모든 이미지는 한 번의 개봉으로 함께 표시되고, 숫자 박스·저장 기록·선물 팝업·획득 티켓은 날짜당 하나다.

| 날짜 | 이미지 파일 | 숫자 박스 위치 |
| --- | --- | --- |
| 1 | `Day01_Bakery.png` | 빵집 쇼윈도 옆 |
| 2 | `day02_purple_house_windows.png` | 보라색 집 창문 옆 |
| 3 | `day03_toyshop_showcase, parent, windows.png` | 장난감 가게 쇼윈도 옆 |
| 4 | `day04_postoffice_window_mailbox.png` | 우체국 창문 옆 |
| 5 | `day05_clocktower_small_windows.png` | 시계탑 오른쪽 작은 창문 옆 |
| 6 | `day06_bakery_entrance_boxes.png`, `day06_tree_red_ornaments.png` | 빵집 선물 상자 아래 |
| 7 | `day07_teashop_main_windows.png` | 찻집 창문 옆 |
| 8 | `day08_tree_fence_garland_ribbons.png` | 트리 앞 울타리 리본 |
| 9 | `day09_orange_house_entrance_decor.png` | 주황색 집 현관 옆 |
| 10 | `day10_upper_path_residents.png` | 위쪽 길 주민 옆 |
| 11 | `day11_purple_house_balcony_decor.png` | 보라색 집 발코니 옆 |
| 12 | `Day12_Walking_Couple.png`, `day12_tree_bottom_lights.png` | 왼쪽 길의 연인 옆 |
| 13 | `day13_teashop_chatting_friends.png`, `day13_teashop_roof_garland.png` | 찻집 앞 친구들 옆 |
| 14 | `day14_postoffice_parcels.png` | 우체국 소포 아래 |
| 15 | `day15_clocktower_arch_window.png` | 시계탑 아치 창문 옆 |
| 16 | `day16_plaza_bench_couple.png` | 벤치의 연인 옆 |
| 17 | `day17_purple_house_gift_walkers.png`, `day17_tree_gifts_first.png` | 보라색 집 앞 선물을 든 주민 옆 |
| 18 | `day18_plaza_family.png`, `day18_tree_middle_lights.png` | 가족 아래 |
| 19 | `day19_toyshop_horse_garland.png` | 장난감 가게의 목마 옆 |
| 20 | `day20_tree_gift_kid.png`, `day20_tree_gifts_second.png` | 선물을 나르는 아이 옆 |
| 21 | `day21_bakery_upper_window_garland.png` | 빵집 위층 창문 옆 |
| 22 | `day22_plaza_photographer.png` | 사진사 아래 |
| 23 | `day23_postoffice_door_wreath.png` | 우체국 리스 옆 |
| 24 | `day24_sky_santa_rudolph.png`, `day24_tree_upper_lights.png` | 하늘의 산타 옆 |
| 25 | `day25_tree_top_star_and_glow.png` | 트리 꼭대기 별 옆 |

트리와 다른 오브젝트가 함께 등장하는 날은 트리 밖의 오브젝트에 숫자를 둔다. 트리 단독인 8일(울타리)과 25일(별)만 트리에 숫자를 둔다. 25개 터치 영역은 서로 겹치지 않는다.

## 이미지 배치와 조정

- 기본 배경은 `Viliage_Day0.png`, 크기는 **1051 × 1496**이다. `Viliage_Day25.png`는 위치 확인용 참고 이미지이며 런타임 장면을 완성본 한 장으로 교체하지 않는다.
- `villageCanvas`는 가로 600으로 원본 비율을 유지한다. 모든 이미지와 숫자가 같은 배율로 확대·축소된다.
- `VillageRect(left, top, width, height)`에는 **원본 배경의 픽셀 좌표**를 입력한다. 생성자가 내부의 600 기준 좌표로 변환한다.
- 잘라낸 PNG는 본래 너비·높이를 유지한 `VillageRect`에 배치한다. 예: 빵집은 `VillageRect(55, 572, 250, 154)`이다.
- 전체 캔버스 PNG(6일 장식, 9일 현관, 11일 발코니, 12일 연인, 16일 벤치 연인, 22일 사진사)는 투명 여백을 포함하여 `villageBounds`에 배치한다.
- `villageLayers`: 이미지 위치, 파일 경로, 날짜, 앞뒤 순서와 전환 효과.
- `villageHotspots`: 날짜마다 하나인 숫자 박스·클릭 영역. 실제 렌더를 확인하여 1·6·9·22일 박스를 인물이나 다른 오브젝트를 덜 가리도록 조정했다.
- 원본 PNG는 수정하지 않았다. 참고 완성본에는 Daily_Open 파일에 포함되지 않은 주황집 창문 조명·시계탑 종 등도 있으므로 합성 장면과 세부 내용은 다를 수 있다.
- `VillageScene.showDayLabels`는 기본 true다. 배치 검증용 렌더에서는 false로 두어 숫자 없는 실제 합성 장면을 추출할 수 있다.

## 개봉, 저장, 티켓

올해 12월 1~25일의 기기 현지 시각 00:00에 각 날짜가 열린다. 이전 날짜부터 차례로 개봉할 필요는 없다.

처음 개봉하면 해당 날짜의 레이어들이 함께 나타나고 티켓 1장을 받는다. 재열람과 페이지 방문에는 티켓을 추가 지급하지 않는다. 저장 성공 후에만 장면과 잔액을 갱신한다. 복원과 재열람에서 등장 애니메이션을 반복하지 않는다.

개봉 날짜와 뽑기 기록은 연도별 `advent_progress_v2_<연도>` JSON으로 저장한다. 기존 `advent_opened_days_v1_<연도>`도 처음 읽을 때 복원하며, 일반 가챠 기록과는 분리한다. 기존 1·2·12일 개봉 기록도 새 이미지에 그대로 적용된다.

상단에 `ticket.png`와 티켓 잔액을 표시하고, 캘린더에서 새 티켓 획득 시 반짝임 효과를 재생한다. 가챠에서 잔액 0이면 부족 안내가 표시되며, 끝까지 뜯어 저장에 성공했을 때 1장 차감한다. 취소와 짧은 드래그에는 차감하지 않는다.

## 개발용 확인

디버그 패널은 11/30과 12/1~25 날짜 선택, 직접 시각 선택, 실제 시각 복귀, 날짜 잠금 무시, 터치 영역 테두리 표시, 개봉 상태 초기화를 제공한다. 개발 옵션은 세션에만 유지되고 릴리스에서는 표시하지 않는다. 초기화하면 어드벤트 티켓과 뽑기 기록도 초기화된다.

```sh
flutter test
flutter analyze
```

Windows에서 실제 장면을 PNG로 생성:

```sh
flutter test test/village_scene_test.dart --dart-define=VILLAGE_PREVIEW=true
```

출력은 `build/village_preview/`에 저장한다. 이 옵션에서는 Windows 맑은 고딕 폰트를 사용한다.

- `closed.png`: 초기 상태와 25개 날짜
- `opened.png`, `day02_opened.png`, `day12_opened.png`: 일부 날짜 누적
- `all-open-with-dates.png`: 25일 전체 개봉과 날짜 박스
- `all-open-artwork.png`: 날짜 없는 실제 Flutter 합성 장면

검증 범위는 32개 파일의 누락·중복·날짜 연결·비율, 25개 터치 영역의 겹침, 모든 날짜의 자정 잠금 경계, 티켓의 1회 지급·저장·복원·차감, 320/600/1000px 레이아웃, 25개 버튼의 실제 클릭과 누적 표시다.
