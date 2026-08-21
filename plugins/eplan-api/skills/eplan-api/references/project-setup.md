# Project setup

## New projects

Prefer the bundled scaffold for a minimal action or add-in. Supply an explicit API assembly
directory and target framework. The templates deliberately avoid NuGet references to EPLAN-owned
binaries.

Each generated project includes the eight bundled `EplanUtilities` sources under `Utilities/`.
The templates target the EPLAN 2026 unified assembly naming verified by the supplied Utility
project: `Eplan.EplApi.AFu.dll`, `Baseu`, `DataModelu`, `Guiu`, `HEServicesu`, and `MasterDatau`.
Pass the directory containing that complete set. Do not mix unified and legacy assemblies.

The generated project uses an `EplanApiAssemblyDirectory` MSBuild property and `HintPath` entries.
For team repositories, move the machine-specific value into untracked local configuration or pass
it at build time:

```powershell
dotnet build .\Extension.csproj -p:EplanApiAssemblyDirectory="C:\path\to\EPLAN\Bin"
```

## Existing projects

Inspect SDK-style versus legacy format, target framework, platform target, signing, output scripts,
EPLAN reference conventions, and `Directory.Build.*` files before changing anything. Do not replace
a working legacy project format only to modernize it. Avoid mixing EPLAN assembly versions.

## Build and deployment

Build into a normal repository output directory first. Treat copying into an EPLAN installation or
add-in directory as a separate explicit operation. Never overwrite an in-use extension without a
rollback copy and user authorization.
