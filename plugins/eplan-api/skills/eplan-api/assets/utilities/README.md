# Bundled EPLAN Utilities

These seven C# sources are copied into every add-in scaffold under `Utilities/`:

- `FunctionUtility.cs`
- `GuiUtility.cs`
- `PageUtility.cs`
- `PropertyUtility.cs`
- `SelectionUtility.cs`
- `SettingUtility.cs`
- `TextUtility.cs`

They retain the `EplanUtilities` namespace. Treat them as editable project source after
scaffolding. Prefer composing their existing methods; extend the appropriate Utility when a new
operation belongs at that boundary. APIs not demonstrated by these files still require EPLAN 2026
official-documentation verification.
