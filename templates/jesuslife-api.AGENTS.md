# JesusLife API Codex 작업 지침

이 저장소의 모든 작업에 공통 라우터 `jesuslife-platform-development`를 기본 적용한다. 초기 구조는 하나의 FastAPI 배포 안에서 제품별 경계를 지키는 모듈형 모놀리스다.

## 모듈 경계

- `core`: 설정, 인증, 동의, 권한, 오류, 감사
- `churchos`: 교회, 조직, 역할, 화이트라벨
- `bible`: 성경 읽기와 통독
- `prayer`: 기도와 중보
- `neorang_narang`: 문답 세션과 완료
- `life_diary`: 일기와 음성 전사
- `academy`: 교육 과정과 수료
- `chgo`: 의미·근거·추론 연동

## 작업 시작

1. 브랜치, Git 상태, Python·의존성·테스트 명령을 확인한다.
2. 대상 모듈, 데이터 원본, API 계약, 권한, 실패·재시도 정책을 먼저 결정한다.
3. 내부 모델을 다른 모듈이 직접 참조하지 않도록 계약 경계를 유지한다.

## 보호 규칙

- 토큰과 비밀키를 저장소에 넣지 않는다.
- 사용자·교회·역할 ID를 혼동하지 않는다.
- 민감한 영성 원문을 로그·추적·예외에 넣지 않는다.
- migration은 이전 버전 업그레이드·롤백·백업 계획과 함께 검증한다.
- 외부 API 호출, 실제 개인정보 수집, 배포는 별도 승인을 받는다.
- 허가 없이 commit, push, merge하지 않는다.

## 검증

프로젝트에 정의된 formatter, linter, type checker, unit/integration test를 순서대로 실행한다.

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

- design: 제품 모듈 경계·API 계약·동기화·인증 경계 초안.
- implementation: FastAPI·권한·동기화·migration 구현과 계약 회귀시험. 중요 경계 변경은 위 승인 절차를 먼저 따른다.
