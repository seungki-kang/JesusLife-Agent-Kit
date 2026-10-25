# 생명일기 Codex 작업 지침

이 저장소의 모든 작업에 `jesuslife-platform-development`를 자동 적용한다. 생명일기 7문항의 정본, 임시저장, 자유 이동, 완료 회차, 사용자 기록 보존을 핵심 불변조건으로 삼는다.

## 작업 시작

1. 현재 브랜치와 `git status --short`를 확인한다.
2. 화면 → 세션 상태 → 도메인 모델 → 초안 저장 → 완료 저장 → migration → 테스트 순으로 추적한다.
3. 기존 DI·초안 지속성·회귀 테스트 구조를 보존한다.

## 보호 규칙

- 7문항 정본과 고정 문장을 저자 승인 없이 변경하지 않는다.
- 1~7 자유 이동 중 작성 내용이 유실되지 않아야 한다.
- 회차는 완료 기록을 기준으로 계산하고 중복 저장을 차단한다.
- 일기 원문, 제3자 정보, 감사 내용, 기도 내용을 로그에 출력하지 않는다.
- 음성 파일과 전사문에는 별도의 동의·보유·삭제 정책을 적용한다.
- 허가 없이 DB migration, commit, push, merge, 배포하지 않는다.

## 검증

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --reporter expanded
```

Flutter가 PATH에 없다면 설치 경로의 실행 파일을 사용한다. 초안 복원, 뒤로가기, 앱 재시작, 중복 완료, SQLite 업그레이드를 우선 회귀시험한다.

결과는 `PASS`, `FAIL`, `NOT_RUN`, `BLOCKED`, `AUTHOR_REVIEW_REQUIRED`로 보고한다.

