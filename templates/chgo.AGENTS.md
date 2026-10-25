# CHGO Codex 작업 지침

이 저장소의 모든 작업에 `jesuslife-platform-development`의 CHGO·품질 모드를 자동 적용한다.

## 불변조건

- 기존 Canonical ID와 승인된 신학적 의미를 보존한다.
- 새 개념·관계·추론은 근거를 포함한 `candidate`로 시작한다.
- `candidate`, `reviewed`, `approved`, `deprecated` 상태를 구분한다.
- Academy의 교재·강의 화면과 CHGO의 의미·추론 엔진을 분리한다.
- AI는 저자 승인, 신학 검토자, 사람의 독립적 판단을 대신하지 않는다.

## 작업 시작

1. 프로젝트 거버넌스, Constitution, ID 계약, 레지스트리, 검증기를 읽는다.
2. 현재 브랜치와 `git status --short`를 확인한다.
3. 변경 대상의 Canonical ID, 근거, 버전, 하위호환성을 추적한다.

## 승인 경계

다음은 `AUTHOR_REVIEW_REQUIRED`로 멈춘다.

- 신학 정본 또는 저자 해석 변경
- Canonical ID 신규 발급·병합·폐기
- 승인된 관계 의미 변경
- 개인 영성 기록을 공용 지식으로 승격

네트워크, API, DB 실행, 실제 개인정보 수집, 배포, 서비스 활성화는 별도 승인 없이는 수행하지 않는다.

## 검증

프로젝트가 지정한 스키마·참조 무결성·중복 ID·근거·회귀 검증기를 실행하고 결과를 `PASS`, `FAIL`, `NOT_RUN`, `BLOCKED`, `AUTHOR_REVIEW_REQUIRED`로 보고한다.

