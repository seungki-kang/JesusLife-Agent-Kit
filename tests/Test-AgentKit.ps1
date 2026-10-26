# Windows PowerShell 5.1, no external dependencies.
$ErrorActionPreference = 'Stop'
$package = Split-Path $PSScriptRoot -Parent
$trial = Join-Path ([IO.Path]::GetTempPath()) ('JesusLife-Test-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory $trial | Out-Null
Write-Host "Evidence: $trial"
function Assert($Condition, $Message) {
  if (-not $Condition) { throw $Message }
  Write-Host "PASS $Message"
}
$actualProfile=$env:USERPROFILE; $actualLocal=$env:LOCALAPPDATA
$utf8 = New-Object Text.UTF8Encoding($true)
$names = @('jesuslife-platform-development','jesuslife-platform-design','jesuslife-platform-implementation')
foreach ($file in Get-ChildItem $package -Recurse -Filter *.ps1) {
  $tokens=$null; $errors=$null
  [Management.Automation.Language.Parser]::ParseFile($file.FullName,[ref]$tokens,[ref]$errors) | Out-Null
  Assert (@($errors).Count -eq 0) "Parser: $($file.Name)"
}
foreach ($file in Get-ChildItem $package -Recurse -Filter *.md) {
  foreach ($m in [regex]::Matches([IO.File]::ReadAllText($file.FullName),'\[[^\]]*\]\(([^)]+)\)')) {
    $link=$m.Groups[1].Value
    if ($link -match '^(https?://|#)') { continue }
    Assert (Test-Path -LiteralPath (Join-Path $file.DirectoryName ($link.Split('#')[0]))) "Link: $($file.Name) -> $link"
  }
}
foreach ($name in $names) {
  $text=[IO.File]::ReadAllText((Join-Path $package "skills\$name\SKILL.md"))
  Assert ($text -match ('(?m)^name: ' + [regex]::Escape($name) + '\r?$')) "Frontmatter: $name"
  Assert ($text -match '(?s)^---\r?\n.*?\r?\n---') "Frontmatter delimiters: $name"
  $front=[regex]::Match($text,'\A---\r?\n(?<front>.*?)\r?\n---',[Text.RegularExpressions.RegexOptions]::Singleline)
  $fields=@($front.Groups['front'].Value -split '\r?\n' | Where-Object { $_.Trim().Length -gt 0 })
  Assert ($fields.Count -eq 2 -and @($fields | Where-Object { $_ -notmatch '^(name|description):\s+\S' }).Count -eq 0 -and @($fields | Where-Object { $_ -match '^description:' }).Count -eq 1) "Only name and description: $name"
  $yaml=[IO.File]::ReadAllText((Join-Path $package "skills\$name\agents\openai.yaml"))
  foreach ($field in @('display_name','short_description','default_prompt')) {
    Assert ($yaml -match ($field + ': "[^"\r\n]+"')) "$name $field"
  }
  Assert ($yaml.Contains('$'+$name)) "Default prompt: $name"
}
$fixture=Join-Path $trial 'package'
New-Item -ItemType Directory $fixture | Out-Null
Copy-Item (Join-Path $package 'Install-JesusLife-Agents.ps1') $fixture
Copy-Item (Join-Path $package 'skills') $fixture -Recurse
Copy-Item (Join-Path $package 'templates') $fixture -Recurse
$profile=Join-Path $trial 'profile'; $local=Join-Path $trial 'local'; $project=Join-Path $trial 'project'
New-Item -ItemType Directory -Path $profile,$local,$project | Out-Null
$runner=Join-Path $trial 'run.ps1'
$runnerText=@'
param($Fixture,$ProfilePath,$LocalPath,$ProjectPath,$Mode)
$env:USERPROFILE=$ProfilePath
$env:LOCALAPPDATA=$LocalPath
$options=@{}
if ($Mode -eq 'replace') { $options.ReplaceExistingAgents=$true; $options.ReplaceExistingSkill=$true }
if ($Mode -eq 'legacy') { $options.MoveLegacySkill=$true }
& (Join-Path $Fixture 'Install-JesusLife-Agents.ps1') -NeorangNarangPath $ProjectPath -LifeDiaryPath '' -ApiPath '' -ChgoPath '' -ChurchOSPath '' -JLBiblePath '' -JLPrayerPath '' -AcademyPath '' @options
exit $LASTEXITCODE
'@
[IO.File]::WriteAllText($runner,$runnerText,$utf8)
function Get-TestTree([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path)) { return '<absent>' }
  $root=(Resolve-Path -LiteralPath $Path).Path
  return (@(Get-ChildItem -LiteralPath $root -Recurse -Force | Sort-Object FullName | ForEach-Object {
    $relative=$_.FullName.Substring($root.Length)
    if ($_.PSIsContainer) { "D|$relative" } else { "F|$relative|$((Get-FileHash -LiteralPath $_.FullName).Hash)" }
  }) -join "`n")
}
function Run-Installer([string]$Mode='normal') {
  $output = & "$PSHOME\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File $runner $fixture $profile $local $project $Mode 2>&1
  $script:lastCode=$LASTEXITCODE
  $script:lastOutput=$output | Out-String -Width 4096
  [IO.File]::WriteAllText((Join-Path $trial ([guid]::NewGuid().ToString('N') + '.log')),$script:lastOutput,$utf8)
}
# v1.5 singleton upgrade uses a separate isolated profile and no real project.
$normalProfile=$profile; $normalLocal=$local; $normalProject=$project
$profile=Join-Path $trial 'v15-profile'; $local=Join-Path $trial 'v15-local'; $project=Join-Path $trial 'v15-project'
New-Item -ItemType Directory -Path $profile,$local,$project | Out-Null
$v15=Join-Path $profile '.agents\skills\jesuslife-platform-development'
New-Item -ItemType Directory -Force $v15 | Out-Null
[IO.File]::WriteAllText((Join-Path $v15 'SKILL.md'),'v1.5 user-owned singleton',$utf8)
$v15Hash=(Get-FileHash (Join-Path $v15 'SKILL.md')).Hash
Run-Installer
Assert ((Get-FileHash (Join-Path $v15 'SKILL.md')).Hash -eq $v15Hash) 'v1.5 singleton preserved without replacement'
foreach ($name in $names | Select-Object -Skip 1) {
  Assert (-not (Test-Path (Join-Path $profile ".agents\skills\$name"))) "No mixed singleton install: $name"
}
Assert ($lastOutput -match 'REVIEW|BLOCKED') 'Singleton upgrade requires explicit replacement'
$oldLegacy=Join-Path $profile '.codex\skills\jesuslife-platform-development'
New-Item -ItemType Directory -Force $oldLegacy | Out-Null
[IO.File]::WriteAllText((Join-Path $oldLegacy 'SKILL.md'),'legacy singleton',$utf8)
Run-Installer legacy
Assert ($lastCode -eq 1 -and $lastOutput -match 'BLOCKED' -and (Test-Path $oldLegacy)) 'REVIEW set blocks legacy move and exits 1'
Run-Installer replace
Assert ($lastCode -eq 0) 'Explicit singleton upgrade succeeds'
foreach ($name in $names) {
  foreach ($file in Get-ChildItem (Join-Path $fixture "skills\$name") -Recurse -File) {
    $relative=$file.FullName.Substring((Join-Path $fixture "skills\$name").Length).TrimStart('\')
    Assert ((Get-FileHash $file.FullName).Hash -eq (Get-FileHash (Join-Path $profile ".agents\skills\$name\$relative")).Hash) "Singleton upgrade matches package: $name/$relative"
  }
}
Assert (@(Get-ChildItem (Join-Path $local 'JesusLife\Temp') -Force).Count -eq 0) 'Singleton upgrade staging cleanup'
$profile=$normalProfile; $local=$normalLocal; $project=$normalProject
Run-Installer
Assert ($lastCode -eq 0 -and ([regex]::Matches($lastOutput,'INSTALLED')).Count -eq 4) 'Initial three skills and AGENTS'
# Normalize table wrapping so complete messages and paths can be checked in redirected output.
$compactOutput=$lastOutput -replace '\s',''
foreach ($name in $names) {
  Assert ($compactOutput.Contains(($name + ' INSTALLED 3종 세트 적용 완료' -replace '\s',''))) "New skill success message: $name"
}
Assert ($lastOutput -notmatch '백업:') 'New installation omits backup label'
Assert ($lastOutput.Contains('3종 스킬 세트를 확인하세요.')) 'Correct completion wording'
Assert (-not $lastOutput.Contains('3종 스킬 세트을 확인하세요.')) 'Old completion typo absent'
foreach ($name in $names) { Assert (Test-Path (Join-Path $profile ".agents\skills\$name\SKILL.md")) "Installed $name" }
Run-Installer
Assert ($lastCode -eq 0 -and ([regex]::Matches($lastOutput,'UNCHANGED')).Count -eq 4) 'Idempotent UNCHANGED'
foreach ($name in $names) { [IO.File]::AppendAllText((Join-Path $profile ".agents\skills\$name\SKILL.md"),"`ncustom",$utf8) }
[IO.File]::AppendAllText((Join-Path $project 'AGENTS.md'),"`ncustom",$utf8)
Run-Installer
Assert ($lastCode -eq 0 -and ([regex]::Matches($lastOutput,'REVIEW')).Count -ge 4) 'Changed REVIEW'
foreach ($name in $names) { Assert ([IO.File]::ReadAllText((Join-Path $profile ".agents\skills\$name\SKILL.md")).Contains('custom')) "Preserved $name" }
Run-Installer replace
Assert ($lastCode -eq 0 -and ([regex]::Matches($lastOutput,'UPDATED')).Count -eq 4) 'Replace agents and skills'
Assert (@(Get-ChildItem (Join-Path $local 'JesusLife\AgentBackups\skills') -Directory).Count -eq 3) 'Three skill backups'
$compactOutput=$lastOutput -replace '\s',''
foreach ($name in $names) {
  $backups=@(Get-ChildItem (Join-Path $local 'JesusLife\AgentBackups\skills') -Directory | Where-Object { $_.Name -like "$name-*" })
  Assert ($backups.Count -eq 1) "Actual replacement backup: $name"
  $expected="$name UPDATED 3종 세트 적용 완료; 백업: $($backups[0].FullName)" -replace '\s',''
  Assert ($compactOutput.Contains($expected)) "Replacement message includes actual backup path: $name"
}
Assert (@(Get-ChildItem (Join-Path $local 'JesusLife\AgentBackups') -Recurse -Filter AGENTS-*.md).Count -eq 1) 'AGENTS backup'
Assert (@(Get-ChildItem (Join-Path $local 'JesusLife\Temp') -Force).Count -eq 0) 'Staging cleanup'
foreach ($name in $names) {
  $legacy=Join-Path $profile ".codex\skills\$name"
  New-Item -ItemType Directory -Force $legacy | Out-Null
  [IO.File]::WriteAllText((Join-Path $legacy 'SKILL.md'),'legacy sentinel',$utf8)
}
Run-Installer
Assert (([regex]::Matches($lastOutput,'REVIEW')).Count -ge 3) 'Legacy warning per skill'
Run-Installer legacy
Assert ($lastCode -eq 0 -and ([regex]::Matches($lastOutput,'MOVED')).Count -eq 3) 'Legacy move per skill'
Assert (@(Get-ChildItem (Join-Path $local 'JesusLife\AgentBackups\legacy-skills') -Directory).Count -eq 3) 'Legacy backups'
Move-Item (Join-Path $fixture 'skills\jesuslife-platform-design') (Join-Path $fixture 'skills\design-disabled')
Run-Installer
Assert ($lastCode -eq 1 -and $lastOutput -match 'FAIL' -and $lastOutput -match 'UNCHANGED') 'Partial failure and exit 1'
# Inject each member's replacement failure in the disposable package only.
Move-Item (Join-Path $fixture 'skills\design-disabled') (Join-Path $fixture 'skills\jesuslife-platform-design')
$installer=Join-Path $fixture 'Install-JesusLife-Agents.ps1'
$original=[IO.File]::ReadAllText($installer)
foreach ($failedName in $names) {
  $before=@{}
  foreach ($name in $names) {
    [IO.File]::AppendAllText((Join-Path $profile ".agents\skills\$name\SKILL.md"),"`nrollback sentinel $failedName",$utf8)
    $before[$name]=Get-TestTree (Join-Path $profile ".agents\skills\$name")
  }
  $injection=@"
function Move-Item {
  param([string]`$LiteralPath,[string]`$Destination)
  if (-not `$script:injected -and `$LiteralPath -like '*Temp*$failedName-*' -and `$Destination -like '*.agents*$failedName') {
    `$script:injected=`$true
    throw 'Injected staging move failure: $failedName'
  }
  Microsoft.PowerShell.Management\Move-Item -LiteralPath `$LiteralPath -Destination `$Destination
}
"@
  [IO.File]::WriteAllText($installer,$original.Replace('$platformSkills=@(',$injection + "`n" + '$platformSkills=@('),$utf8)
  Run-Installer replace
  Assert ($lastCode -eq 1 -and $lastOutput -match 'FAIL' -and $lastOutput.Contains($failedName)) "Named replacement failure exit 1: $failedName"
  foreach ($name in $names) {
    Assert ((Get-TestTree (Join-Path $profile ".agents\skills\$name")) -eq $before[$name]) "Whole set restored after $failedName : $name"
  }
  Assert ($lastOutput -match '복원 성공' -and $lastOutput -match '백업') "Backup and restoration reported: $failedName"
  Assert (@(Get-ChildItem (Join-Path $local 'JesusLife\Temp') -Force).Count -eq 0) "Failure staging cleanup: $failedName"
}
# Failure of the third member must also remove newly installed companions.
$savedProfile=$profile; $savedLocal=$local; $savedProject=$project
foreach ($state in @('empty','singleton')) {
  $profile=Join-Path $trial "$state-failure-profile"
  $local=Join-Path $trial "$state-failure-local"
  $project=Join-Path $trial "$state-failure-project"
  New-Item -ItemType Directory -Path $profile,$local,$project | Out-Null
  if ($state -eq 'singleton') {
    $old=Join-Path $profile '.agents\skills\jesuslife-platform-development'
    New-Item -ItemType Directory -Force $old | Out-Null
    [IO.File]::WriteAllText((Join-Path $old 'SKILL.md'),'v1.5 protected on failure',$utf8)
  }
  $before=@{}
  foreach ($name in $names) { $before[$name]=Get-TestTree (Join-Path $profile ".agents\skills\$name") }
  # $injection from the preceding loop fails implementation, after two applied members.
  [IO.File]::WriteAllText($installer,$original.Replace('$platformSkills=@(',$injection + "`n" + '$platformSkills=@('),$utf8)
  Run-Installer replace
  Assert ($lastCode -eq 1) "$state install failure exits 1"
  foreach ($name in $names) {
    Assert ((Get-TestTree (Join-Path $profile ".agents\skills\$name")) -eq $before[$name]) "$state original presence and content restored: $name"
  }
  Assert (@(Get-ChildItem (Join-Path $local 'JesusLife\Temp') -Force).Count -eq 0) "$state failure staging cleanup"
}
$profile=$savedProfile; $local=$savedLocal; $project=$savedProject
[IO.File]::WriteAllText($installer,$original,$utf8)
# Parent environment remains untouched; all installer invocations override paths in children.
Assert ($env:USERPROFILE -eq $actualProfile -and $env:LOCALAPPDATA -eq $actualLocal) 'Parent USERPROFILE and LOCALAPPDATA unchanged'
Assert ($profile.StartsWith($trial) -and $local.StartsWith($trial) -and $project.StartsWith($trial)) 'All installer targets inside isolated trial'
Write-Host 'PASS isolated regression suite (PowerShell 5.1)'
Write-Host 'NOT_RUN PowerShell 7; live discovery; Mutex contention'
