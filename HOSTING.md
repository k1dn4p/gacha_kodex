# Firebase Hosting 웹 배포

이 앱은 Flutter 웹 정적 파일로 배포합니다. 뽑기 기록은 브라우저 로컬 저장소에 저장되며 기기 간에 공유되지 않습니다.

## 최초 준비

1. [Firebase 콘솔](https://console.firebase.google.com/)에 Google 계정으로 로그인하고 프로젝트를 만듭니다.
2. [공식 안내](https://firebase.google.com/docs/cli#install_the_firebase_cli)에 따라 Firebase CLI를 설치합니다. Windows 독립 실행형 CLI 또는 Node.js와 npm을 사용할 수 있습니다.
3. 프로젝트 루트에서 `firebase login`을 실행합니다.

`firebase.json`이 있으므로 `firebase init`은 필요하지 않습니다.

## 빌드와 배포

프로젝트 루트에서 실행합니다.

```powershell
flutter pub get
flutter build web --release
```

빌드가 성공한 경우에만 아래 명령을 실행합니다. 현재 연결된 Firebase 프로젝트 ID는 `ahk-kuji`입니다.

```powershell
firebase deploy --only hosting --project ahk-kuji
```

출력에 표시되는 Hosting URL로 접속합니다. 이후 수정 사항도 다시 빌드한 후 배포합니다.
배포 대상은 `web`이 아닌 `build/web`입니다. 앱 경로는 `index.html`로 연결되며 캐시는 매번 재검증합니다.

배포 후 모바일 화면에서 티켓 선택, 결과 이미지 표시, 새로고침 후 기록 유지를 확인합니다.
요금제와 사용량 한도는 Firebase 콘솔에서 확인합니다.

공식 문서: [Flutter 웹 배포](https://docs.flutter.dev/deployment/web), [Firebase Hosting](https://firebase.google.com/docs/hosting/quickstart).
