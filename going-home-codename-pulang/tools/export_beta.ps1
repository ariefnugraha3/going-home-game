param(
    [ValidateSet('Web', 'Android Debug')][string]$Platform = 'Web',
    [string]$Godot = 'D:\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe',
    [string]$Templates = "$env:APPDATA\Godot\export_templates\4.7.2.stable",
    [string]$AndroidSdk = "$env:LOCALAPPDATA\Android\Sdk",
    [string]$JavaSdk = 'C:\Program Files\Eclipse Adoptium\jdk-21.0.7.6-hotspot'
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$exportHome = Join-Path $projectRoot '.godot-export'
$godotHome = Join-Path $exportHome 'Godot'
$templateTarget = Join-Path $godotHome 'export_templates\4.7.2.stable'
New-Item -ItemType Directory -Force -Path $templateTarget | Out-Null
$templateFiles = if ($Platform -eq 'Web') { @('version.txt') + @(Get-ChildItem -LiteralPath $Templates -Filter 'web*.zip' | ForEach-Object Name) } else { @('version.txt', 'android_debug.apk', 'android_release.apk') }
$templateFiles += 'icudt_godot.dat'
foreach ($name in $templateFiles) {
    $source = Join-Path $Templates $name
    if (-not (Test-Path -LiteralPath $source)) { throw "Missing export template: $source" }
    Copy-Item -LiteralPath $source -Destination (Join-Path $templateTarget $name) -Force
}
# Keep SDK settings and generated debug signing keys separate from the user's editor.
$sdkPath = $AndroidSdk.Replace('\', '/')
$javaPath = $JavaSdk.Replace('\', '/')
$settings = @"
[gd_resource type="EditorSettings" format=3]

[resource]
export/android/android_sdk_path = "$sdkPath"
export/android/java_sdk_path = "$javaPath"
"@
Set-Content -LiteralPath (Join-Path $godotHome 'editor_settings-4.7.tres') -Value $settings -Encoding UTF8
$destination = if ($Platform -eq 'Web') { 'export/web/index.html' } else { 'export/android/pulang-debug.apk' }
New-Item -ItemType Directory -Force -Path (Split-Path (Join-Path $projectRoot $destination) -Parent) | Out-Null
$previousAppData = $env:APPDATA
try {
    $env:APPDATA = $exportHome
    $log = Join-Path $exportHome ('export-' + $Platform.Replace(' ', '-') + '.log')
    & $Godot --headless --path $projectRoot --export-debug $Platform (Join-Path $projectRoot $destination) --log-file $log
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    if (Select-String -LiteralPath $log -Pattern 'SCRIPT ERROR:|Parse Error:|Compile Error:|Export failed' -Quiet) { exit 1 }
    Get-Item -LiteralPath (Join-Path $projectRoot $destination) | Select-Object FullName, Length
} finally {
    $env:APPDATA = $previousAppData
}
