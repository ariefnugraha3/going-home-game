param(
    [string]$Godot = 'D:\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe',
    [switch]$Visual
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
    $testArgs = @('--path', $projectRoot, '--log-file', (Join-Path $testStorage 'tests.log'))
    if (-not $Visual) { $testArgs += @('--headless', '--fixed-fps', '60') }
    $testArgs += 'res://tests/TestRunner.tscn'
    if ($Visual) { $testArgs += @('--', '--visual') }
    & $Godot @testArgs
    exit $LASTEXITCODE
} finally {
    $env:APPDATA = $previousAppData
}
