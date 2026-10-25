---
name: jesuslife-platform-development
description: JesusLife 제품 작업의 공통 보호 규칙과 자동 라우터. 기존 호출 이름을 유지하며 기획·설계는 design, 코드·DB·API·테스트·빌드는 implementation으로 분류한다. 단순 개념 설명과 코드 학습은 제외한다.
---

# JesusLife 공통 라우터

작업 전에 [공통 보호·라우팅 절차](references/common-rules.md)를 읽고 적용할 스킬과 순서를 알린다. 불명확하거나 위험한 요청은 변경 없이 질문한다. 중요 경계는 AUTHOR_REVIEW_REQUIRED로 분류하고 필요한 승인 전 변경하지 않는다.

- 설계: [design](../jesuslife-platform-design/SKILL.md).
- 구현: [implementation](../jesuslife-platform-implementation/SKILL.md).
- “설계하고 구현”: design → 중요 경계의 필요한 승인 → implementation.

기존 이름과 Flutter·API·CHGO·품질 모드 호출을 유지한다. 하위 스킬이 없으면 공통 절차에 연결된 references를 사용한다. 외부 스킬은 자체 보호 규칙 아래에서 최소한으로 보조 사용하며 자동 설치하지 않는다. 세부 절차·자료 선택·검증 보고는 references를 따른다.