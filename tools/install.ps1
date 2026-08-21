[CmdletBinding()]
param(
    [ValidateSet('Claude', 'Codex', 'Both')]
    [string]$Target = 'Both',
    [ValidateSet('User', 'Project')]
    [string]$Scope = 'User',
    [string]$ProjectRoot,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$source = Join-Path $repositoryRoot 'plugins\eplan-api\skills\eplan-api'
if (-not (Test-Path -LiteralPath (Join-Path $source 'SKILL.md') -PathType Leaf)) {
    throw "Canonical skill was not found: $source"
}

if ($Scope -eq 'Project') {
    if (-not $ProjectRoot) { throw '-ProjectRoot is required for project-scoped installation.' }
    if (-not (Test-Path -LiteralPath $ProjectRoot -PathType Container)) {
        throw "Project root does not exist: $ProjectRoot"
    }
    $scopeRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
} else {
    $scopeRoot = [Environment]::GetFolderPath('UserProfile')
}

$destinations = [System.Collections.Generic.List[string]]::new()
if ($Target -in @('Claude', 'Both')) {
    $destinations.Add((Join-Path $scopeRoot '.claude\skills\eplan-api'))
}
if ($Target -in @('Codex', 'Both')) {
    $destinations.Add((Join-Path $scopeRoot '.agents\skills\eplan-api'))
}

foreach ($destination in $destinations) {
    if (Test-Path -LiteralPath $destination) {
        if (-not $Force) {
            throw "Destination exists: $destination. Pass -Force to replace this exact skill folder."
        }
        Remove-Item -LiteralPath $destination -Recurse -Force
    }
    $parent = Split-Path -Parent $destination
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent | Out-Null
    }
    Copy-Item -LiteralPath $source -Destination $destination -Recurse
    Write-Output "Installed eplan-api at $destination"
}
