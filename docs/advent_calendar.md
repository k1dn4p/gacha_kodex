# 크리스마스 마을: 1일·2일·12일

> 향후 1~25일 구현은 [VILLAGE_25_DAY_PLAN.md](VILLAGE_25_DAY_PLAN.md)의 날짜별 변화 표와 트리 단계 표를 따른다. 해당 문서는 계획이며 현재 구현 완료 목록이 아니다.

## 실행과 진입

```sh
flutter pub get
flutter run -d chrome
```

Settings → **크리스마스 어드벤트 모드** 켜기 → **Calendar** 탭.
기존 가챠 설정과 티켓 기록은 별도로 유지한다.

## 현재 동작

- `Viliage_Day0.png`를 기본 배경으로 표시한다.
- 현재는 1일·2일·12일을 표시한다. 1일은 `Day1_Bakery Show Window.png`, 2일은 `Day02_Attic_Window.png`, 12일은 `Day12_Walking_Couple.png`가 나타난다. 개봉한 날짜의 변화는 누적된다.
- 선물 제목과 문구 팝업, 재열람, 개봉 기록 저장·복원을 유지한다.
- `Viliage_Day25.png`는 완성 모습 참고용이며 실행용 에셋에 등록하지 않는다.
- 이전 문·빵·리스 임시 레이어와 과거 프로토타입의 2~3일 내용은 사용하지 않는다. 현재 2일은 새 다락집 창문 이미지다.
- 사용자 확정에 따라 Day02 PNG 전체를 2일에 함께 표시한다. 발코니 양말·가랜드도 2일에 나타나며 원본 이미지는 분리하지 않는다. 기존 11일 장식 파일 제작은 보류하고, 11일의 대체 변화는 추후 결정한다.

## 이미지와 좌표

현재 사용하는 배경과 오버레이 PNG의 크기는 모두 **1051 × 1496**이다. 원본과 투명 여백은 수정하지 않는다.
`villageCanvas`는 가로 600, 세로 `600 * 1496 / 1051`로 원본 비율을 유지한다. 장면 전체가 화면 너비에 맞춰 함께 확대·축소된다.

`lib/advent/village_config.dart`에서 설정한다.

| 설정 | 역할 |
|---|---|
| `villageDays` | 날짜, 개봉 가능 시각, 선물 제목과 문구 |
| `villageLayers` | 이미지 경로, 위치·크기, 표시 조건, 앞뒤 순서, 전환 효과 |
| `villageHotspots` | 터치 영역과 숫자 정렬 |

날짜 숫자의 스타일은 `lib/widgets/village_scene.dart`의 `_DayTarget`에서 설정한다. 현재 글자 크기는 18, 배지는 34 × 32, 배지 배경의 불투명도는 0.55다. 배지만 작아지고 터치 영역은 유지된다.

배경은 전체 캔버스인 `villageBounds`에 배치한다. Day1은 전체 크기가 같아도 내부 창문 그림의 크기·위치가 달라 레이어를 별도 보정했다. 사용자가 조정한 최신 위치는 `village_config.dart`의 Day1 `bounds`를 기준으로 한다. 숫자 1은 터치 영역 왼쪽에 표시한다.

Day12는 배경과 같은 `villageBounds`를 사용한다. 왼쪽 굽은 길에 연인 두 명이 추가되며 터치 영역은 `Rect.fromLTWH(60, 420, 120, 110)`이다. 숫자 12는 인물을 가리지 않도록 영역 오른쪽에 표시한다.

Day02도 `villageBounds`에 그대로 겹친다. 좌상단 다락집 창문을 누를 수 있도록 터치 영역은 `Rect.fromLTWH(65, 110, 110, 100)`이며 숫자는 오른쪽에 배치한다.

이후 레이어를 배경과 정확히 같은 좌표로 제작하면 `villageBounds`에 그대로 겹칠 수 있다. 새 실행 이미지는 `pubspec.yaml`에 등록한다. 기본 이미지 폴더의 PNG는 개별 등록해 PPT와 Office 잠금 파일이 실행 에셋에 포함되지 않도록 한다.

## 상태와 개발 패널

올해 12월 1일·2일·12일 기기 현지 시각 00:00부터 해당 날짜를 개봉할 수 있다. 기록은 SharedPreferences의 `advent_opened_days_v1_<연도>`에 저장한다. 기존에 해당 날짜를 열었던 기록이 있으면 이미지도 개봉 상태로 나타난다. 이전 날짜를 먼저 열도록 강제하지 않는다.

개발 패널은 `11/30`, `12/1`, `12/2`, `12/12`, 날짜·시간 선택, 실제 시각 복귀, 잠금 무시, 터치 영역 표시, 개봉 상태 초기화를 제공한다. 2일은 `12/2`를 선택한 뒤 숫자 2를 누른다. 개발 옵션은 세션에만 유지되고, `kDebugMode`가 아닌 빌드에서는 비활성화된다.

저장 성공 후에만 장면을 갱신한다. 기록 복원과 선물 재열람에서는 등장 애니메이션을 반복하지 않는다.

## 검증

```sh
flutter test test/advent_provider_test.dart test/village_scene_test.dart test/widget_test.dart
flutter analyze
```

Windows에서 실제 장면 미리보기 생성:

```sh
flutter test test/village_scene_test.dart --dart-define=VILLAGE_PREVIEW=true
```

`build/village_preview/closed.png`(초기), `opened.png`(1일), `day02_opened.png`(1일·2일), `day12_opened.png`(1일·2일·12일 누적)가 생성된다. 미리보기 옵션은 Windows의 맑은 고딕 폰트를 사용하며 일반 테스트에는 필요하지 않다.

## 다음 날짜 추가

날짜 설정 → 레이어 → 터치 영역 → 에셋 등록과 테스트 순서로 추가한다. 전체 목표는 1~25일이며 현재는 1일·2일·12일만 연결했다. `tools/generate_advent_assets.ps1`는 이전 임시 빵집 이미지 생성용이며 현재 마을 PNG를 생성하지 않는다.

## 2026-11-06 추가: 어드벤트 Ticket과 전용 이미지

이 절은 앞선 저장 키·실행 에셋 등록 설명보다 우선한다.

- 날짜 선물을 처음 개봉하면 Ticket 1개를 지급한다. Calendar 탭 방문이나 선물 재열람은 지급하지 않는다. 기존에 개봉한 날짜도 1개씩 인정한다.
- 홈·Calendar·가챠·현황·설정·결과의 고정 AppBar에 Ticket 잔액을 표시한다. 일반 모드에서는 표시하지 않는다.
- Ticket 0개이면 가챠 카드를 눌러도 열리지 않는다. 끝까지 찢어 저장에 성공하면 1개 차감한다. 취소·짧은 드래그는 차감하지 않는다.
- 어드벤트 개봉 날짜와 가챠 카드 기록은 `advent_progress_v2_<연도>` JSON 하나에 저장한다. 잔액은 개봉 날짜 수에서 사용한 카드 수를 뺀 값이다. 기존 v1 날짜 기록은 최초 로드 시 읽고 다음 저장부터 v2를 사용한다.
- 일반 가챠 기록과 분리한다. 어드벤트 카드 구성은 현재 기존 기본 테마의 A~H 수량을 사용하며, 전용 상품명·수량은 별도 확정 전이다. 일반 Settings의 상품 테마·수량 변경은 어드벤트 카드 구성을 변경하지 않는다.
- 개발 패널의 개봉 전체 초기화는 어드벤트 Ticket과 가챠 카드도 함께 초기화한다.
- 어드벤트 가챠·결과·현황 이미지는 `assets/images/advent/`에서 읽는다. 파일명은 `ticket_unopened.png`, `ticket_opened_A.png`~`ticket_opened_H.png`, `prize_A.png`~`prize_H.png`다. 누락 이미지는 임시 아이콘을 표시한다.
- 새 이미지를 넣으면 자동 포함되도록 pubspec에 `assets/images/advent/`를 등록했다. 작업 자료는 하위 `작업용/` 폴더에 두고, Office 문서·잠금 파일은 이 폴더 바로 아래에 두지 않는다. 이미지 추가 후 앱을 완전히 재실행한다.
- 2일 창문 안 작은 트리의 빛점 5개는 `villageLights`와 `village_lights.dart`에서 관리한다. 2일 개봉 후 지속적으로 반짝인다.
검증: 전체 flutter test 18개 통과. flutter analyze --no-pub --no-fatal-infos에서 오류·경고 없이 기존 정보성 lint 5건만 남았다. 실제 기기 확인과 릴리스 빌드는 이번 변경에서 실행하지 않았다.
