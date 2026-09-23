param(
    [string]$Godot = 'D:\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe',
    [switch]$Visual,
    [ValidateSet('Story', 'Practice', 'Input', 'Narrative', 'All')][string]$Suite = 'All',
    [switch]$StoryDebug,
    [ValidateSet(30, 60)][int]$FixedFps = 60
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$testStorage = Join-Path $projectRoot '.godot-test'
New-Item -ItemType Directory -Force -Path $testStorage | Out-Null
$previousAppData = $env:APPDATA
try {
    # Keep test saves entirely separate from the player's real journey.
    $env:APPDATA = $testStorage
    & $Godot --headless --path $projectRoot --editor --import --quit --log-file (Join-Path $testStorage 'import.log')
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    if (Select-String -Path (Join-Path $testStorage 'import.log') -Pattern 'SCRIPT ERROR:|Parse Error:|Compile Error:' -Quiet) { exit 1 }
    $scenes = @()
    if ($Suite -in @('Story', 'All')) { $scenes += 'TestRunner' }
    if ($Suite -in @('Practice', 'All')) { $scenes += 'PracticeTests' }
    if ($Suite -in @('Input', 'All')) { $scenes += 'InputTests' }
    if ($Suite -in @('Narrative', 'All')) { $scenes += 'NarrativeTests' }
    foreach ($scene in $scenes) {
        $logPath = Join-Path $testStorage ($scene + '.log')
        $testArgs = @('--path', $projectRoot, '--log-file', $logPath, '--quit-after', '60000')
        if (-not $Visual) { $testArgs += @('--headless', '--fixed-fps', [string]$FixedFps) }
        $testArgs += ('res://tests/' + $scene + '.tscn')
        $testArgs += '--'
        if ($Visual) { $testArgs += '--visual' }
        if ($StoryDebug) { $testArgs += '--story-debug' }
        if ($FixedFps -eq 30) { $testArgs += '--limit-30' }
        & $Godot @testArgs
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        if (Select-String -Path $logPath -Pattern 'SCRIPT ERROR:|Parse Error:|Compile Error:|FAIL:' -Quiet) { exit 1 }
        if (-not (Select-String -Path $logPath -Pattern 'RESULT: \d+ checks, 0 failures' -Quiet)) { exit 1 }
    }
    exit 0
} finally {
    $env:APPDATA = $previousAppData
}
