# 작업 인수인계: 크리스마스 빌리지

최종 정리: **2026-11-05 (한국 시각)**. 다른 컴퓨터나 새 AI 대화에서 먼저 읽을 문서.

## 1. 지금 어디까지 했는가

기존 Flutter 가챠 앱에 크리스마스 어드벤트 모드를 추가했다. 전체 목표는 **12월 1~25일**이며, 현재 실행 코드에 연결된 날짜는 **1일·2일·12일**이다. 예전 빵집 단독 1~3일 프로토타입 설명을 현재 구현으로 혼동하지 않는다.

기본 마을 그림 위에 날짜별 투명 PNG를 겹쳐 장면이 누적된다. Settings에서 어드벤트 모드를 켜면 홈 소개와 색상이 바뀌고 Calendar 탭이 나타난다. 기존 가챠·현황·설정·티켓 기록은 유지한다.

| 날짜 | 현재 연결된 이미지 | 개봉 후 변화 |
| --- | --- | --- |
| 1일 | `Day1_Bakery Show Window.png` | 빵집 쇼윈도 조명과 진열된 빵 |
| 2일 | `Day02_Attic_Window.png` | 다락집 창문 조명·실내 작은 트리·발코니 양말·가랜드 |
| 12일 | `Day12_Walking_Couple.png` | 왼쪽 굽은 길에서 손잡고 걷는 연인 두 명 |

**확정 사항:** Day02 PNG에 양말·가랜드가 포함된 것을 사용자가 확인했고, 이미지를 분리하지 않고 2일에 모두 표시하기로 선택했다. 원래 11일에 예정했던 양말·가랜드는 중복 추가하지 않는다. **11일의 대체 변화·파일명은 아직 미정**이며, 기존 `Day11_Balcony_Stockings.png`, `Day11_Balcony_Garland.png` 제작은 보류한다.

전체 날짜별 클릭 위치·변화·파일명·야외 주민 수와 트리 단계는 [VILLAGE_25_DAY_PLAN.md](VILLAGE_25_DAY_PLAN.md)를 따른다. 현재 구현 안내는 [advent_calendar.md](advent_calendar.md)를 참고한다.

## 2. 사용자가 원하는 방향과 작업 방식

- 달력 격자보다 그림책풍 크리스마스 마을의 문·창문·장식·길 속에 날짜가 들어가는 화면을 원한다.
- `Viliage_Day0.png`를 기본 배경으로, 날짜별 이미지를 하나씩 얹는다. `Viliage_Day25.png`는 완성 모습 참고용이며 전체 화면 교체용이 아니다.
- **한 날짜를 한 번 누르면 여러 레이어가 함께 나타나는 구조**를 원한다. 같은 날짜의 파일들은 같은 `dayId`와 `afterOpening` 조건으로 연결한다. 파일마다 따로 개봉하지 않는다.
- 날짜를 누르면 나오는 선물 제목·짧은 문구 팝업을 마음에 들어 했으므로 유지한다. 개봉한 선물 재열람도 유지한다.
- 코드는 이해하고 직접 수정할 수 있게 단순하게 유지한다. 사용자가 문법 설명을 요청하면 해당 코드 중심으로 간단히 설명한다.
- 사용자가 만든 PNG를 확인해서 연결한다. 이미지 전체 크기가 같더라도 내부 물체의 크기·위치·투명 여백까지 확인한다. 원본을 임의로 자르거나 수정하지 않는다.
- 의미 있는 모호함이 있으면 확인한다. 요청하지 않은 날짜나 가짜 콘텐츠를 임의로 채우지 않는다.
- Git 명령을 직접 실행하고 싶어 했고, 강제 초기화 과정에서 로컬 자료 누락을 겪었다. 커밋·push·reset·clean을 임의로 실행하지 않는다. 이번 마무리 요청은 문서 갱신이며 코드 수정 요청이 아니다.

## 3. 코드 구조와 이름

폴더명은 `gacha_kodex`, Dart 패키지명은 **`gacha_codex`**다.

| 파일 | 역할 |
| --- | --- |
| `lib/advent/village_config.dart` | 날짜·선물, 레이어, 좌표, 터치 영역, 색상 |
| `lib/widgets/village_scene.dart` | `VillageScene`, 이미지 겹치기·전환, 날짜 배지·터치 |
| `lib/providers/advent_provider.dart` | 개봉 판정·기록 저장·복원·초기화, 개발 옵션 |
| `lib/pages/calendar_page.dart` | 화면 배치, `_openDay`, 잠금 안내, 선물 팝업 |
| `lib/widgets/advent_debug_panel.dart` | 개발용 날짜·시간, 잠금 무시, 영역 표시·초기화 |
| `lib/providers/app_settings_provider.dart` | 어드벤트 모드 설정 저장 |
| `lib/widgets/advent_home_intro.dart` | 홈 화면 안의 어드벤트 소개 카드 |
| `lib/widgets/app_bottom_nav.dart` | 조건부 Calendar 탭과 화면 교체 이동 |
| `lib/main.dart` | Provider와 화면 라우트 등록 |
| `pubspec.yaml` | 실행 이미지 에셋 등록 |

`BakeryScene`, `bakery_config.dart`, `bakery_scene.dart`, `bakery_scene_test.dart`는 각각 `VillageScene`, `village_config.dart`, `village_scene.dart`, `village_scene_test.dart`로 이름을 통일했다. 이전 파일을 다시 생성하거나 별도 설정으로 유지하지 않는다. 빵집이라는 실제 건물 이름이나 파일명의 `Bakery`는 그대로 사용할 수 있다.

하단 탭의 페이지 ID는 메인 **0**, Calendar **1**, 가챠 **2**, 현황 **3**, 설정 **4**다. 각 페이지의 `AppBottomNav(currentIndex: ...)`도 이 번호에 맞췄다. `pageIds = [0, if (advent) 1, 2, 3, 4]`이며 Calendar 모드를 끄면 표시 위치만 달라진다. 선택·비선택 글자는 둘 다 크기 12·굵기 w600이고 색상으로 구분한다.

## 4. 좌표·스타일·레이어 설정

- 원본 기준: **1051 × 1496**.
- `villageCanvas = Size(600, 600 * 1496 / 1051)`, `villageBounds = Rect.fromLTWH(0, 0, 600, 600 * 1496 / 1051)`.
- `Rect.fromLTWH`는 왼쪽 거리·위쪽 거리·너비·높이다. 기준 도화지 전체를 화면에 맞춰 확대·축소한다.
- Day02와 Day12는 `bounds: villageBounds`로 그대로 겹친다.
- Day1은 내부 그림 크기·위치가 달라 별도 보정한다. 정리 시점 값은 `Rect.fromLTWH(21, 93, 484, 599)`이다. 사용자가 직접 위치를 조정하기도 했으므로 다음 작업 때 실제 최신 코드를 우선한다.
- `zIndex`는 클수록 앞에 그린다. 현재 배경 0, Day1 1, Day02 2, Day12 12다. 날짜 순서가 모든 인물·건물의 올바른 앞뒤 순서를 보장하지는 않으므로 이후 겹침을 확인한다.

현재 터치 영역(`x, y, 너비, 높이`)과 배지 정렬:

| 날짜 | `bounds` | `labelAlignment` |
| --- | --- | --- |
| 1일 | `Rect.fromLTWH(120, 305, 100, 100)` | `Alignment.centerLeft` |
| 2일 | `Rect.fromLTWH(65, 110, 110, 100)` | `Alignment.centerRight` |
| 12일 | `Rect.fromLTWH(60, 420, 120, 110)` | `Alignment.centerRight` |

배지는 그림을 덜 가리도록 줄였다. `_DayTarget`에서 숫자 크기 **18**, 굵기 **w600**, 배지 **34 × 32**, 배경 불투명도 **0.55**, 테두리 불투명도 **0.65**·두께 **1**, 모서리 **10**이다. 상태 아이콘은 크기 **12**, 불투명도 **0.8**이다. 표시 크기와 별도로 터치 영역을 유지한다.

`LayerVisibility`는 항상 / 개봉 전 / 개봉 후, `LayerMotion`은 none / fade / fadeScale이다. 표시 여부가 바뀔 때만 애니메이션을 실행하며 처음 기록을 복원하거나 선물을 재열람할 때 반복하지 않는다.

## 5. 개봉 상태와 개발 패널

- 기본 시즌은 Provider 생성 시점의 올해다. 현지 시각 12월 1일·2일·12일 자정부터 해당 날짜를 열 수 있다.
- 이전 날짜를 먼저 열도록 강제하지 않는다. 개봉 가능한 날짜는 각각 독립적으로 열 수 있다.
- 기록은 날짜 ID 집합 하나로 저장한다. 같은 날짜의 여러 레이어는 기록 하나를 공유한다.
- 모드 키는 `advent_calendar`, 개봉 키는 `advent_opened_days_v1_<연도>`다. 가챠 설정·티켓 기록과 분리한다.
- 저장 성공 후 상태를 갱신한다. 재열람은 기록을 바꾸지 않는다. 잠긴 날짜는 안내만 표시한다.
- 서버 시간 검증·계정 동기화는 없다. **다른 컴퓨터에 Git으로 코드를 옮겨도 사용자 개봉 기록은 옮겨지지 않는다.**
- 디버그 패널: `11/30`, `12/1`, `12/2`, `12/12`, 직접 날짜·시간 선택, 실제 시각 복귀, 잠금 무시, 터치 영역 표시, 초기화.
- 개발용 선택은 자동 개봉을 하지 않으며 세션에만 유지된다. 테스트 시각 변경은 시즌 연도·저장 키를 바꾸지 않는다.
- `kDebugMode`로 UI와 개발 메서드를 보호한다. profile/release에서는 패널이 나타나지 않는다.

## 6. 에셋·자료 파일과 아직 연결하지 않은 것

실행에 필요한 아래 네 이미지는 모두 `assets/images/advent/`에 있고 `pubspec.yaml`에 개별 등록돼 있다.

1. `Viliage_Day0.png`
2. `Day1_Bakery Show Window.png` — 이전 `Bakery Show Window_Day1.png`에서 이름을 바꿨고 코드·문서도 갱신했다.
3. `Day02_Attic_Window.png`
4. `Day12_Walking_Couple.png`

추가 자료:

- `Viliage_Day25.png`: 최종 모습 참고용. 실행 장면에 연결하지 않는다.
- `Viliage_Day0_light off.png`: 정리 시점에 새로 존재하는 이미지. **현재 코드·pubspec에 연결되지 않았고 내용 비교·배경 교체 결정도 하지 않았다.** 기존 Day0을 임의로 교체하지 않는다.
- `assets/images/advent/작업용/`: 사용자 작업 자료. 앱 연결을 가정하지 않는다.
- `assets/images/images_ppt.pptx`: 사용자 수정이 있는 자료. 내용 분석·앱 연동은 하지 않았다.
- `docs/description_table.xlsx`: 현재 존재한다. 기존 `assets/images/advent/description_table.xlsx`는 삭제 상태이며 이동된 자료로 보이지만 이동 이력을 별도 검증하지 않았다. 연동하지 않았다.
- `assets/images/advent/Full_image.png`: Git에서 삭제 상태. 현재 기본 그림은 위 Day0이다. 자동 복원하지 않는다.
- 이전 `exterior.png`, `window_light.png`, `closed_door.png`, `open_door.png`, `bread.png`, `wreath.png`는 폴더에 남아 있지만 현재 장면에서 쓰지 않는다. `tools/generate_advent_assets.ps1`도 과거 임시 빵집 생성용이다.

PPT가 열린 상태에서 `assets/images/` 전체를 등록하면 `~$images_ppt.pptx` 잠금 파일을 읽다가 Flutter가 실패했다. 기본 폴더의 실행 PNG는 개별 등록하도록 정리했으며 PPT·Office 잠금 파일은 실행 에셋으로 포함하지 않는다.

## 7. 검증 결과와 남은 확인

이번 세션에서 종료 결과까지 확인한 최신 관련 테스트:

```sh
flutter test test/advent_provider_test.dart test/village_scene_test.dart test/widget_test.dart --dart-define=VILLAGE_PREVIEW=true
```

**12개 모두 통과.** 1일·2일·12일 잠금 경계, 누적 이미지, 선물 팝업·재열람, 저장·복원·초기화, 복원 시 애니메이션 생략, 화면 너비 320/600/1000에서 레이어·터치 영역을 확인했다. 잠금 안내 테스트에서는 이전 SnackBar를 정리해 다음 날짜 안내가 대기열에 가려지지 않도록 했다.

다음 5개 파일에 대한 `flutter analyze --no-pub`도 **No issues found**로 종료했다: `lib/advent/village_config.dart`, `lib/pages/calendar_page.dart`, `lib/widgets/advent_home_intro.dart`, `test/advent_provider_test.dart`, `test/village_scene_test.dart`.

미리보기 생성·열람을 완료했다. `build/village_preview/closed.png`, `opened.png`, `day02_opened.png`, `day12_opened.png`이며 마지막은 1일·2일·12일 누적 장면이다. `VILLAGE_PREVIEW=true`는 Windows 맑은 고딕 폰트를 사용하므로 다른 OS의 일반 테스트에서는 옵션을 뺀다. `build/`는 Git에서 제외돼 새 컴퓨터에서 재생성해야 한다.

실제 확인한 SDK는 Flutter **3.41.4**, Dart **3.11.1**이다. 다른 컴퓨터에서는 버전을 다시 확인한다.

미확인·기존 문제:

- 전체 `flutter test`와 `flutter build web --release`는 현재 최종 코드 기준으로 성공을 재확인하지 않았다.
- 이전 검사에서 `ticket_tear_dialog_test.dart`의 `cancelled drag resets without consuming the ticket`가 실패했다는 기록이 있다. 이번 작업에서 수정하거나 재검증하지 않았다.
- 앞선 전체 분석에는 기존 가챠 관련 정보성 lint 6건이 남아 있었다. 최신 관련 파일 분석 결과와 구분한다.
- 실제 모바일 기기 수동 검증과 배포는 하지 않았다.
- 이 마무리 요청에서는 문서만 정리하며 테스트·빌드를 다시 실행하지 않았다. 위 결과는 이번 세션의 가장 최근 검증 기록이다.

## 8. Git 상태와 다른 컴퓨터로 전달

정리 시점 `main`의 HEAD와 로컬 `origin/main`은 **`62fa7ef` (`handover works(md)`)**다. 원격을 새로 fetch하지는 않았다. **오늘의 변경은 아직 미커밋 상태이며 에이전트가 commit·push하지 않았다.** 로컬 `origin/main`과 같다는 표시가 오늘 작업이 서버에 저장됐다는 뜻은 아니다.

다른 컴퓨터에서 이어가려면 현재 컴퓨터에서 코드·테스트·문서·필요한 새 PNG와 이름 변경을 검토해 커밋하고 push해야 한다. 새 파일이 아직 untracked이므로 기존 파일 수정만 커밋하면 새 컴퓨터에서 import나 이미지 로딩이 실패할 수 있다. 특히 아래를 함께 포함한다.

- 새 `village_config.dart`, `village_scene.dart`, `village_scene_test.dart`와 예전 bakery 파일 삭제.
- Provider·페이지·하단 탭·홈 소개·`pubspec.yaml`·기존 테스트 변경.
- 실행용 네 PNG와 필요한 참고 자료.
- 이 문서, `VILLAGE_25_DAY_PLAN.md`, `advent_calendar.md`.

사용자가 수정한 PPT, 자료 이동·삭제, 작업용 폴더도 별도 검토한다. `~$`로 시작하는 Office 잠금 파일은 커밋 대상에서 제외한다. 일괄 덮어쓰기나 `reset --hard`, `git clean`으로 미커밋 자료를 없애지 않는다.

다른 컴퓨터에서는 먼저 로컬 변경·충돌 여부를 확인하고, 보존이 필요한 작업을 정리한 뒤 같은 브랜치에서 pull하거나 새로 clone한다. 그다음:

```sh
flutter --version
flutter pub get
flutter run -d chrome
```

새 이미지나 파일명을 바꿨을 때는 Hot Reload만으로 에셋 갱신이 안 될 수 있으므로 앱을 완전히 종료하고 재실행한다. Calendar에서 `12/2`를 선택하고 2일, `12/12`를 선택하고 12일을 눌러본다. 기존 기록이 있으면 초기화 후 확인한다.

## 9. 다음 작업

1. 동기화된 코드와 에셋이 모두 있는지 확인하고 현재 1일·2일·12일 장면을 실행한다. 완료된 기능을 다시 만들지 않는다.
2. 사용자가 다음으로 준비한 PNG와 요청한 날짜를 확인한다. 아직 없는 날짜를 빈 이미지나 임의 문구로 채우지 않는다.
3. 11일을 작업할 때는 새 변화·파일명을 사용자와 정한다. 양말·가랜드는 이미 2일에서 표시한다.
4. 새 파일은 계획 표에 맞춰 확인하고 날짜 설정 → 레이어 → 터치 영역 → 에셋 등록 → 관련 검증 순서로 연결한다.
5. 날짜가 추가되면 현재 1일·2일·12일로 적힌 Calendar·홈 안내와 문서도 함께 갱신한다.
6. 실제 서비스 전에는 전체 테스트·분석·릴리스 빌드와 작은 화면 조작성을 별도로 확인한다.

다음 대화에 전달할 문장:

> `docs/WORK_HANDOFF.md`, `docs/VILLAGE_25_DAY_PLAN.md`, `docs/advent_calendar.md`를 먼저 읽어줘. Day0 위에 날짜별 투명 PNG를 누적하는 빌리지이고 현재 1일·2일·12일이 구현돼 있어. Day02의 양말·가랜드도 2일에 표시하기로 확정했으므로 11일의 대체 변화는 미정이야. 코드와 에셋의 실제 상태를 확인하고 기존 가챠와 완료된 기능을 유지하면서 내가 요청하는 다음 작업을 이어가줘.
