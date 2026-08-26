# Project setup

## Choose the project shape

For EPLAN Platform 2026 add-ins following the verified production-project shape, use a legacy
MSBuild C# library targeting .NET Framework 4.8.1:

```xml
<PropertyGroup>
  <OutputType>Library</OutputType>
  <TargetFrameworkVersion>v4.8.1</TargetFrameworkVersion>
  <LangVersion>9.0</LangVersion>
  <Deterministic>true</Deterministic>
</PropertyGroup>
```

Do not replace this with an SDK-style project or a modern .NET target as an incidental cleanup.
Use the Visual Studio MSBuild toolchain that supports .NET Framework, legacy WPF markup compilation,
and the selected language version.

The bundled scaffold creates a minimal new Add-in containing an `IEplAddIn` lifecycle class and an
`IEplAction` command class. It copies its pinned EPLAN API assemblies into the generated project's
`DLLs/` directory; do not assume that its SDK-style layout can replace a working legacy project.

Name an add-in assembly using the `*.EplAddIn.*` convention, with non-empty segments on both sides
of `EplAddIn` (for example, `Company.EplAddIn.PageTools`). Registered EPLAN action names must not
contain dots; use an undotted name such as `Company_PageTools_Open`.

Define each action name once on its `IEplAction` class as `public static string ActionName`. Use
that field both in `OnRegister` and wherever the add-in adds the command to a menu or ribbon group,
for example `group.AddCommand(buttonName, ActionClass.ActionName)`. Do not repeat the registered
action-name string in the add-in class.

Create persistent ribbon commands in `IEplAddIn.OnRegister`, and remove the owned custom tab in
`OnUnregister`. Set `loadOnStart = true` so the add-in is loaded in later EPLAN sessions. Clean the
owned custom tab before recreating it to avoid stale or duplicate ribbon entries. Keep `OnInitGui`
for UI work that must wait until the loaded add-in's user interface is initialized; do not duplicate
persistent ribbon registration there. Avoid modal success messages during registration and
unregistration.

## EPLAN references and WPF

Reference one verified EPLAN 2026 unified assembly set. The scaffold bundles `AFu`, `Baseu`,
`DataModelu`, `Guiu`, `HEServicesu`, `MasterDatau`, and `Starteru` version 2026.0.3 and uses
relative `DLLs/` hint paths. Set EPLAN-owned references to `Private=False`; keep the bundled set
together, and do not mix installation versions or unified and legacy assemblies.

For WPF, include only the required framework references and declare XAML pages with
`Generator=MSBuild:Compile`. A typical .NET Framework 4.8.1 add-in needs `PresentationCore`,
`PresentationFramework`, `System.Xaml`, and `WindowsBase`.

## Build configurations

Maintain two configurations with different purposes.

### Debug

- Generate full symbols and disable optimization.
- Define `DEBUG;TRACE`.
- Do not sign or run the external signing post-build step.
- Build to `bin\Debug\` and launch EPLAN as the external debugger program.

### Release (signing)

- Enable optimization, emit PDB-only symbols, and define `TRACE`.
- Build to `bin\Release\`.
- Enable strong-name signing with the approved public key and the delay-sign setting required by
  the EPLAN signing workflow.
- Run the EADN signing script only after a successful Release build. Replace the unsigned assembly
  with the returned signed artifact only after the signing service reports success.
- Never commit an EADN access token in the project, script, or command line. Resolve it from a
  protected environment variable, secret store, or untracked local MSBuild property, and fail the
  signing build clearly when it is absent.

Representative legacy project groups:

```xml
<PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug|AnyCPU'">
  <DebugSymbols>true</DebugSymbols>
  <DebugType>full</DebugType>
  <Optimize>false</Optimize>
  <OutputPath>bin\Debug\</OutputPath>
  <DefineConstants>DEBUG;TRACE</DefineConstants>
  <SignAssembly>false</SignAssembly>
</PropertyGroup>

<PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Release|AnyCPU'">
  <DebugType>pdbonly</DebugType>
  <Optimize>true</Optimize>
  <OutputPath>bin\Release\</OutputPath>
  <DefineConstants>TRACE</DefineConstants>
  <SignAssembly>true</SignAssembly>
  <AssemblyOriginatorKeyFile>Company_Public.snk</AssemblyOriginatorKeyFile>
  <DelaySign>true</DelaySign>
  <PostBuildEvent />
</PropertyGroup>
```

Build the legacy project with Visual Studio MSBuild, selecting the configuration explicitly:

```powershell
msbuild .\Extension.csproj /restore /p:Configuration=Debug /p:Platform=AnyCPU
msbuild .\Extension.csproj /restore /p:Configuration=Release /p:Platform=AnyCPU
```

Treat Release as an externally mutating operation when its post-build event calls a signing service.
Do not run it merely to check whether ordinary code compiles; use Debug for local verification.

## Start EPLAN for Debug

Keep the executable path and product variant in an untracked `.csproj.user` file because the EPLAN
installation location is machine-specific. For the verified local EPLAN 2026.0.3 installation:

```xml
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<Project ToolsVersion="15.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug|AnyCPU'">
    <StartAction>Program</StartAction>
    <StartProgram>D:\Eplan\Platform\2026.0.3\Bin\EPLAN.exe</StartProgram>
    <StartArguments>/Variant:"Electric P8"</StartArguments>
  </PropertyGroup>
</Project>
```

Starting EPLAN is separate from deploying or registering the add-in. Do not copy build output into
the EPLAN `Bin` directory. Use the target release's supported add-in registration and deployment
mechanism, and keep a rollback copy before replacing an installed extension.

## Build and deployment checks

Before building, verify package restore, .NET Framework 4.8.1 developer targeting support, the
selected MSBuild instance, EPLAN assembly version, configuration, and output directory. Separate
compile, WPF markup-compile, signing-service, EPLAN load, and runtime failures in diagnostics.
