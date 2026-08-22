[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Za-z_][A-Za-z0-9_.-]*$')]
    [string]$ProjectName,
    [Parameter(Mandatory)]
    [string]$OutputPath,
    [string]$TargetFramework = 'net481',
    [string]$RootNamespace,
    [string]$ActionName,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$requiredAssemblies = @(
    'Eplan.EplApi.AFu.dll',
    'Eplan.EplApi.Baseu.dll',
    'Eplan.EplApi.DataModelu.dll',
    'Eplan.EplApi.Guiu.dll',
    'Eplan.EplApi.HEServicesu.dll',
    'Eplan.EplApi.MasterDatau.dll',
    'Eplan.EplApi.Starteru.dll'
)
$assemblyAssetRoot = Join-Path $PSScriptRoot '..\assets\DLLs'
if (-not (Test-Path -LiteralPath $assemblyAssetRoot -PathType Container)) {
    throw "Bundled EPLAN API assembly directory was not found: $assemblyAssetRoot"
}
foreach ($requiredAssembly in $requiredAssemblies) {
    if (-not (Test-Path -LiteralPath (Join-Path $assemblyAssetRoot $requiredAssembly) -PathType Leaf)) {
        throw "Bundled EPLAN API assembly was not found: $requiredAssembly"
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

$templateRoot = Join-Path $PSScriptRoot '..\assets\templates\addin'
if (-not (Test-Path -LiteralPath $templateRoot -PathType Container)) {
    throw "Bundled Add-in template was not found: $templateRoot"
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
$registeredActionName = if ($ActionName) { $ActionName } else { "$namespace.EplanAction" }
$tokens = [ordered]@{
    '__PROJECT_NAME__' = $ProjectName
    '__ROOT_NAMESPACE__' = $namespace
    '__ACTION_NAME__' = $registeredActionName
    '__TARGET_FRAMEWORK__' = $TargetFramework
}

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

New-Item -ItemType Directory -Path $destination | Out-Null
$templatePrefix = (Resolve-Path -LiteralPath $templateRoot).Path.TrimEnd('\') + '\'
Get-ChildItem -LiteralPath $templateRoot -File -Recurse | ForEach-Object {
    $relative = $_.FullName.Substring($templatePrefix.Length)
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
    [System.IO.File]::WriteAllText($outputFile, $content, $utf8NoBom)
}

$utilityDestination = Join-Path $destination 'Utilities'
New-Item -ItemType Directory -Path $utilityDestination | Out-Null
foreach ($utilitySource in $utilitySources) {
    $utilityOutput = Join-Path $utilityDestination $utilitySource.Name
    $utilityContent = Get-Content -Raw -LiteralPath $utilitySource.FullName
    [System.IO.File]::WriteAllText($utilityOutput, $utilityContent, $utf8NoBom)
}

$assemblyDestination = Join-Path $destination 'DLLs'
New-Item -ItemType Directory -Path $assemblyDestination | Out-Null
foreach ($requiredAssembly in $requiredAssemblies) {
    Copy-Item -LiteralPath (Join-Path $assemblyAssetRoot $requiredAssembly) -Destination $assemblyDestination
}

[pscustomobject]@{
    Type = 'AddIn'
    ProjectDirectory = $destination
    ProjectFile = Join-Path $destination "$ProjectName.csproj"
    TargetFramework = $TargetFramework
    ActionName = $registeredActionName
    DllFiles = @($requiredAssemblies)
    UtilityFiles = @($utilitySources.Name)
    RequiresTargetVersionVerification = $true
}
