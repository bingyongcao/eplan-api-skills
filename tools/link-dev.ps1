[CmdletBinding()]
param(
    [ValidateSet('Claude', 'Codex', 'Both')]
    [string]$Target = 'Both',
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$source = (Resolve-Path -LiteralPath (Join-Path $repositoryRoot 'plugins\eplan-api\skills\eplan-api')).Path
$profileRoot = [Environment]::GetFolderPath('UserProfile')
$destinations = [System.Collections.Generic.List[string]]::new()

if ($Target -in @('Claude', 'Both')) {
    $destinations.Add((Join-Path $profileRoot '.claude\skills\eplan-api'))
}
if ($Target -in @('Codex', 'Both')) {
    $destinations.Add((Join-Path $profileRoot '.agents\skills\eplan-api'))
}

foreach ($destination in $destinations) {
    if (Test-Path -LiteralPath $destination) {
        if (-not $Force) {
            throw "Destination exists: $destination. Pass -Force to replace this exact path."
        }
        Remove-Item -LiteralPath $destination -Recurse -Force
    }
    $parent = Split-Path -Parent $destination
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent | Out-Null
    }
    New-Item -ItemType Junction -Path $destination -Target $source | Out-Null
    Write-Output "Linked $destination -> $source"
}
