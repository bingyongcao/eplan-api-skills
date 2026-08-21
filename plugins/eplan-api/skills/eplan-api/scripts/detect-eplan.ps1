[CmdletBinding()]
param(
    [string[]]$SearchRoot,
    [switch]$AsJson
)

$ErrorActionPreference = 'Stop'
$roots = [System.Collections.Generic.List[string]]::new()

if ($SearchRoot) {
    foreach ($root in $SearchRoot) {
        if (Test-Path -LiteralPath $root -PathType Container) {
            $roots.Add((Resolve-Path -LiteralPath $root).Path)
        }
    }
} else {
    foreach ($base in @(
        [Environment]::GetFolderPath('ProgramFiles'),
        [Environment]::GetFolderPath('ProgramFilesX86')
    )) {
        if (-not [string]::IsNullOrWhiteSpace($base)) {
            $candidate = Join-Path $base 'EPLAN'
            if (Test-Path -LiteralPath $candidate -PathType Container) {
                $roots.Add($candidate)
            }
        }
    }
}

$seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$installations = [System.Collections.Generic.List[object]]::new()

foreach ($root in $roots) {
    $baseAssemblies = Get-ChildItem -LiteralPath $root -Filter 'Eplan.EplApi.Base*.dll' -File -Recurse -ErrorAction SilentlyContinue |
        Where-Object Name -in @('Eplan.EplApi.Base.dll', 'Eplan.EplApi.Baseu.dll')
    foreach ($assembly in $baseAssemblies) {
        if (-not $seen.Add($assembly.FullName)) { continue }

        $directory = $assembly.Directory.FullName
        $isUnified = $assembly.Name -eq 'Eplan.EplApi.Baseu.dll'
        $applicationFrameworkName = if ($isUnified) { 'Eplan.EplApi.AFu.dll' } else { 'Eplan.EplApi.ApplicationFramework.dll' }
        $applicationFramework = Join-Path $directory $applicationFrameworkName
        $xmlDocumentation = [System.IO.Path]::ChangeExtension($assembly.FullName, '.xml')
        $versionInfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($assembly.FullName)

        $installations.Add([pscustomobject]@{
            SearchRoot = $root
            AssemblyDirectory = $directory
            BaseAssembly = $assembly.FullName
            AssemblyProfile = if ($isUnified) { 'Unified' } else { 'Legacy' }
            ApplicationFrameworkAssembly = if (Test-Path -LiteralPath $applicationFramework) { $applicationFramework } else { $null }
            XmlDocumentation = if (Test-Path -LiteralPath $xmlDocumentation) { $xmlDocumentation } else { $null }
            FileVersion = $versionInfo.FileVersion
            ProductVersion = $versionInfo.ProductVersion
        })
    }
}

$ordered = @($installations | Sort-Object FileVersion, AssemblyDirectory -Descending)
if ($AsJson) {
    ConvertTo-Json -InputObject $ordered -Depth 4
} else {
    $ordered
}
