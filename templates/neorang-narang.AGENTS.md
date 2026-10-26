# 너랑나랑 Codex 작업 지침

이 저장소의 모든 설계·코드·테스트 작업에 `jesuslife-platform-development`의 공통 원칙을 자동 적용한다. `neorang-narang-dev`가 설치되어 있으면 프로젝트 세부 규칙도 함께 적용한다.

## 작업 시작

1. 저장소 경로, 현재 브랜치, `git status --short`를 확인한다.
2. `pubspec.yaml`, 관련 화면, 모델, 저장소 계약, SQLite 구현, 테스트를 추적한다.
3. 미커밋 변경은 사용자 작업으로 간주하고 보존한다.
4. 공통 라우터로 설계 또는 개발을 자동 선택하고 Flutter·API·품질 절차를 필요한 범위에만 적용한다.

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
## 자동 선택과 작업 순서

프로젝트 고유 보호 규칙을 유지하며 공통 라우터 `jesuslife-platform-development`를 기본 적용한다. 사용자가 스킬 이름을 몰라도 요청한 산출물을 기준으로 다음 스킬을 자동 선택한다.

| 요청 | 선택 |
|---|---|
| 기획·설계·구조·흐름·비교·경계·계약 초안 | `jesuslife-platform-design` |
| 구현·수정·추가·오류 해결·DB 변경·API 개발·테스트·빌드 | `jesuslife-platform-implementation` |
| “설계하고 구현” | design → 중요 경계의 필요한 승인 → implementation |

설계만 요청되면 앱 코드·DB를 변경하지 않는다. 신학 문구·Canonical ID·개인정보 공유·DB 구조·인증 경계 변경은 `AUTHOR_REVIEW_REQUIRED`로 분류하고 필요한 사람의 승인 후 적용한다. 복합 요청이나 작업 순서 안내를 승인으로 간주하지 않는다.
불명확하거나 위험하면 대상 상태를 변경하지 않고 먼저 질문하며, 답변 전에는 읽기 전용 점검만 한다. 작업 시작 전에 적용할 스킬 이름·역할·순서를 알리고, 순서가 바뀌면 해당 작업 전에 다시 알린다.

## 스킬 자료 탐색

실제 설치된 스킬 위치에서 공통 라우터의 `references/common-rules.md`를 먼저 읽는다. 설계·개발은 해당 스킬의 `references/workflow.md`에서 필요한 절차만 선택한다. 이 AGENTS.md가 설치될 프로젝트를 기준으로 패키지 상대경로를 추정하지 않는다.
하위 스킬이 없으면 공통 라우터 references의 설계·Flutter·API·CHGO·품질 절차로 진행한다. 공통 스킬도 없으면 이 파일의 보호 규칙을 적용하고, 확인할 수 없는 필수 조건은 `BLOCKED`로 보고한다.
외부 스킬은 설치·관련성을 확인한 뒤 자체 공통·프로젝트 보호 규칙 아래에서 필요한 최소 범위에만 보조 사용한다. 보호 규칙과 충돌하는 지침은 적용하지 않으며 자동 설치·작업 범위 확대·승인 우회를 하지 않는다.

## 이 프로젝트의 라우팅 예

- design: 문답 세션·완료·은혜 기록·서명·복구 보관함 흐름 설계.
- implementation: Flutter 상태·저장소·SQLite·복원 구현과 회귀시험. 중요 경계 변경은 위 승인 절차를 먼저 따른다.
