# Flutter·SQLite 구현

대상 경로·브랜치·git status와 미커밋 diff, AGENTS.md, pubspec.yaml, DI·테스트 구조를 확인한다. 화면 → 상태/모델 → 저장소 계약 → 구현 → SQLite/API → 테스트를 추적한다.
UI가 SQLite·서버 구현에 직접 의존하지 않게 하고 기존 계약·초안 지속성을 보존한다. 저장 성공 전에 완료를 표시하지 않는다. 오프라인, 재시도, 중복 완료, 뒤로가기, 앱 재시작, 초안 복원을 고려한다.
최소 변경을 적용하고 구조 변경과 기능 변경을 섞지 않는다. 사용자 기록·서명은 보존하며 삭제는 복구 보관함을 우선한다.
DB 구조 변경은 AUTHOR_REVIEW_REQUIRED로 보고한다. migration 적용 전 승인·백업·복구 계획을 확인하고 합성 DB로 새 설치·기존 버전 업그레이드·실패 복구를 검증한다.
프로젝트 명령을 우선하여 format 검사, flutter analyze, 관련 테스트, 전체 flutter test, 필요한 빌드를 실행한다. 도구가 없으면 NOT_RUN과 이유를 기록한다.