# JesusLife API Codex 작업 지침

이 저장소의 모든 작업에 `jesuslife-platform-development`의 API·품질 모드를 자동 적용한다. 초기 구조는 하나의 FastAPI 배포 안에서 제품별 경계를 지키는 모듈형 모놀리스다.

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

