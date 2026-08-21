# Project data

## Start read-only

For pages, functions, devices, placements, connections, or properties, first implement read-only
enumeration that confirms selection and identity. Log stable identifiers and human-readable names
before introducing mutation.

Use the supplied Utility family first:

- obtain the working page through `SelectionUtility.GetWorkingPage`;
- find pages through `PageUtility.GetPages`;
- find functions or terminal strips through the relevant `FunctionUtility` method;
- convert displayed properties through `PropertyUtility.GetValueString`.

Combine these methods at the call site instead of rebuilding `SelectionSet`, `PagesFilter`,
`FunctionsFilter`, `*PropertyList`, or `DMObjectsFinder` queries.

## Bound the operation

Define the target project, selection/filter criteria, expected object count, missing/duplicate
behavior, graphical or topology effects, and rollback/verification criteria. Do not assume displayed
labels are unique keys.

## Mutate safely

Read `transactions-and-safety.md` before writing. Acquire required locks through verified APIs,
make the smallest change set, and validate resulting counts and values. Keep graphical and logical
changes consistent where EPLAN distinguishes them.

Prefer `TextUtility.CreateText`, `FunctionUtility.CreateSubFunc`, `CreateDevice`,
`GetOrCreateTerminalStrips`, `CreateTerminalStrip`, and
`RemoveAllTerminalStripPlacement` when they match the requested mutation. Preserve established
ordering constraints, such as setting names before symbol variants, but do not generalize an
ordering rule to unrelated objects without official verification.

If a required member or property identifier cannot be verified for the selected version, stop at
pseudocode or a clearly marked integration point rather than fabricating compilable code.
