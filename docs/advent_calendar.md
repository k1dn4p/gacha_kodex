# 크리스마스 빵집 프로토타입

## 실행과 진입

```sh
flutter pub get
flutter run -d chrome
```

Settings → **크리스마스 어드벤트 모드** 켜기 → **Calendar** 탭.
기존 가챠 설정과 티켓 기록은 그대로 유지됩니다.

개발 빌드에서는 장면 아래에 테스트 패널이 표시됩니다.
- `11/30`: 모든 미개봉 날짜 잠금 확인
- `12/1`, `12/2`, `12/3`: 해당 시즌의 자정으로 테스트 시각 변경
- `날짜·시간 변경`: 날짜와 시·분을 직접 선택 (기기 시각은 변경하지 않음)
- `실제 시각 사용`: 테스트 시각 해제
- `날짜 잠금 무시`: 미개봉 날짜를 누를 수 있게 허용; 자동 개봉하지 않음
- `터치 영역 테두리 표시`: 숫자와 별도로 정의한 클릭 영역 확인
- `개봉 상태 전체 초기화`: 현재 시즌 기록을 비우고 초기 모습으로 즉시 복원

개발 설정은 저장하지 않습니다. `kDebugMode`로 UI와 상태 변경 메서드를 모두 보호하므로 profile/release에서는 테스트 시각·잠금 우회를 사용할 수 없습니다.

## 구현 파일

- `lib/advent/bakery_config.dart`: 날짜/선물 설정, 레이어 설정, 터치 영역, 색상
- `lib/providers/advent_provider.dart`: 개봉 가능 시각 판단, 날짜별 기록, 로컬 저장, 개발 설정
- `lib/widgets/bakery_scene.dart`: 기준 캔버스 전체 스케일링, 레이어 표시/전환, 숫자/터치
- `lib/pages/calendar_page.dart`: 화면과 잠금 안내, 선물 팝업
- `lib/widgets/advent_debug_panel.dart`: 개발용 테스트 패널
- `tools/generate_advent_assets.ps1`: 외부 다운로드 없이 임시 투명 PNG 6개 생성

## 상태와 날짜

`AdventDay`는 `dayId`, `unlockAt`, `gift`를 정의하고, `AdventDayState`는 해당 설정과 `isOpened`를 제공합니다. 저장은 날짜 ID 집합 하나뿐입니다. 이미지별 개봉 기록은 없습니다.

올해 12월 1~3일 **기기 현지 시각 00:00**에 각각 개봉할 수 있습니다. 테스트 시각은 잠금 판정에만 적용하며 시즌 자체를 변경하지 않습니다. 일자를 순서대로 열도록 강제하지 않습니다.

SharedPreferences의 `advent_opened_days_v1_<연도>`에 저장합니다. 앱을 새로 실행해 다른 연도가 되면 해당 연도 기록을 사용합니다. 미래의 실제 서비스에서는 시즌 연도와 `unlockAt`을 기획에 맞춰 명시적으로 지정할 수 있습니다. 현재는 기기 시계 기반 로컬 프로토타입이며 서버 시간 검증은 없습니다.

저장 성공 후에만 화면 상태를 갱신합니다. 저장 실패 시 기존 상태를 유지하고 안내합니다. 최초 로딩이 끝난 뒤 장면을 생성하므로 복원 상태에는 전환 애니메이션이 없습니다. 재열람 또한 상태를 바꾸지 않아 애니메이션을 반복하지 않습니다.

## 이미지 교체

모든 PNG는 투명 배경이며 `assets/images/advent/`에 있습니다. 날짜 숫자는 PNG에 포함하지 않습니다.

기준 캔버스는 **600 × 760**입니다. 현재 PNG는 선명도를 위해 배치 크기의 2배 해상도로 생성했습니다.

| 레이어 | 기준 좌표 x, y, 너비, 높이 | 조건 |
|---|---|---|
| exterior | 30, 140, 540, 520 | 항상 |
| window_light | 100, 360, 175, 165 | 1일 개봉 후 |
| closed_door | 350, 350, 130, 230 | 2일 개봉 전 |
| open_door | 350, 350, 130, 230 | 2일 개봉 후 |
| bread | 380, 448, 92, 110 | 2일 개봉 후 |
| wreath | 445, 258, 90, 90 | 3일 개봉 후 |

실제 PNG로 교체하려면 `bakeryLayers`의 `assetPath`, `bounds`를 수정하고 필요하면 `pubspec.yaml`에 경로를 등록합니다. `zIndex`가 클수록 앞에 표시됩니다. `visibility`와 `dayId`로 날짜 상태를 참조합니다. `enterMotion`, `exitMotion`은 none/fade/fadeScale을 지원하며 각각의 Duration으로 재생 시간을 지정합니다.

닫힌 문과 열린 문은 **같은 투명 캔버스 크기와 배치 기준**으로 준비하고 `bakeryDoorBounds`를 함께 사용하세요. 외관에는 교체할 문짝을 그리지 마세요. PNG 내부 여백도 배치 기준의 일부이며 자동으로 자르지 않습니다.

별도 `bakeryHotspots`의 `bounds`가 터치 영역입니다. 이미지만 교체할 때에는 터치 영역을 그대로 둘 수 있습니다. 건물 위치를 바꾸면 대응하는 영역도 수정하세요. 전체 장면을 한 번만 확대/축소하므로 이미지, 숫자, 터치 영역이 함께 움직이고 개별 크롭은 하지 않습니다.

임시 에셋 재생성 (Windows, System.Drawing 사용):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/generate_advent_assets.ps1
```

스크립트는 위 6개 PNG만 덮어씁니다. 실제 그림으로 교체한 뒤에는 재생성하지 마세요.

## 4~25일 추가

1. `bakeryDays(year)`에 실제 `unlockAt`과 `AdventGift`를 가진 `AdventDay`를 추가합니다.
2. `bakeryLayers`에 해당 날짜를 참조하는 이미지 레이어와 표시 조건을 추가합니다.
3. `bakeryHotspots`에 해당 날짜의 터치 영역을 추가합니다.
4. 에셋을 등록하고 테스트를 추가합니다.

4~25일의 가짜 날짜나 빈 선물은 생성하지 않았습니다. 현재 화면에 없는 날짜는 개봉 대상이 아닙니다. 새로운 레이어를 위해 렌더링 코드에 `if (day == ...)`를 추가할 필요가 없습니다.

## 검증 명령

```sh
flutter test test/advent_provider_test.dart test/bakery_scene_test.dart test/widget_test.dart
flutter analyze
flutter build web --release
```

Windows에서 실제 Flutter 위젯의 초기/개봉 장면 PNG 생성:

```sh
flutter test test/bakery_scene_test.dart --dart-define=BAKERY_PREVIEW=true
```

결과는 `build/advent_preview/closed.png`, `opened.png`입니다. 이 옵션에서만 Windows의 맑은 고딕 폰트를 읽으며 일반 테스트/앱에는 영향을 주지 않습니다.
