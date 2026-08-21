[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ProjectPath,
    [string]$ApiAssemblyDirectory,
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Debug'
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $ProjectPath -PathType Leaf)) {
    throw "Project file does not exist: $ProjectPath"
}
$dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
if (-not $dotnet) { throw 'dotnet CLI was not found on PATH.' }

$arguments = @('build', (Resolve-Path -LiteralPath $ProjectPath).Path, '--configuration', $Configuration)
if ($ApiAssemblyDirectory) {
    if (-not (Test-Path -LiteralPath $ApiAssemblyDirectory -PathType Container)) {
        throw "API assembly directory does not exist: $ApiAssemblyDirectory"
    }
    $resolvedApiDirectory = (Resolve-Path -LiteralPath $ApiAssemblyDirectory).Path
    $arguments += "-p:EplanApiAssemblyDirectory=$resolvedApiDirectory"
}

& $dotnet.Source @arguments
if ($LASTEXITCODE -ne 0) { throw "dotnet build failed with exit code $LASTEXITCODE." }
