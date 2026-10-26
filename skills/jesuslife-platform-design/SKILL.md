---
name: jesuslife-platform-design
description: JesusLife 제품 기획·경계·흐름·데이터 소유권·API 계약 초안·ADR·CHGO 후보·대안 비교·로드맵 설계 요청에 자동 적용한다. 설계 요청만으로 앱 코드나 DB를 변경하지 않는다.
---

# JesusLife 설계

작업 전에 [공통 보호 규칙](../jesuslife-platform-development/references/common-rules.md)을 적용하고 [설계 자료 안내](references/workflow.md)를 읽는다. 적용할 스킬과 순서를 먼저 알린다. 라우터를 재호출하지 않는다.

설계 산출물을 작성하며 설계 요청만으로 앱 코드·DB를 변경하지 않는다. 불명확하거나 위험하면 변경 없이 질문한다. 중요 경계는 AUTHOR_REVIEW_REQUIRED로 분류하며 복합 요청은 설계 → 필요한 승인 → 개발 순서로 진행한다. 세부 절차와 검증·보고는 자료 안내에 연결된 references를 따른다. 공통 자료가 없으면 BLOCKED로 보고한다.