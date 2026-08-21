[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$plugin = Join-Path $repo 'plugins\eplan-api'
$skill = Join-Path $plugin 'skills\eplan-api'
$failures = [System.Collections.Generic.List[string]]::new()

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { $script:failures.Add($Message) }
}

foreach ($jsonPath in @(
    (Join-Path $plugin '.codex-plugin\plugin.json'),
    (Join-Path $plugin '.claude-plugin\plugin.json'),
    (Join-Path $repo '.agents\plugins\marketplace.json'),
    (Join-Path $repo '.claude-plugin\marketplace.json')
)) {
    try { Get-Content -Raw -LiteralPath $jsonPath | ConvertFrom-Json | Out-Null }
    catch { $failures.Add("Invalid JSON: $jsonPath - $($_.Exception.Message)") }
}

$skillText = Get-Content -Raw -LiteralPath (Join-Path $skill 'SKILL.md')
Assert-True ($skillText -match '(?s)^---\s*name:\s*eplan-api\s*description:\s*.+?\s*---') 'SKILL.md frontmatter is invalid.'
Assert-True ($skillText -notmatch '\[TODO|TODO:') 'A TODO placeholder remains in SKILL.md.'
Assert-True ($skillText.Split("`n").Count -lt 500) 'SKILL.md exceeds 500 lines.'
Assert-True ($skillText -match 'utility-first\.md') 'SKILL.md does not route EPLAN data access through utility-first.md.'
Assert-True ($skillText -match 'official-api-verification\.md') 'SKILL.md does not route uncovered APIs through official verification.'
Assert-True ($skillText -match [regex]::Escape('https://www.eplan.help/en-us/Infoportal/Content/api/2026/index.html')) 'SKILL.md does not identify the official EPLAN 2026 API documentation.'

$utilityReference = Join-Path $skill 'references\utility-first.md'
$officialReference = Join-Path $skill 'references\official-api-verification.md'
$utilityAssetDirectory = Join-Path $skill 'assets\utilities'
Assert-True (Test-Path -LiteralPath $utilityReference -PathType Leaf) 'Utility-first reference is missing.'
Assert-True (Test-Path -LiteralPath $officialReference -PathType Leaf) 'Official API verification reference is missing.'
Assert-True (Test-Path -LiteralPath $utilityAssetDirectory -PathType Container) 'Bundled Utility asset directory is missing.'
$utilityText = Get-Content -Raw -LiteralPath $utilityReference
$utilityNames = @('SelectionUtility', 'PageUtility', 'FunctionUtility', 'TextUtility', 'PropertyUtility', 'GuiUtility', 'SettingUtility')
foreach ($utilityName in $utilityNames) {
    Assert-True ($utilityText -match [regex]::Escape($utilityName)) "Utility catalog is missing $utilityName."
    Assert-True (Test-Path -LiteralPath (Join-Path $utilityAssetDirectory "$utilityName.cs") -PathType Leaf) "Bundled source is missing $utilityName.cs."
}
Assert-True (@(Get-ChildItem -LiteralPath $utilityAssetDirectory -Filter '*Utility.cs' -File).Count -eq 7) 'Bundled Utility source count is not 7.'

Get-ChildItem -LiteralPath $repo -Filter '*.ps1' -File -Recurse | ForEach-Object {
    $tokens = $null
    $errors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$tokens, [ref]$errors) | Out-Null
    foreach ($error in $errors) { $failures.Add("$($_.FullName): $($error.Message)") }
}

$temp = Join-Path ([System.IO.Path]::GetTempPath()) ("eplan-api-skill-test-" + [guid]::NewGuid().ToString('N'))
try {
    $fakeBin = Join-Path $temp 'EPLAN\Platform\Bin'
    New-Item -ItemType Directory -Path $fakeBin | Out-Null
    foreach ($assemblyName in @(
        'Eplan.EplApi.AFu.dll',
        'Eplan.EplApi.Baseu.dll',
        'Eplan.EplApi.DataModelu.dll',
        'Eplan.EplApi.Guiu.dll',
        'Eplan.EplApi.HEServicesu.dll',
        'Eplan.EplApi.MasterDatau.dll'
    )) {
        New-Item -ItemType File -Path (Join-Path $fakeBin $assemblyName) | Out-Null
    }

    $detect = Join-Path $skill 'scripts\detect-eplan.ps1'
    $detected = @((& $detect -SearchRoot (Join-Path $temp 'EPLAN') -AsJson) | ConvertFrom-Json)
    Assert-True ($detected.Count -eq 1) 'Synthetic EPLAN installation was not detected exactly once.'

    $scaffold = Join-Path $skill 'scripts\scaffold-project.ps1'
    $output = Join-Path $temp 'output'
    New-Item -ItemType Directory -Path $output | Out-Null
    $action = & $scaffold -Type action -ProjectName Sample.Action -ClassName SampleAction -AssemblyDirectory $fakeBin -OutputPath $output
    Assert-True (Test-Path -LiteralPath $action.ProjectFile -PathType Leaf) 'Action project was not scaffolded.'
    Assert-True (Test-Path -LiteralPath (Join-Path $action.ProjectDirectory 'Action.cs') -PathType Leaf) 'Action source was not scaffolded.'
    Assert-True ($action.UtilityFiles.Count -eq 7) 'Action scaffold did not report 7 Utility files.'
    $addin = & $scaffold -Type addin -ProjectName Sample.AddIn -ClassName SampleAddIn -AssemblyDirectory $fakeBin -OutputPath $output
    Assert-True (Test-Path -LiteralPath $addin.ProjectFile -PathType Leaf) 'Add-in project was not scaffolded.'
    Assert-True (Test-Path -LiteralPath (Join-Path $addin.ProjectDirectory 'AddIn.cs') -PathType Leaf) 'Add-in source was not scaffolded.'

    foreach ($projectDirectory in @($action.ProjectDirectory, $addin.ProjectDirectory)) {
        foreach ($utilityName in $utilityNames) {
            $generatedUtility = Join-Path $projectDirectory "Utilities\$utilityName.cs"
            Assert-True (Test-Path -LiteralPath $generatedUtility -PathType Leaf) "$utilityName.cs was not included in $projectDirectory."
            if (Test-Path -LiteralPath $generatedUtility -PathType Leaf) {
                $assetText = (Get-Content -Raw -LiteralPath (Join-Path $utilityAssetDirectory "$utilityName.cs")) -replace "`r`n", "`n"
                $generatedText = (Get-Content -Raw -LiteralPath $generatedUtility) -replace "`r`n", "`n"
                Assert-True ($assetText.TrimEnd() -ceq $generatedText.TrimEnd()) "$utilityName.cs changed while scaffolding."
            }
        }
        $projectText = Get-Content -Raw -LiteralPath (Join-Path $projectDirectory ((Split-Path -Leaf $projectDirectory) + '.csproj'))
        foreach ($assemblyName in @('AFu', 'Baseu', 'DataModelu', 'Guiu', 'HEServicesu', 'MasterDatau')) {
            Assert-True ($projectText -match [regex]::Escape("Eplan.EplApi.$assemblyName.dll")) "Generated project is missing Eplan.EplApi.$assemblyName.dll."
        }
    }

    $generated = Get-ChildItem -LiteralPath $output -File -Recurse | ForEach-Object { Get-Content -Raw -LiteralPath $_.FullName }
    Assert-True (-not ($generated -match '__[A-Z_]+__')) 'A template token remains in generated output.'

    $installRoot = Join-Path $temp 'install-target'
    New-Item -ItemType Directory -Path $installRoot | Out-Null
    & (Join-Path $repo 'tools\install.ps1') -Target Both -Scope Project -ProjectRoot $installRoot | Out-Null
    foreach ($installedSkill in @(
        (Join-Path $installRoot '.agents\skills\eplan-api'),
        (Join-Path $installRoot '.claude\skills\eplan-api')
    )) {
        foreach ($utilityName in $utilityNames) {
            Assert-True (Test-Path -LiteralPath (Join-Path $installedSkill "assets\utilities\$utilityName.cs") -PathType Leaf) "$utilityName.cs was not included in the installed skill at $installedSkill."
        }
    }
}
finally {
    if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ -ErrorAction Continue }
    throw "Validation failed with $($failures.Count) issue(s)."
}

Write-Output 'All repository validation checks passed.'
