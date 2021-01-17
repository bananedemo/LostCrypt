[CmdletBinding()]
param(
    [string]$Version,
    [string]$Changeset,
    [string]$ProjectPath = '.',
    [string]$BuildTarget,
    [string]$UnityHubPath = 'C:\Program Files\Unity Hub\Unity Hub.exe',
    [string[]]$UnityModules = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module powershell-yaml

$unityArchiveUri = 'https://unity3d.com/get-unity/download/archive'

if ([string]::IsNullOrWhiteSpace($Version) -or [string]::IsNullOrWhiteSpace($Changeset)) {
    Write-Verbose "Getting Unity version from project path $ProjectPath"
    $versionFile = [io.path]::Combine($ProjectPath, 'ProjectSettings\ProjectVersion.txt')
    if (!(Test-Path $versionFile)) {
        throw "Project path $ProjectPath is not valid" 
    }
    $Version = (Get-Content -Raw $versionFile | ConvertFrom-Yaml)['m_EditorVersion']
    $versionChangesetMap = @{}
    (Invoke-WebRequest -Uri $unityArchiveUri -UseBasicParsing).Links |
    Select-Object -ExpandPropert href -ErrorAction SilentlyContinue |
    Where-Object { $_ -like 'unityhub://*' } |
    ForEach-Object {
        [uri]$uri = $_
        $versionChangesetMap[$uri.Host] = $uri.LocalPath.substring(1)
    }
    $Changeset = $VersionChangesetMap[$Version]
}

if ([string]::IsNullOrWhiteSpace($Version) -or [string]::IsNullOrWhiteSpace($Changeset)) {
    throw "version and changeset is not specified"
}

Write-Host "Target Unity version: $Version ($Changeset)"

Write-Host "Available Unity versions:"
$versions = & $UnityHubPath -- --headless editors --installed | Out-String

Write-Host $versions.Trim()
if (!($versions | Select-String -Pattern $Version)) {
    Write-Host "Installing Unity editor..."
    & $UnityHubPath -- --headless install --version $Version --changeset $Changeset | Out-Default
}

switch ($BuildTarget) {
    "Android" { $UnityModules += @("android") }
    "iOS" { $UnityModules += @("ios") }
}

if ($UnityModules.count -gt 0) {
    Write-Host "Install Unity editor UnityModules..."
    # Unity Hub 2.4.2 unable to install multiple UnityModules at a time
    # https://forum.unity.com/threads/hub-cli-missing-UnityModules.974301/
    foreach ($m in $UnityModules) {
        & $UnityHubPath -- --headless im --version $Version --cm -m $m | Out-Default
    }
}

exit 0
