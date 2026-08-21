[CmdletBinding()]
param(
    [string[]]$SearchRoot,
    [switch]$AsJson
)

$ErrorActionPreference = 'Stop'
$detectedJson = & (Join-Path $PSScriptRoot 'detect-eplan.ps1') -SearchRoot $SearchRoot -AsJson
$installations = @($detectedJson | ConvertFrom-Json)
$dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
$issues = [System.Collections.Generic.List[string]]::new()

if (-not $dotnet) { $issues.Add('dotnet CLI was not found on PATH.') }
if ($installations.Count -eq 0) {
    $issues.Add('No Eplan.EplApi.Baseu.dll or Eplan.EplApi.Base.dll was found. Pass -SearchRoot for a nonstandard installation.')
}
foreach ($installation in $installations) {
    if (-not $installation.ApplicationFrameworkAssembly) {
        $issues.Add("Application framework assembly is missing beside $($installation.BaseAssembly).")
    }
}

$result = [pscustomobject]@{
    Is64BitOperatingSystem = [Environment]::Is64BitOperatingSystem
    Is64BitProcess = [Environment]::Is64BitProcess
    PowerShellVersion = $PSVersionTable.PSVersion.ToString()
    DotnetPath = if ($dotnet) { $dotnet.Source } else { $null }
    Installations = $installations
    Issues = @($issues)
    IsReady = ($dotnet -and $installations.Count -gt 0 -and $issues.Count -eq 0)
}

if ($AsJson) { $result | ConvertTo-Json -Depth 6 } else { $result }
