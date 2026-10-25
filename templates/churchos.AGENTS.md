# ChurchOS Codex 작업 지침

이 저장소의 모든 작업에 `jesuslife-platform-development`를 자동 적용한다. ChurchOS는 교회 운영과 화이트라벨 통합 앱이며 JesusLife One의 사용자 통합 경험을 제공한다.

## 핵심 경계

- ChurchOS는 교회·조직·역할·교회별 설정을 소유한다.
- JLBible, JLPrayer, 너랑나랑, 생명일기, Academy 데이터의 원본을 복제 소유하지 않는다.
- 교회별 브랜드 설정과 기능 설정을 코드 복제보다 구성으로 처리한다.
- 교회 테넌트 간 데이터 격리를 서버에서 검증한다.

작업 전 브랜치와 Git 상태를 확인하고, 설계 변경은 데이터 소유권·권한·화이트라벨 영향을 먼저 문서화한다. 개인정보 수집·배포·commit·push·merge는 별도 승인 없이 수행하지 않는다.

## 검증

관련 단위·위젯·통합 테스트, 정적 분석, 빌드를 순서대로 실행한다. 교회 전환과 테넌트 격리, 역할별 권한, 화이트라벨 구성을 우선 회귀시험한다.

결과는 `PASS`, `FAIL`, `NOT_RUN`, `BLOCKED`, `AUTHOR_REVIEW_REQUIRED`로 보고한다.

