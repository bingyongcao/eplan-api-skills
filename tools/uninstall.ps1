[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateSet('Claude', 'Codex', 'Both')]
    [string]$Target = 'Both',
    [ValidateSet('User', 'Project')]
    [string]$Scope = 'User',
    [string]$ProjectRoot
)

$ErrorActionPreference = 'Stop'

if ($Scope -eq 'Project') {
    if (-not $ProjectRoot) { throw '-ProjectRoot is required for project-scoped uninstallation.' }
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
    if (-not (Test-Path -LiteralPath $destination -PathType Container)) {
        Write-Output "Not installed: $destination"
        continue
    }

    if ($PSCmdlet.ShouldProcess($destination, 'Remove eplan-api skill folder')) {
        Remove-Item -LiteralPath $destination -Recurse -Force
        Write-Output "Uninstalled eplan-api from $destination"
    }
}