[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Server,
    [Parameter(Mandatory)][int]$Port = 58765,
    [Parameter(Mandatory)][string]$Connect = '127.0.0.1:8080',
    [Parameter(Mandatory)][string]$KeyPath
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

Start-Process -NoNewWindow -FilePath ssh -ArgumentList $ArgumentList
