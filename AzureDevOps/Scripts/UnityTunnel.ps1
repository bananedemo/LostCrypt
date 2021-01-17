[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Server,
    [Parameter(Mandatory)][int]$Port = 58765,
    [Parameter(Mandatory)][string]$Connect = '127.0.0.1:8080',
    [Parameter(Mandatory)][string]$KeyPath
)

Set-StrictMode -Version 3
$ErrorActionPreference = 'Stop'

$ArgumentList = @(
    $Server,
    '-i', $KeyPath,
    '-L', "${Port}:${Connect}",
    '-o', 'ExitOnForwardFailure=yes',
    '-o', 'StrictHostKeyChecking=accept-new',
    '-N'
)

Start-Process -NoNewWindow -FilePath ssh -ArgumentList $ArgumentList
