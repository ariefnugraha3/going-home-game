param(
    [string]$Godot = 'D:\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
)
$projectRoot = Split-Path $PSScriptRoot -Parent
& $Godot --path $projectRoot -- --dev-tools
exit $LASTEXITCODE
