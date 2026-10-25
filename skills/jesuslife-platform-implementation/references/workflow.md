# 개발 자료 안내

개발 스킬의 자료 진입점이다. 절차 원본은 기존 라우터 단독 설치와의 호환성을 위해 공통 references에 한 번만 유지한다. 문서를 복사하지 않는다.

1. 작업 시작 전 [공통 보호·질문·승인·사전 안내 규칙](../../jesuslife-platform-development/references/common-rules.md)을 적용한다. 라우터를 재호출하지 않는다.
2. [제품 경계](../../jesuslife-platform-development/references/project-boundaries.md)를 확인한다.
3. 대상 작업에 해당하는 절차만 선택한다.
   - Flutter·SQLite·로컬 저장: [Flutter 절차](../../jesuslife-platform-development/references/flutter-workflow.md).
   - FastAPI·인증·동기화·migration: [API 절차](../../jesuslife-platform-development/references/api-workflow.md).
   - CHGO: [온톨로지 절차](../../jesuslife-platform-development/references/ontology-workflow.md).
4. 외부 보조 스킬을 검토할 때만 [외부 스킬 규칙](../../jesuslife-platform-development/references/external-skill-routing.md)을 읽는다.
5. 테스트·빌드·릴리스 검증 결과는 [품질 게이트](../../jesuslife-platform-development/references/quality-gate.md)로 보고한다.

공통 자료가 없으면 변경 없이 BLOCKED로 보고한다. 설계가 필요한 복합 요청은 design → 필요한 승인 → implementation 순서를 따른다. 관련 없는 절차를 일괄 로드하지 않는다.

## 변경 전 확인과 실행

대상 경로, AGENTS.md·프로젝트 문서, 현재 브랜치, git status --short와 미커밋 diff를 확인한다. 사용자 변경을 보존하고 main을 수정하지 않는다. 화면 → 상태/모델 → 저장소 계약 → 구현 → DB/API → 테스트를 추적하고 기존 구조를 재사용해 최소 변경한다. 복구 가능한 데이터 변경과 회귀 테스트를 적용한다. 필요한 설계가 미정이면 구체적 초안을 제시하고 승인된 부분부터 구현한다.
