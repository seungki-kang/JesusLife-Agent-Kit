# JLBible Codex 작업 지침

이 저장소의 모든 작업에 `jesuslife-platform-development`를 자동 적용한다.

## 핵심 원칙

- 성경 본문, 인물, 연대, 지도, 평행본문의 정확성과 근거를 최우선으로 한다.
- 번역본 라이선스와 국가별 사용 권한을 확인하지 않은 본문을 배포하지 않는다.
- Canonical ID, 스키마·API 버전, migration, changelog, deprecation을 관리한다.
- 예수생명과 하나님 나라 해석축은 근거와 승인 상태를 표시한다.
- 추론 후보와 승인된 성경·신학 데이터를 섞지 않는다.

작업 전 브랜치·Git 상태·검증기·데이터 출처를 확인한다. 본문 변경, 라이선스가 불명확한 데이터 사용, 배포, commit·push·merge는 별도 승인 없이 수행하지 않는다.

## 검증

스키마, Canonical ID, 참조 무결성, 본문 해시, 출처·라이선스, 회귀 검증기를 실행한다. 앱 코드는 정적 분석, 관련 테스트, 전체 테스트, 빌드 순서로 확인한다.

결과는 `PASS`, `FAIL`, `NOT_RUN`, `BLOCKED`, `AUTHOR_REVIEW_REQUIRED`로 보고한다.

