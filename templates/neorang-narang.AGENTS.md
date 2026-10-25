# 너랑나랑 Codex 작업 지침

이 저장소의 모든 설계·코드·테스트 작업에 `jesuslife-platform-development`의 공통 원칙을 자동 적용한다. `neorang-narang-dev`가 설치되어 있으면 프로젝트 세부 규칙도 함께 적용한다.

## 작업 시작

1. 저장소 경로, 현재 브랜치, `git status --short`를 확인한다.
2. `pubspec.yaml`, 관련 화면, 모델, 저장소 계약, SQLite 구현, 테스트를 추적한다.
3. 미커밋 변경은 사용자 작업으로 간주하고 보존한다.
4. 요청을 설계, Flutter, API, 품질 중 필요한 모드로 자동 분류한다.

## 보호 규칙

- 완료 기록, 은혜 기록, 서명, 이름을 임의로 삭제하지 않는다.
- 교재·기도문·문답 문구의 신학적 의미를 승인 없이 변경하지 않는다.
- 이름·은혜 기록·서명 내용을 로그에 출력하지 않는다.
- DB 버전과 migration은 영향·복구·업그레이드 시험 계획 없이 변경하지 않는다.
- 삭제는 복구 보관함을 우선하고 영구 삭제는 별도 확인한다.
- 허가 없이 commit, push, merge, 배포하지 않는다.

## 검증

변경 범위에 맞는 테스트부터 실행한 뒤 다음을 수행한다.

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --reporter expanded
```

Flutter가 PATH에 없다면 설치 경로의 실행 파일을 사용한다. SQLite 변경은 새 설치와 기존 DB 업그레이드를 함께 검증한다.

결과는 `PASS`, `FAIL`, `NOT_RUN`, `BLOCKED`, `AUTHOR_REVIEW_REQUIRED`로 보고한다.

