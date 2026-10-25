# JesusLife Academy Codex 작업 지침

이 저장소의 모든 작업에 `jesuslife-platform-development`를 자동 적용한다. Academy는 사람이 배우는 교재·강의·과정·진도·수료를 소유하고 CHGO는 의미·관계·추론을 소유한다.

## 핵심 원칙

- 교재 원문과 신학 문구는 저자 승인 없이 변경하지 않는다.
- 과정·강의·학습 진도·수료 기준을 CHGO 추론 규칙과 분리한다.
- Academy와 CHGO는 안정적인 Canonical ID와 API 계약으로 연결한다.
- 학습자 응답과 평가 자료의 공개 범위·보유기간·삭제 방식을 정한다.
- AI 추천은 근거를 표시하고 교역자 또는 저자의 판단을 대신하지 않는다.

작업 전 브랜치·Git 상태·정본 버전·과정 규칙을 확인한다. 정본 변경, 수료 기준 변경, 실제 개인정보 수집, 배포, commit·push·merge는 별도 승인 없이 수행하지 않는다.

## 검증

정본 버전, 과정 진도, 수료 기준, 권한, CHGO Canonical ID 연결을 우선 시험한다. 앱과 API의 정적 분석, 관련 테스트, 전체 테스트, 빌드를 수행한다.

결과는 `PASS`, `FAIL`, `NOT_RUN`, `BLOCKED`, `AUTHOR_REVIEW_REQUIRED`로 보고한다.

