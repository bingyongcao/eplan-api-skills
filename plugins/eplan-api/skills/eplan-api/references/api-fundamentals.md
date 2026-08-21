# API fundamentals

Use this reference to choose the correct EPLAN data-model object and navigation path before writing
direct API access. Verify members against the target EPLAN release; the model below summarizes
EPLAN Platform 2026.

## Read the object model correctly

An arrow in an API model usually means “navigate through this member.” It does not necessarily mean
ownership, inheritance, or that changing the returned object automatically persists through the
source object.

```text
Project
|-- Pages[] ------------------------------> Page
|   |-- Functions[] ----------------------> Function
|   |   `-- Connections[] ----------------> Connection
|   |-- AllPlacements[] ------------------> Placement
|   |-- AllGraphicalPlacements[] ---------> GraphicalPlacement
|   `-- TerminalStrips / PlugStrips / PLCs / BoxedDevices
|-- ArticleReferences[] ------------------> ArticleReference --Article
`-- SymbolLibraries[] --------------------> SymbolLibrary --> Symbol --> SymbolVariant

Function / Connection / Project
`-- ArticleReferences[] ------------------> ArticleReference
```

## Distinguish class hierarchy from navigation

Important inheritance paths explain why the same object appears through several APIs:

```text
StorableObject
|-- Placement
|   |-- SymbolReference
|   |   `-- FunctionBase
|   |       `-- Function
|   `-- Group
|       `-- DocumentBase
|           `-- Page
|-- Project
|-- Connection
|-- Article
`-- ArticleReference
```

## Distinguish `Article` from `ArticleReference`

`Eplan.EplApi.DataModel.Article` represents a part stored in the project's internal parts database.
`Eplan.EplApi.DataModel.ArticleReference` represents one assignment of a part to a `Project`,
`Function`, or `Connection`.

## Persist article-reference changes explicitly

`ArticleReference` is a transient/offline object even when returned for a stored owner. Changes made
on it are not committed to the `Project`, `Function`, or `Connection` until `StoreToObject()`
succeeds.

```csharp
ArticleReference articleReference = function.ArticleReferences[0];
articleReference.Count = 2;
articleReference.StoreToObject();
```

For property-list access, prefer a named member on `ArticleReferencePropertyList`; use a numeric
property ID only when no named member exists and the exact ID, value type, index, and write access
are verified.

Prefer the owner's documented add/remove operations, or the existing `FunctionUtility` article
reference methods, instead of reconstructing assignment state at a call site.

## Resolve symbols before creating symbol references

A `SymbolReference` points to a `SymbolVariant`. Creating a function or another compatible symbol
reference generally requires resolving or initializing the correct variant first, then creating the
object on a page with that variant. Verify symbol-library name, symbol name, variant number, and
object compatibility; do not invent them from a visual label.

```csharp
SymbolLibrary library = new SymbolLibrary(project, libraryName);
Symbol symbol = new Symbol(library, symbolName);
var variant = new SymbolVariant();
variant.Initialize(symbol, variantNumber);

var function = new Function();
function.Create(page, variant);
```

Treat this as the verified API shape, not a replacement for `FunctionUtility.CreateDevice` or
`CreateSubFunc` when those utilities already cover the operation.

## Apply a model-first workflow

1. Identify the logical owner: project, page, function, connection, or master-data object.
2. Choose the narrowest verified navigation member or existing Utility method.
3. Confirm whether the returned object is stored, transient, detached, filtered, or inherited.
4. Distinguish array position from EPLAN property index and reference position.
5. Prefer named property-list members over numeric IDs.
6. Verify the required persistence operation and transaction/locking context before writing.
7. Re-read or re-query the owner after the write when confirmation is important.