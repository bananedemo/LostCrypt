[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Server,

    [int]$Port = 58765,

    [string]$Connect = '127.0.0.1:8080',

    [Parameter(Mandatory)]
    [string]$KeyPath,

    [switch]$UpdateConfig = $false
)

Set-StrictMode -Version 3
$ErrorActionPreference = 'Stop'

$acl = Get-Acl -Path $KeyPath
$acl.SetAccessRuleProtection($true, $false)
$acl.Access | ForEach-Object { $acl.RemoveAccessRule($_) }
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule -ArgumentList $acl.Owner, 'Read', 'Allow'
$acl.AddAccessRule($ace)
Set-Acl -Path $KeyPath -AclObject $acl
Get-Acl -Path $KeyPath | Format-List *

$ArgumentList = @(
    $Server,
    '-v',
    '-i', $KeyPath,
    '-L', "${Port}:${Connect}",
    '-o', 'ExitOnForwardFailure=yes',
    '-o', 'StrictHostKeyChecking=accept-new',
    '-N'
)

$proc = Start-Process -PassThru -NoNewWindow -FilePath ssh -ArgumentList $ArgumentList

foreach ($i in 0..9) {
    Write-Verbose "Waiting for the tunnel open ($i)"
    $t = Test-NetConnection 127.0.0.1 -Port $Port
    if ($t.TcpTestSucceeded) {
        break
    }
    if ($proc.HasExited -or $i -eq 9) {
        Stop-Process $proc -ea 0
        throw "Unable to open the tunnel"
    }
    Start-Sleep -Seconds 1
}

$config = @"
{
    "licensingServiceBaseUrl": "http://127.0.0.1:${Port}",
    "enableEntitlementLicensing": true,
    "enableFloatingApi": true,
    "clientConnectTimeoutSec": 5,
    "clientHandshakeTimeoutSec": 10
}
"@

if ($UpdateConfig) {
    mkdir C:\ProgramData\Unity\config -ea 0 | Out-Null
    $config | Set-Content -Path C:\ProgramData\Unity\config\services-config.json
}
