[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('action', 'addin')]
    [string]$Type,
    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Za-z_][A-Za-z0-9_.-]*$')]
    [string]$ProjectName,
    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Za-z_][A-Za-z0-9_]*$')]
    [string]$ClassName,
    [Parameter(Mandatory)]
    [string]$AssemblyDirectory,
    [Parameter(Mandatory)]
    [string]$OutputPath,
    [string]$TargetFramework = 'net48',
    [string]$RootNamespace,
    [string]$ActionName,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $AssemblyDirectory -PathType Container)) {
    throw "Assembly directory does not exist: $AssemblyDirectory"
}
$resolvedAssemblyDirectory = (Resolve-Path -LiteralPath $AssemblyDirectory).Path
$requiredAssemblies = @(
    'Eplan.EplApi.AFu.dll',
    'Eplan.EplApi.Baseu.dll',
    'Eplan.EplApi.DataModelu.dll',
    'Eplan.EplApi.Guiu.dll',
    'Eplan.EplApi.HEServicesu.dll',
    'Eplan.EplApi.MasterDatau.dll'
)
foreach ($requiredAssembly in $requiredAssemblies) {
    if (-not (Test-Path -LiteralPath (Join-Path $resolvedAssemblyDirectory $requiredAssembly) -PathType Leaf)) {
        throw "Required EPLAN API assembly was not found: $requiredAssembly"
    }
}

if (-not (Test-Path -LiteralPath $OutputPath -PathType Container)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}
$resolvedOutput = (Resolve-Path -LiteralPath $OutputPath).Path
$destination = Join-Path $resolvedOutput $ProjectName
if (Test-Path -LiteralPath $destination) {
    if (-not $Force) {
        throw "Destination already exists: $destination. Pass -Force to replace this exact scaffold directory."
    }
    Remove-Item -LiteralPath $destination -Recurse -Force
}

$templateRoot = Join-Path (Join-Path $PSScriptRoot '..\assets\templates') $Type
if (-not (Test-Path -LiteralPath $templateRoot -PathType Container)) {
    throw "Bundled template was not found: $templateRoot"
}
$utilityRoot = Join-Path $PSScriptRoot '..\assets\utilities'
if (-not (Test-Path -LiteralPath $utilityRoot -PathType Container)) {
    throw "Bundled Utility sources were not found: $utilityRoot"
}
$utilitySources = @(Get-ChildItem -LiteralPath $utilityRoot -Filter '*Utility.cs' -File | Sort-Object Name)
if ($utilitySources.Count -ne 7) {
    throw "Expected 7 bundled Utility sources but found $($utilitySources.Count): $utilityRoot"
}

$namespace = if ($RootNamespace) { $RootNamespace } else { $ProjectName -replace '-', '_' }
$registeredActionName = if ($ActionName) { $ActionName } else { "$namespace.$ClassName" }
$tokens = [ordered]@{
    '__PROJECT_NAME__' = $ProjectName
    '__ROOT_NAMESPACE__' = $namespace
    '__CLASS_NAME__' = $ClassName
    '__ACTION_NAME__' = $registeredActionName
    '__TARGET_FRAMEWORK__' = $TargetFramework
    '__EPLAN_API_DIR__' = $resolvedAssemblyDirectory
}

New-Item -ItemType Directory -Path $destination | Out-Null
Get-ChildItem -LiteralPath $templateRoot -File -Recurse | ForEach-Object {
    $relative = [System.IO.Path]::GetRelativePath($templateRoot, $_.FullName)
    if ($relative.EndsWith('.template', [System.StringComparison]::OrdinalIgnoreCase)) {
        $relative = $relative.Substring(0, $relative.Length - '.template'.Length)
    }
    $relative = $relative.Replace('__PROJECT_NAME__', $ProjectName)
    $outputFile = Join-Path $destination $relative
    $outputDirectory = Split-Path -Parent $outputFile
    if (-not (Test-Path -LiteralPath $outputDirectory)) {
        New-Item -ItemType Directory -Path $outputDirectory | Out-Null
    }
    $content = Get-Content -Raw -LiteralPath $_.FullName
    foreach ($token in $tokens.Keys) { $content = $content.Replace($token, $tokens[$token]) }
    Set-Content -LiteralPath $outputFile -Value $content -Encoding utf8NoBOM
}

$utilityDestination = Join-Path $destination 'Utilities'
New-Item -ItemType Directory -Path $utilityDestination | Out-Null
foreach ($utilitySource in $utilitySources) {
    $utilityOutput = Join-Path $utilityDestination $utilitySource.Name
    $utilityContent = Get-Content -Raw -LiteralPath $utilitySource.FullName
    Set-Content -LiteralPath $utilityOutput -Value $utilityContent -Encoding utf8NoBOM
}

[pscustomobject]@{
    Type = $Type
    ProjectDirectory = $destination
    ProjectFile = Join-Path $destination "$ProjectName.csproj"
    TargetFramework = $TargetFramework
    AssemblyDirectory = $resolvedAssemblyDirectory
    UtilityFiles = @($utilitySources.Name)
    RequiresTargetVersionVerification = $true
}
