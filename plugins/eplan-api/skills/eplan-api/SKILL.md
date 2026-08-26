---
name: eplan-api
description: Build, modify, and review EPLAN add-ins, including IEplAddIn lifecycle code and IEplAction commands. Use for EPLAN project-data operations. Do not use for EPLAN scripts or ordinary .NET work unrelated to EPLAN.
---

# EPLAN API

Develop against the EPLAN Platform P8 API.

## Follow the workflow

1. Identify the requested outcome.
2. Inspect the target repository for existing `*Utility` classes, especially the `EplanUtilities`
   namespace. Search method declarations and call sites before writing direct EPLAN API access.
3. Prefer composing existing Utility methods when they already cover the required read or write.
4. When no Utility directly covers the task, generalize from the closest verified Utility pattern.
   Keep project conventions, but verify every newly introduced EPLAN type and member.
5. Establish evidence for EPLAN API symbols in this order:
   - existing Utility declarations and working call sites in the target repository;
   - user-provided code or documentation for the target version;
   - installed EPLAN XML documentation and assemblies;
   - the [official EPLAN Platform API 2026 documentation](https://www.eplan.help/en-us/Infoportal/Content/api/2026/index.html);
   - the general patterns in this skill.
6. Read only the references relevant to the task.
7. Implement the smallest coherent change. Preserve repository conventions when modifying an
   existing solution.

## Route to references

- Read [coding-rules.md](references/coding-rules.md) before writing, modifying, or reviewing code.
  Apply these defaults where the target repository does not define a conflicting convention.
- Read [utility-first.md](references/utility-first.md) before accessing EPLAN data in a repository
  that contains the supplied Utility family. Use its method catalog and composition order.
- Read [project-setup.md](references/project-setup.md) before building a new add-in project from scratch.
- Read [api-fundamentals.md](references/api-fundamentals.md) before writing, modifying, or reviewing code.

## Use bundled tools

Run tools from any working directory; they resolve bundled content relative to `$PSScriptRoot`.
The scaffold copies all seven sources from `assets/utilities/` into the generated project's
`Utilities/` directory and references their verified EPLAN 2026 unified assembly dependencies.

```powershell
& "<skill>/scripts/detect-eplan.ps1" -AsJson
& "<skill>/scripts/validate-environment.ps1" -AsJson
& "<skill>/scripts/scaffold-project.ps1" -ProjectName Example.EplAddIn.Tools -OutputPath . `
  -ActionName ExampleAction
```

Use `scaffold-project.ps1` only for new Add-in projects. Modify existing project files directly
after inspecting their conventions. The scaffold generates both `EplanAddIn : IEplAddIn` and
`EplanAction : IEplAction`, copies the seven bundled EPLAN 2026.0.3 unified assemblies into the
project's `DLLs/` directory, and references them with relative paths. Registered action names must
not contain dots. Generated assembly names must match `*.EplAddIn.*`.
