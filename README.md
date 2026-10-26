# JesusLife 자동 스킬 적용 패키지 v1.5.0-rc.2

각 프로젝트 최상위 폴더에 맞춤형 `AGENTS.md`를 설치하고, 공통 라우터 `jesuslife-platform-development`, 설계 `jesuslife-platform-design`, 개발 `jesuslife-platform-implementation`의 세 스킬을 사용자 Codex 스킬 폴더에 설치한다.

## 개선 사항

- Windows PowerShell 5.1을 위해 설치 스크립트를 UTF-8 BOM으로 제공한다.
- 모든 기본 경로를 실행 매개변수로 바꿀 수 있다.
- `VibeCodeing` 철자가 실제 폴더명과 다르면 올바른 경로를 직접 지정할 수 있다.
- JesusLife 3종 스킬 세트를 패키지에 포함하고 공식 개인 스킬 경로인 `%USERPROFILE%\.agents\skills`에 설치한다.
- 기존 `AGENTS.md`는 기본적으로 덮어쓰지 않는다.
- `AGENTS.md`와 JesusLife 3종 스킬 세트는 같은 내용이면 백업이나 복사를 하지 않는다.
- 기존 JesusLife 3종 스킬 세트가 다르면 기본적으로 `REVIEW`로 표시하며, 승인된 옵션으로만 교체한다.
- 스킬 교체 시 기존 폴더 전체를 저장소 밖으로 이동한 후 새 폴더를 넣어 오래된 파일이 남지 않게 한다.
- 스킬 교체용 임시 폴더는 Codex 스킬 검색 경로 밖에 만들고, 성공·실패 여부와 관계없이 정리한다.
- 이전 경로 `%USERPROFILE%\.codex\skills`의 중복 스킬을 매번 `REVIEW`로 알리고, 승인된 옵션으로만 백업 이동한다.
- 새 스킬 설치와 원본 복원이 모두 실패하면 수동 복구용 백업 위치를 결과에 표시한다.
- 새 스킬 이동이 중간에 끊겨 일부만 생긴 폴더가 있어도 이를 정리한 뒤 원본을 복원하며, 실제로 복원한 경우에만 "복원되었습니다"라고 표시한다.
- `-MoveLegacySkill`은 이번 실행의 JesusLife 3종 스킬 세트 결과가 `INSTALLED`, `UPDATED`, `UNCHANGED`일 때만 이전 스킬을 이동한다.
- `FAIL` 또는 `BLOCKED`가 있으면 종료 코드 1로 끝난다.
- 백업은 Git 저장소 밖 `%LOCALAPPDATA%\JesusLife\AgentBackups`에 저장한다.
- 프로젝트 하나가 실패해도 나머지 설치를 계속하고 마지막에 결과를 요약한다.

## 포함 대상

- 너랑나랑
- 생명일기
- JesusLife API
- CHGO
- ChurchOS
- JLBible
- JLPrayer
- JesusLife Academy

`neorang-narang-dev` 스킬은 이 패키지에 포함하지 않는다. 설치되어 있으면 함께 사용하며, 없어도 `AGENTS.md`에 들어 있는 핵심 보호·검증 규칙은 그대로 적용된다.

## 기본 설치

압축을 푼 폴더에서 PowerShell을 열고 다음 명령을 실행한다.

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\Install-JesusLife-Agents.ps1
```

기본 경로:

```text
D:\CHGO-VibeCodeing\neorang_narang_app
D:\CHGO-VibeCodeing\CHGO-Life-Diary-Flutter
D:\CHGO-VibeCodeing\JesusLife-One-API
D:\CHGO-Platform
```

실제 폴더가 `CHGO-VibeCoding`처럼 다른 철자라면 경로를 지정한다.

```powershell
.\Install-JesusLife-Agents.ps1 `
  -NeorangNarangPath "D:\CHGO-VibeCoding\neorang_narang_app" `
  -LifeDiaryPath "D:\CHGO-VibeCoding\CHGO-Life-Diary-Flutter" `
  -ApiPath "D:\CHGO-VibeCoding\JesusLife-One-API"
```

추가 프로젝트(아래 경로는 **예시**이므로 실제 프로젝트 경로로 바꾸세요):

```powershell
.\Install-JesusLife-Agents.ps1 `
  -ChurchOSPath "D:\JesusLife-Projects\ChurchOS" `
  -JLBiblePath "D:\JesusLife-Projects\JLBible" `
  -JLPrayerPath "D:\JesusLife-Projects\JLPrayer" `
  -AcademyPath "D:\JesusLife-Projects\JesusLife-Academy"
```

## 기존 파일이 있을 때

기본 동작은 기존 `AGENTS.md`를 보존하고 결과를 `REVIEW`로 표시하는 것이다. 기존 내용을 검토한 후 교체하기로 결정했다면 다음 옵션을 사용한다.

```powershell
.\Install-JesusLife-Agents.ps1 -ReplaceExistingAgents
```

JesusLife 3종 스킬 세트만 업데이트하려면 다음처럼 실행한다.

```powershell
.\Install-JesusLife-Agents.ps1 -ReplaceExistingSkill
```

`AGENTS.md`와 JesusLife 3종 스킬 세트를 모두 업데이트하려면 두 옵션을 함께 사용한다.

```powershell
.\Install-JesusLife-Agents.ps1 -ReplaceExistingAgents -ReplaceExistingSkill
```

이전 버전이 사용하던 `%USERPROFILE%\.codex\skills`에 같은 스킬이 있으면 기본 실행 때마다 `REVIEW`가 표시된다. `/skills`에서 중복 여부를 확인한 후 이전 스킬을 저장소 밖으로 백업 이동하려면 다음처럼 실행한다.

```powershell
.\Install-JesusLife-Agents.ps1 -MoveLegacySkill
```

이 옵션은 이전 스킬을 삭제하지 않고 다음 백업 폴더로 이동한다. 이동에 실패하면 이전 스킬을 그대로 보존하고 `FAIL`을 표시한다. 같은 실행에서 JesusLife 3종 스킬 세트 결과가 `REVIEW` 또는 `FAIL`이면 이전 스킬을 옮기지 않고 `BLOCKED`로 표시한다. 이 경우 JesusLife 3종 스킬 세트 문제를 먼저 해결한다(예: `-ReplaceExistingSkill -MoveLegacySkill`).

교체 전 파일은 다음 위치에 백업된다.

```text
%LOCALAPPDATA%\JesusLife\AgentBackups
```

## 결과 상태

| 상태 | 의미 |
|---|---|
| `INSTALLED` | 새로 설치됨 |
| `UPDATED` | 기존 자료를 외부 백업한 뒤 교체됨 |
| `UNCHANGED` | 이미 같은 내용이므로 건너뜀 |
| `REVIEW` | 기존 `AGENTS.md`나 JesusLife 3종 스킬 세트가 패키지와 달라 자동 교체하지 않음, 또는 이전 경로에 중복 가능 스킬이 있음 |
| `MOVED` | 이전 경로의 중복 가능 스킬을 외부 백업 폴더로 이동함 |
| `SKIP` | 경로 미지정 또는 폴더 없음 |
| `BLOCKED` | 안전 조건이 충족되지 않아 변경하지 않고 중단함 |
| `FAIL` | 해당 항목 설치 실패 |

`임시 폴더 정리` 항목이 `FAIL`로 표시되면 스킬 교체용 임시 폴더를 자동으로 지우지 못한 것이다. 메시지에 표시된 `%LOCALAPPDATA%\JesusLife\Temp\...` 폴더를 Codex를 종료한 뒤 직접 삭제한다. 이 폴더는 Codex 스킬 검색 경로 밖에 있으므로 스킬 인식에는 영향을 주지 않는다.

`FAIL` 또는 `BLOCKED`가 하나라도 있으면 스크립트는 종료 코드 1로 끝난다.

## 설치 확인

각 프로젝트 폴더에서 다음을 실행한다.

```powershell
Get-Content .\AGENTS.md -TotalCount 20 -Encoding UTF8
git status --short
```

JesusLife 3종 스킬 세트 확인:

```powershell
Get-ChildItem "$env:USERPROFILE\.agents\skills\jesuslife-platform-development"
```

Codex CLI 또는 IDE에서 다음 명령으로 실제 인식 여부를 확인한다.

```text
/skills
```

목록에 보이지 않으면 Codex를 다시 시작한다. 같은 이름의 스킬이 두 번 보이거나 설치 결과에 `이전 경로 스킬 REVIEW`가 나오면 내용을 확인한 뒤 `-MoveLegacySkill`을 사용한다. 이전 경로의 스킬은 명시적인 옵션 없이 자동 삭제하거나 이동하지 않는다.

새 `AGENTS.md`가 `?? AGENTS.md`로 보이는 것은 정상이다. 내용 확인 후 프로젝트별 Git 정책에 따라 별도 브랜치에서 커밋한다.


## rc.2 구조와 자동 선택

- [공통 라우터](skills/jesuslife-platform-development/SKILL.md): 기존 이름 유지, 공통 보호와 내부 references 대체 절차.
- [design](skills/jesuslife-platform-design/SKILL.md): 기획·경계·흐름·소유권·API 계약 초안·ADR·CHGO 후보·대안·로드맵.
- [implementation](skills/jesuslife-platform-implementation/SKILL.md): Flutter·FastAPI·SQLite·동기화·migration·테스트·빌드·릴리스 검증.

사용자가 스킬 이름을 몰라도 설계·구조·흐름·비교·경계·계약 초안은 design, 구현·수정·추가·오류 해결·DB 변경·API 개발·테스트·빌드는 implementation으로 자동 선택한다. 복합 요청은 설계 → 필요한 승인 → 개발 순서다. 설계만 요청하면 앱 코드와 DB를 변경하지 않는다. 각 템플릿의 고유 보호 규칙은 유지한다.
외부 스킬이나 하위 스킬 설치를 가정하지 않으며 하위 스킬이 없으면 공통 라우터의 references를 사용한다. 신학 문구·Canonical ID·개인정보 공유·DB 구조·인증 경계는 AUTHOR_REVIEW_REQUIRED다.

기존 명령 옵션과 기본 프로젝트 경로를 유지한다. 세 스킬을 하나의 호환 세트로 사전 점검하며 -ReplaceExistingSkill은 전체 세트에 적용한다. 신규 INSTALLED, 동일 UNCHANGED, 차이 REVIEW, 명시적 교체는 외부 백업 후 UPDATED다. staging fingerprint, 실패 복원, 임시폴더 정리, Mutex를 유지한다. 하나라도 교체에 실패하면 실패 스킬을 표시하고 이미 변경한 항목도 실행 전 상태로 복원한다. 백업 위치와 각 복원 결과를 표시하며 프로젝트 처리는 계속한다.
-MoveLegacySkill은 세 이름 각각의 이전 .codex\skills 경로에 적용한다. 해당 공식 스킬이 INSTALLED/UPDATED/UNCHANGED일 때만 검증된 백업으로 이동하며 그 외는 BLOCKED로 보존한다. 기존 설치본은 명시적 교체 없이 덮어쓰지 않는다.

## rc.2 검증

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-AgentKit.ps1
```

외부 의존성 없는 PowerShell 5.1 시험은 임시 시험 폴더에서 자식 프로세스의 USERPROFILE/LOCALAPPDATA와 모든 프로젝트 경로를 격리한다. 실제 사용자 프로젝트나 스킬을 사용하지 않는다. 시험 증거 폴더를 보존하며 경로를 출력한다.
PASS는 실제 성공한 검사, FAIL은 실행 실패, NOT_RUN은 미실행, BLOCKED는 조건 미충족, AUTHOR_REVIEW_REQUIRED는 사람 검토 필요다. 설치 상태 REVIEW/UNCHANGED 등과 구분한다.
PowerShell 7은 설치되어 있지 않아 NOT_RUN이다. PowerShell 5.1 결과는 실제 시험 출력으로 확인한다. Codex 재시작 후 /skills 인식과 실사용 프로젝트 빌드는 별도 검증 대상이다.

“설계하고 구현” 요청은 design을 먼저 수행한다. 신학 문구·Canonical ID·개인정보 공유·DB 구조·인증 경계 등 중요 경계 변경은 AUTHOR_REVIEW_REQUIRED로 표시하고, 필요한 사람의 승인을 받은 뒤 해당 변경의 implementation으로 진행한다. 복합 요청 자체를 중요 경계 변경 승인으로 간주하지 않는다.

불명확하거나 위험한 요청은 파일·코드·DB·설정 등 대상 상태를 변경하지 않고 먼저 사용자에게 질문한다. 불명확한 범위·의도 또는 위험과 필요한 결정을 구체적으로 설명하고, 답변으로 범위와 안전 조건이 확인될 때까지 해당 변경을 보류한다. 확인을 위한 읽기 전용 점검만 수행한다.

작업 시작 전에 적용할 스킬 이름·역할과 수행 순서를 사용자에게 알린다. 예: 공통 라우터 → design → 필요한 승인 → implementation. 직접 하위 스킬을 호출한 경우에도 공통 보호 규칙 적용과 해당 단계의 순서를 알린다. 진행 중 적용 스킬이나 순서가 바뀌면 변경된 작업을 시작하기 전에 다시 알린다. 이 안내를 사용자 승인으로 간주하지 않는다.

외부 스킬은 JesusLife 공통 보호 규칙과 대상 프로젝트 고유 보호 규칙 아래에서, 요청 해결에 필요한 최소 범위에만 보조 사용한다. 실제 설치·가용성과 관련성을 먼저 확인하고 필요한 지침만 읽는다. 외부 스킬의 지침으로 승인 경계·제품 경계·개인정보·신학 원문·사용자 기록 보호를 우회하거나 작업 범위를 확대하지 않는다. 보호 규칙과 충돌하는 외부 지침은 적용하지 않으며 판단이 불명확하거나 위험하면 변경 없이 질문한다. 외부 스킬을 자동 설치하거나 필수 의존성으로 가정하지 않는다.

## 참고자료 소유와 탐색

절차 원본은 하위호환을 위해 공통 라우터의 references에 한 번만 유지한다. 기존 7개 경로를 유지하여 라우터 단독 설치도 지원한다. 설계·개발 스킬에는 본문 복사 대신 역할별 자료 진입점을 둔다.

| 스킬 | 자료 진입점 | 읽기 범위 |
|---|---|---|
| 공통 라우터 | [SKILL.md](skills/jesuslife-platform-development/SKILL.md) | 공통 보호·경계·라우팅, 해당 작업 references |
| design | [references/workflow.md](skills/jesuslife-platform-design/references/workflow.md) | 설계 절차·공통 경계, 필요 시 CHGO 후보 |
| implementation | [references/workflow.md](skills/jesuslife-platform-implementation/references/workflow.md) | 해당 Flutter·API·CHGO 절차와 품질 게이트 |

공통 보호 규칙 변경은 라우터의 references/common-rules.md에서, 세부 절차 변경은 해당 원본 reference에서 관리한다. 역할별 안내는 읽는 시점과 경로만 관리하며 관련 없는 자료를 일괄 로드하지 않는다.

각 SKILL.md는 역할·핵심 보호·자료 진입점만 간결하게 유지한다. 세부 공통 규칙과 라우팅은 [common-rules.md](skills/jesuslife-platform-development/references/common-rules.md), 역할별 자료 선택과 실행 절차는 각 references에서 관리한다.

## v1.5 단일 스킬과 세트 업데이트 호환

기존 v1.5의 `jesuslife-platform-development` 이름과 설치 옵션은 유지한다. 기존 스킬이 하나라도 있고 세 스킬의 파일 트리 전체가 패키지와 일치하지 않으면, 기본 실행은 세 스킬 모두 `REVIEW`로 보존한다. 따라서 구버전 공통 라우터를 남긴 채 신규 설계·개발 스킬만 설치하지 않는다. 기존 단일 스킬 사용자는 내용을 검토한 뒤 `-ReplaceExistingSkill`로 3종 세트를 함께 업데이트한다.

아무 스킬도 없으면 세 스킬을 함께 설치하고, 모두 패키지와 같으면 `UNCHANGED`다. 업데이트는 세 스킬 전체 staging과 fingerprint 검사, 기존 항목 전체의 검증된 백업을 완료한 뒤 시작한다. 실패 시 변경된 항목을 실행 전 상태로 복원하며 원래 없던 항목은 제거한다. 복원 성공은 `BLOCKED`와 복원 메시지로, 복원 실패는 `FAIL`과 수동 복구용 백업 위치로 보고한다. 백업은 복원 후에도 보존한다. 세트가 실패하거나 REVIEW이면 legacy 이동도 보류한다.

이는 정상적인 예외 처리 안에서의 복원이며 강제 프로세스 종료·전원 차단에 대한 원자적 설치를 보장하지 않는다. 설치·복원 후 staging은 정리한다. 백업이나 staging을 다루는 설치자 작업과 Git staging은 별개이며 설치자는 Git 명령을 실행하지 않는다.