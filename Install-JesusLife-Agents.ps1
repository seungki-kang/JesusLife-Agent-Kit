param(
  [string]$NeorangNarangPath = "D:\CHGO-VibeCodeing\neorang_narang_app",
  [string]$LifeDiaryPath = "D:\CHGO-VibeCodeing\CHGO-Life-Diary-Flutter",
  [string]$ApiPath = "D:\CHGO-VibeCodeing\JesusLife-One-API",
  [string]$ChgoPath = "D:\CHGO-Platform",
  [string]$ChurchOSPath = "",
  [string]$JLBiblePath = "",
  [string]$JLPrayerPath = "",
  [string]$AcademyPath = "",
  [switch]$ReplaceExistingAgents,
  [switch]$ReplaceExistingSkill,
  [switch]$MoveLegacySkill
)

$ErrorActionPreference = "Stop"
$installerMutex = [System.Threading.Mutex]::new($false, "Local\JesusLife-Agent-Installer")
$hasInstallerMutex = $false

try {
  try {
    $hasInstallerMutex = $installerMutex.WaitOne(0)
  }
  catch [System.Threading.AbandonedMutexException] {
    $hasInstallerMutex = $true
  }

  if (-not $hasInstallerMutex) {
    Write-Error "JesusLife 설치 프로그램이 이미 실행 중입니다. 기존 실행이 끝난 뒤 다시 시도하세요."
    exit 1
  }

$packageRoot = $PSScriptRoot
$templateRoot = Join-Path $packageRoot "templates"
$skillSource = Join-Path $packageRoot "skills\jesuslife-platform-development"
$skillParent = Join-Path $env:USERPROFILE ".agents\skills"
$skillDestination = Join-Path $skillParent "jesuslife-platform-development"
$legacySkillDestination = Join-Path $env:USERPROFILE ".codex\skills\jesuslife-platform-development"
$backupRoot = Join-Path $env:LOCALAPPDATA "JesusLife\AgentBackups"
$temporaryRoot = Join-Path $env:LOCALAPPDATA "JesusLife\Temp"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$results = [System.Collections.Generic.List[object]]::new()

function Add-Result {
  param([string]$Name, [string]$Status, [string]$Message)
  $results.Add([pscustomobject]@{
      Name = $Name
      Status = $Status
      Message = $Message
    })
}

function Test-SameFile {
  param([string]$Source, [string]$Destination)
  if (-not (Test-Path -LiteralPath $Destination -PathType Leaf)) {
    return $false
  }
  $sourceHash = (Get-FileHash -LiteralPath $Source -Algorithm SHA256).Hash
  $destinationHash = (Get-FileHash -LiteralPath $Destination -Algorithm SHA256).Hash
  return $sourceHash -eq $destinationHash
}

function Get-DirectoryFingerprint {
  param([string]$Path)

  if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
    return $null
  }

  $root = (Resolve-Path -LiteralPath $Path).Path.TrimEnd('\')
  $directoryEntries = foreach ($directory in Get-ChildItem -LiteralPath $root -Directory -Recurse -Force | Sort-Object FullName) {
    $relativePath = $directory.FullName.Substring($root.Length).TrimStart('\')
    "D|$relativePath"
  }

  $fileEntries = foreach ($file in Get-ChildItem -LiteralPath $root -File -Recurse -Force | Sort-Object FullName) {
    $relativePath = $file.FullName.Substring($root.Length).TrimStart('\')
    $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
    "F|$relativePath|$hash"
  }

  $entries = @($directoryEntries) + @($fileEntries)
  $content = $entries -join "`n"
  $sha256 = [System.Security.Cryptography.SHA256]::Create()
  try {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
    $hashBytes = $sha256.ComputeHash($bytes)
    return -join ($hashBytes | ForEach-Object { $_.ToString("x2") })
  }
  finally {
    $sha256.Dispose()
  }
}

# Guard every recursive removal against its intended root.
function Remove-SetPath {
  param([string]$Path, [string]$Root)
  $full=[IO.Path]::GetFullPath($Path)
  $prefix=[IO.Path]::GetFullPath($Root).TrimEnd('\') + '\'
  if (-not $full.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)) {
    throw "정리 대상이 허용 루트 밖입니다: $full"
  }
  if (Test-Path -LiteralPath $full) { Remove-Item -LiteralPath $full -Recurse -Force }
}

function Install-PlatformSkillSet {
  $members=[System.Collections.Generic.List[object]]::new()
  $touched=[System.Collections.Generic.List[object]]::new()
  $stageRoot=$null
  $currentName='JesusLife 3종 스킬 세트'
  $operationId="{0}-{1}" -f $timestamp,([guid]::NewGuid().ToString('N'))
  try {
    # Complete preflight before any skill is changed.
    foreach ($definition in $platformSkills) {
      $currentName=$definition.Id
      $source=Join-Path $packageRoot "skills\$currentName"
      foreach ($required in @('SKILL.md','agents\openai.yaml')) {
        if (-not (Test-Path -LiteralPath (Join-Path $source $required) -PathType Leaf)) {
          throw "번들 파일 없음: $source\$required"
        }
      }
      if ($currentName -eq 'jesuslife-platform-development' -and
          -not (Test-Path -LiteralPath (Join-Path $source 'references\common-rules.md') -PathType Leaf)) {
        throw "공통 보호 규칙 없음: $source"
      }
      $destination=Join-Path $skillParent $currentName
      if ((Test-Path -LiteralPath $destination) -and
          -not (Test-Path -LiteralPath $destination -PathType Container)) {
        throw "공식 스킬 경로가 폴더가 아닙니다: $destination"
      }
      $before=Get-DirectoryFingerprint -Path $destination
      $expected=Get-DirectoryFingerprint -Path $source
      $members.Add([pscustomobject]@{
        Id=$currentName; Source=$source; Destination=$destination
        Before=$before; Expected=$expected; Backup=$null; Stage=$null
      })
    }
    if (@($members | Where-Object { $_.Before -ne $_.Expected }).Count -eq 0) {
      foreach ($member in $members) { Add-Result $member.Id 'UNCHANGED' '3종 모두 패키지와 동일' }
      return
    }
    if (-not $ReplaceExistingSkill -and @($members | Where-Object { $null -ne $_.Before }).Count -gt 0) {
      foreach ($member in $members) {
        Add-Result $member.Id 'REVIEW' '3종 세트 전체 보존. 혼합 설치 방지를 위해 -ReplaceExistingSkill 필요'
      }
      return
    }

    New-Item -ItemType Directory -Force -Path $skillParent,$temporaryRoot | Out-Null
    $stageRoot=Join-Path $temporaryRoot "skill-set-$operationId"
    New-Item -ItemType Directory -Path $stageRoot | Out-Null
    # Stage every member and verify before backing up or replacing anything.
    foreach ($member in $members) {
      $currentName=$member.Id
      $member.Stage=Join-Path $stageRoot "$($member.Id)-$operationId"
      Copy-Item -LiteralPath $member.Source -Destination $member.Stage -Recurse -Force
      if ((Get-DirectoryFingerprint $member.Stage) -ne $member.Expected) {
        throw "staging fingerprint 불일치: $currentName"
      }
    }
    $skillBackupRoot=Join-Path $backupRoot 'skills'
    foreach ($member in $members) {
      $currentName=$member.Id
      if ($null -ne $member.Before) {
        New-Item -ItemType Directory -Force -Path $skillBackupRoot | Out-Null
        $member.Backup=Join-Path $skillBackupRoot "$($member.Id)-$operationId"
        Copy-Item -LiteralPath $member.Destination -Destination $member.Backup -Recurse -Force
        if ((Get-DirectoryFingerprint $member.Backup) -ne $member.Before) {
          throw "기존 스킬 백업 fingerprint 불일치: $currentName; 백업 후보: $($member.Backup)"
        }
      }
    }
    # Refuse to overwrite edits made after preflight.
    foreach ($member in $members) {
      $currentName=$member.Id
      if ((Get-DirectoryFingerprint $member.Destination) -ne $member.Before) {
        throw "사전 점검 후 설치본 변경 감지: $currentName"
      }
    }
    foreach ($member in $members) {
      $currentName=$member.Id
      $touched.Add($member)
      Remove-SetPath $member.Destination $skillParent
      Move-Item -LiteralPath $member.Stage -Destination $member.Destination
      if ((Get-DirectoryFingerprint $member.Destination) -ne $member.Expected) {
        throw "설치 fingerprint 불일치: $currentName"
      }
    }
    # Report success only after all three match the same package.
    foreach ($member in $members) {
      $status=if ($null -eq $member.Before) { 'INSTALLED' } else { 'UPDATED' }
      Add-Result $member.Id $status "3종 세트 적용 완료; 백업: $($member.Backup)"
    }
  }
  catch {
    $failure=$_.Exception.Message
    Add-Result $currentName 'FAIL' "세트 적용 실패: $failure"
    for ($index=$touched.Count-1; $index -ge 0; $index--) {
      $member=$touched[$index]
      try {
        # Never remove the new copy unless the old backup is still valid.
        if ($null -ne $member.Before -and
            (Get-DirectoryFingerprint $member.Backup) -ne $member.Before) {
          throw '백업 없음 또는 fingerprint 불일치; 대상 보존, 수동 복구 필요'
        }
        Remove-SetPath $member.Destination $skillParent
        if ($null -ne $member.Before) {
          Copy-Item -LiteralPath $member.Backup -Destination $member.Destination -Recurse -Force
        }
        if ((Get-DirectoryFingerprint $member.Destination) -ne $member.Before) {
          throw '복원 fingerprint 불일치'
        }
        Add-Result "$($member.Id) 복원" 'BLOCKED' "복원 성공: 실행 전 상태; 백업 보존: $($member.Backup)"
      }
      catch {
        Add-Result "$($member.Id) 복원" 'FAIL' "복원 실패; 수동 복구용 백업: $($member.Backup); $($_.Exception.Message)"
      }
    }
    foreach ($definition in $platformSkills) {
      if ($definition.Id -ne $currentName) {
        Add-Result $definition.Id 'BLOCKED' "세트 적용 실패로 새 버전 적용 취소; 실패 스킬: $currentName"
      }
    }
  }
  finally {
    if ($stageRoot) {
      try { Remove-SetPath $stageRoot $temporaryRoot }
      catch { Add-Result '임시 폴더 정리' 'FAIL' "직접 확인 필요: $stageRoot; $($_.Exception.Message)" }
    }
  }
}
function Resolve-LegacySkill {
  param([string]$OfficialSkillStatus, [string]$SkillName = "jesuslife-platform-development", [string]$ResultName = "이전 경로 스킬")
  $skillDestination = Join-Path $skillParent $SkillName
  $legacySkillDestination = Join-Path $env:USERPROFILE ".codex\skills\$SkillName"

  if (-not (Test-Path -LiteralPath $legacySkillDestination -PathType Container)) {
    return
  }

  if (-not $MoveLegacySkill) {
    Add-Result -Name $ResultName -Status "REVIEW" -Message "중복 인식 가능성 있음: $legacySkillDestination; 확인 후 -MoveLegacySkill 사용"
    return
  }

  $readyStatuses = @("INSTALLED", "UPDATED", "UNCHANGED")
  if ($readyStatuses -notcontains $OfficialSkillStatus) {
    Add-Result -Name $ResultName -Status "BLOCKED" -Message "공식 경로 스킬 상태가 '$OfficialSkillStatus'이므로 이동하지 않음. 3종 스킬 세트 결과를 먼저 해결하세요. 이전 스킬 보존: $legacySkillDestination"
    return
  }

  $officialSkillFile = Join-Path $skillDestination "SKILL.md"
  if (-not (Test-Path -LiteralPath $officialSkillFile -PathType Leaf)) {
    Add-Result -Name $ResultName -Status "BLOCKED" -Message "공식 경로의 스킬 설치를 먼저 확인하세요. 이전 스킬 보존: $legacySkillDestination"
    return
  }

  try {
    $legacyBackupRoot = Join-Path $backupRoot "legacy-skills"
    New-Item -ItemType Directory -Force -Path $legacyBackupRoot | Out-Null
    $operationId = "{0}-{1}" -f $timestamp, ([guid]::NewGuid().ToString("N"))
    $legacyBackup = Join-Path $legacyBackupRoot "$SkillName-$operationId"
    $legacyFingerprint = Get-DirectoryFingerprint -Path $legacySkillDestination
    Copy-Item -LiteralPath $legacySkillDestination -Destination $legacyBackup -Recurse
    if ($legacyFingerprint -ne (Get-DirectoryFingerprint -Path $legacyBackup)) {
      throw "이전 스킬 백업 검증에 실패했습니다. 원본은 제거하지 않았습니다. 백업 후보: $legacyBackup"
    }
    try {
      Remove-Item -LiteralPath $legacySkillDestination -Recurse -Force
    }
    catch {
      throw "검증된 백업은 생성했지만 이전 경로를 완전히 제거하지 못했습니다. 원본과 백업을 모두 확인하세요. 원본: $legacySkillDestination; 백업: $legacyBackup; 제거 오류: $($_.Exception.Message)"
    }
    Add-Result -Name $ResultName -Status "MOVED" -Message "검증된 백업: $legacyBackup"
  }
  catch {
    Add-Result -Name $ResultName -Status "FAIL" -Message $_.Exception.Message
  }
}

function Install-AgentFile {
  param(
    [string]$Name,
    [string]$Path,
    [string]$Template
  )

  if ([string]::IsNullOrWhiteSpace($Path)) {
    Add-Result -Name $Name -Status "SKIP" -Message "경로 미지정"
    return
  }

  if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
    Add-Result -Name $Name -Status "SKIP" -Message "폴더 없음: $Path"
    return
  }

  $source = Join-Path $templateRoot $Template
  $destination = Join-Path $Path "AGENTS.md"
  $stagedFile = $null
  $rollbackFile = $null

  try {
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
      throw "템플릿 없음: $source"
    }

    if (Test-SameFile -Source $source -Destination $destination) {
      Add-Result -Name $Name -Status "UNCHANGED" -Message "이미 최신 상태"
      return
    }

    $destinationExists = Test-Path -LiteralPath $destination -PathType Leaf
    if ($destinationExists -and -not $ReplaceExistingAgents) {
      Add-Result -Name $Name -Status "REVIEW" -Message "기존 AGENTS.md 보존. 교체하려면 -ReplaceExistingAgents 사용"
      return
    }
    if (-not $destinationExists -and (Test-Path -LiteralPath $destination)) {
      throw "AGENTS.md 경로에 파일이 아닌 항목이 있습니다: $destination"
    }

    $operationId = "{0}-{1}" -f $timestamp, ([guid]::NewGuid().ToString("N"))
    $stagedFile = Join-Path $Path ".AGENTS.new-$operationId.md"
    Copy-Item -LiteralPath $source -Destination $stagedFile
    if (-not (Test-SameFile -Source $source -Destination $stagedFile)) {
      throw "AGENTS.md 임시 복사본 검증에 실패했습니다: $stagedFile"
    }

    if ($destinationExists) {
      $safeName = $Name -replace '[\\/:*?"<>|]', '_'
      $projectBackupRoot = Join-Path $backupRoot $safeName
      New-Item -ItemType Directory -Force -Path $projectBackupRoot | Out-Null
      $backup = Join-Path $projectBackupRoot "AGENTS-$operationId.md"
      Copy-Item -LiteralPath $destination -Destination $backup
      if (-not (Test-SameFile -Source $destination -Destination $backup)) {
        throw "기존 AGENTS.md 백업 검증에 실패했습니다. 원본은 변경하지 않았습니다: $backup"
      }

      $rollbackFile = Join-Path $Path ".AGENTS.old-$operationId.md"
      Move-Item -LiteralPath $destination -Destination $rollbackFile
      try {
        Move-Item -LiteralPath $stagedFile -Destination $destination
        $stagedFile = $null
        if (-not (Test-SameFile -Source $source -Destination $destination)) {
          throw "새 AGENTS.md 검증에 실패했습니다."
        }
      }
      catch {
        $replacementError = $_.Exception.Message
        try {
          if (Test-Path -LiteralPath $destination) {
            Remove-Item -LiteralPath $destination -Force
          }
          Move-Item -LiteralPath $rollbackFile -Destination $destination
          $rollbackFile = $null
        }
        catch {
          throw "AGENTS.md 교체 실패: $replacementError; 자동 복원도 실패했습니다. 수동 복구용 백업: $backup; 로컬 복구 후보: $rollbackFile; 복원 오류: $($_.Exception.Message)"
        }
        throw "AGENTS.md 교체 실패: $replacementError; 기존 파일은 복원되었습니다. 백업: $backup"
      }

      try {
        Remove-Item -LiteralPath $rollbackFile -Force
        $rollbackFile = $null
      }
      catch {
        Add-Result -Name "$Name 임시 파일 정리" -Status "FAIL" -Message "새 AGENTS.md는 적용됐지만 직접 삭제가 필요합니다: $rollbackFile; $($_.Exception.Message)"
      }
      Add-Result -Name $Name -Status "UPDATED" -Message "백업: $backup"
      return
    }

    try {
      Move-Item -LiteralPath $stagedFile -Destination $destination
      $stagedFile = $null
      if (-not (Test-SameFile -Source $source -Destination $destination)) {
        throw "설치된 AGENTS.md 검증에 실패했습니다."
      }
    }
    catch {
      $installError = $_.Exception.Message
      if (Test-Path -LiteralPath $destination -PathType Leaf) {
        Remove-Item -LiteralPath $destination -Force
      }
      throw "AGENTS.md 최초 설치 실패: $installError"
    }
    Add-Result -Name $Name -Status "INSTALLED" -Message $destination
  }
  catch {
    Add-Result -Name $Name -Status "FAIL" -Message $_.Exception.Message
  }
  finally {
    if (-not [string]::IsNullOrWhiteSpace($stagedFile) -and
        (Test-Path -LiteralPath $stagedFile -PathType Leaf)) {
      try {
        Remove-Item -LiteralPath $stagedFile -Force
      }
      catch {
        Add-Result -Name "$Name 임시 파일 정리" -Status "FAIL" -Message "직접 삭제 필요: $stagedFile; $($_.Exception.Message)"
      }
    }
  }
}

$platformSkills=@(
  @{ Id='jesuslife-platform-development' },
  @{ Id='jesuslife-platform-design' },
  @{ Id='jesuslife-platform-implementation' }
)
Install-PlatformSkillSet
foreach ($skill in $platformSkills) {
  $officialSkillResult=$results | Where-Object { $_.Name -eq $skill.Id } | Select-Object -Last 1
  $officialSkillStatus=if ($officialSkillResult) { $officialSkillResult.Status } else { 'BLOCKED' }
  Resolve-LegacySkill -OfficialSkillStatus $officialSkillStatus -SkillName $skill.Id -ResultName "$($skill.Id) 이전 경로 스킬"
}
$targets = @(
  @{ Name = "너랑나랑"; Path = $NeorangNarangPath; Template = "neorang-narang.AGENTS.md" },
  @{ Name = "생명일기"; Path = $LifeDiaryPath; Template = "life-diary.AGENTS.md" },
  @{ Name = "JesusLife API"; Path = $ApiPath; Template = "jesuslife-api.AGENTS.md" },
  @{ Name = "CHGO"; Path = $ChgoPath; Template = "chgo.AGENTS.md" },
  @{ Name = "ChurchOS"; Path = $ChurchOSPath; Template = "churchos.AGENTS.md" },
  @{ Name = "JLBible"; Path = $JLBiblePath; Template = "jlbible.AGENTS.md" },
  @{ Name = "JLPrayer"; Path = $JLPrayerPath; Template = "jlprayer.AGENTS.md" },
  @{ Name = "JesusLife Academy"; Path = $AcademyPath; Template = "academy.AGENTS.md" }
)

foreach ($target in $targets) {
  Install-AgentFile -Name $target.Name -Path $target.Path -Template $target.Template
}

Write-Host ""
Write-Host "JesusLife 자동 적용 설치 결과"
$results | Format-Table -AutoSize -Wrap

$hasFail = $results.Status -contains "FAIL"
$hasBlocked = $results.Status -contains "BLOCKED"
$hasReview = $results.Status -contains "REVIEW"

if ($hasFail -or $hasBlocked) {
  if ($hasFail) {
    Write-Warning "일부 항목이 실패했습니다. 실패 항목만 확인한 뒤 다시 실행하세요."
  }
  if ($hasBlocked) {
    Write-Warning "요청한 작업 중 안전 조건 때문에 중단된 항목이 있습니다. BLOCKED 항목의 안내를 확인하세요."
  }
  exit 1
}

if ($hasReview) {
  Write-Warning "검토가 필요한 항목이 있습니다. REVIEW 항목을 확인한 뒤 필요한 옵션으로 다시 실행하세요."
  Write-Host "설치 작업이 끝났지만 검토가 필요한 항목이 남아 있습니다."
}
else {
  Write-Host "설치가 끝났습니다. Codex에서 /skills를 실행하여 3종 스킬 세트을 확인하세요."
}
}
finally {
  if ($hasInstallerMutex) {
    $installerMutex.ReleaseMutex()
  }
  $installerMutex.Dispose()
}

