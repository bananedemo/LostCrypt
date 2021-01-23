[CmdletBinding()]
param(
    [string]$ProjectPath = '.',

    [ValidateSet('Android', 'iOS')]
    [string]$BuildTarget = 'Android',

    [ValidateSet('Development', 'Release')]
    [string]$BuildConfig = 'Development',

    [string]$BuildSettings = 'buildSettings.yml',

    [string]$LogFile = 'Logs/UnityBuild.log',

    [string]$EditorVersion,

    [string]$EditorBasePath = "C:/Program Files/Unity/Hub/Editor",

    [switch]$WaitForLicense = $false
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module powershell-yaml

if ([string]::IsNullOrWhiteSpace($EditorVersion)) {
    Write-Verbose "Getting Unity version from project path $ProjectPath"
    $versionFile = [io.path]::Combine($ProjectPath, 'ProjectSettings\ProjectVersion.txt')
    if (!(Test-Path $versionFile)) {
        throw "Project path $ProjectPath is not valid" 
    }
    $EditorVersion = (Get-Content -Raw $versionFile | ConvertFrom-Yaml)['m_EditorVersion']
}

if ([string]::IsNullOrWhiteSpace($EditorVersion)) {
    throw "Unity version is not specified"
}

# Unity Editor の場所
$EditorPath = [io.path]::Combine($EditorBasePath, $EditorVersion, 'Editor/Unity.exe')
if (!(Test-Path $EditorPath)) {
    throw "Unity editor not found: $EditorPath"
}

# Unity.Licensing.Client の場所
$UnityLicensingClientPath = [io.path]::Combine($EditorBasePath, $EditorVersion, 'Editor/Data/Resources/Licensing/Client/Unity.Licensing.Client.exe')

# フローティングライセンスのリースを待つ
# Unity.Licensing.Client は常に終了コード 0 を返すので標準出力で判断するしかない
if ($WaitForLicense -and (Test-Path $UnityLicensingClientPath)) {
    for ($i = 1; ; $i++) {
        Write-Host "Starting Unity.Licensing.Client (attempt $i)"
        $a = & $UnityLicensingClientPath --acquire-floating
        $a | Out-Host
        if ($a -match '^License lease Created ') {
            break
        }
        Start-Sleep -Seconds 30
    }
}

# Unity Editor の引数
$UnityArgs = @(
    '-quit',
    '-batchmode',
    '-nographics', 
    '-projectPath', $ProjectPath,
    '-buildTarget', $BuildTarget, 
    '-logFile', $LogFile,
    '-executeMethod', 'AppBuilder.Tasks.CommandLineBuild',
    '-config', $BuildConfig,
    '-settings', $BuildSettings
)

# ログファイルおよびディレクトリを作成する
$LogDir = Split-Path -Parent $LogFile
if ($LogDir) { New-Item -ItemType Directory $LogDir -ea 0 | Out-Null }
New-Item -ItemType File $LogFile -ea 0 | Out-Null

# ログファイルを標準出力に送るバックグラウンドプロセス
$logProc = Start-Process -PassThru -NoNewWindow -FilePath powershell.exe -ArgumentList "-command Get-Content -Wait $LogFile"

# Unity Editor 起動
# Start-Process -Wait では子プロセス VBCSCompiler.exe の終了待ちが発生するため $unityProc.HasExited をポーリングして待つ
# https://issuetracker.unity3d.com/issues/roslyn-vbcscompiler-dot-exe-remains-running-after-unity-build-has-finished-when-building-unity-player-in-batch-mode
$unityProc = Start-Process -PassThru -FilePath $EditorPath -ArgumentList $UnityArgs
while (!$unityProc.HasExited) { Start-Sleep 1 }

# ログ出力プロセス終了
Start-Sleep 1
Stop-Process $logProc

exit $unityProc.ExitCode
