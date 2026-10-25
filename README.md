# JesusLife 자동 스킬 적용 패키지 v1.4

각 프로젝트 최상위 폴더에 맞춤형 `AGENTS.md`를 설치하고, 공통 `jesuslife-platform-development` 스킬을 사용자 Codex 스킬 폴더에 설치한다.

## 개선 사항

- Windows PowerShell 5.1을 위해 설치 스크립트를 UTF-8 BOM으로 제공한다.
- 모든 기본 경로를 실행 매개변수로 바꿀 수 있다.
- `VibeCodeing` 철자가 실제 폴더명과 다르면 올바른 경로를 직접 지정할 수 있다.
- 통합 스킬을 패키지에 포함하고 공식 개인 스킬 경로인 `%USERPROFILE%\.agents\skills`에 설치한다.
- 기존 `AGENTS.md`는 기본적으로 덮어쓰지 않는다.
- `AGENTS.md`와 통합 스킬은 같은 내용이면 백업이나 복사를 하지 않는다.
- 기존 통합 스킬이 다르면 기본적으로 `REVIEW`로 표시하며, 승인된 옵션으로만 교체한다.
- 스킬 교체 시 기존 폴더 전체를 저장소 밖으로 이동한 후 새 폴더를 넣어 오래된 파일이 남지 않게 한다.
- 스킬 교체용 임시 폴더는 Codex 스킬 검색 경로 밖에 만들고, 성공·실패 여부와 관계없이 정리한다.
- 이전 경로 `%USERPROFILE%\.codex\skills`의 중복 스킬을 매번 `REVIEW`로 알리고, 승인된 옵션으로만 백업 이동한다.
- 새 스킬 설치와 원본 복원이 모두 실패하면 수동 복구용 백업 위치를 결과에 표시한다.
- 새 스킬 이동이 중간에 끊겨 일부만 생긴 폴더가 있어도 이를 정리한 뒤 원본을 복원하며, 실제로 복원한 경우에만 "복원되었습니다"라고 표시한다.
- `-MoveLegacySkill`은 이번 실행의 통합 스킬 결과가 `INSTALLED`, `UPDATED`, `UNCHANGED`일 때만 이전 스킬을 이동한다.
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

통합 스킬만 업데이트하려면 다음처럼 실행한다.

```powershell
.\Install-JesusLife-Agents.ps1 -ReplaceExistingSkill
```

`AGENTS.md`와 통합 스킬을 모두 업데이트하려면 두 옵션을 함께 사용한다.

```powershell
.\Install-JesusLife-Agents.ps1 -ReplaceExistingAgents -ReplaceExistingSkill
```

이전 버전이 사용하던 `%USERPROFILE%\.codex\skills`에 같은 스킬이 있으면 기본 실행 때마다 `REVIEW`가 표시된다. `/skills`에서 중복 여부를 확인한 후 이전 스킬을 저장소 밖으로 백업 이동하려면 다음처럼 실행한다.

```powershell
.\Install-JesusLife-Agents.ps1 -MoveLegacySkill
```

이 옵션은 이전 스킬을 삭제하지 않고 다음 백업 폴더로 이동한다. 이동에 실패하면 이전 스킬을 그대로 보존하고 `FAIL`을 표시한다. 같은 실행에서 통합 스킬 결과가 `REVIEW` 또는 `FAIL`이면 이전 스킬을 옮기지 않고 `BLOCKED`로 표시한다. 이 경우 통합 스킬 문제를 먼저 해결한다(예: `-ReplaceExistingSkill -MoveLegacySkill`).

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
| `REVIEW` | 기존 `AGENTS.md`나 통합 스킬이 패키지와 달라 자동 교체하지 않음, 또는 이전 경로에 중복 가능 스킬이 있음 |
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

통합 스킬 확인:

```powershell
Get-ChildItem "$env:USERPROFILE\.agents\skills\jesuslife-platform-development"
```

Codex CLI 또는 IDE에서 다음 명령으로 실제 인식 여부를 확인한다.

```text
/skills
```

목록에 보이지 않으면 Codex를 다시 시작한다. 같은 이름의 스킬이 두 번 보이거나 설치 결과에 `이전 경로 스킬 REVIEW`가 나오면 내용을 확인한 뒤 `-MoveLegacySkill`을 사용한다. 이전 경로의 스킬은 명시적인 옵션 없이 자동 삭제하거나 이동하지 않는다.

새 `AGENTS.md`가 `?? AGENTS.md`로 보이는 것은 정상이다. 내용 확인 후 프로젝트별 Git 정책에 따라 별도 브랜치에서 커밋한다.

