# Troubleshooting

## Assembly not found or could not load

Resolve every EPLAN reference to one selected installation. Compare file versions, target framework,
architecture, Copy Local behavior, deployment location, and the complete loader exception. Confirm
the extension was built for the running EPLAN release. Do not copy arbitrary EPLAN DLLs beside it.

## API member missing at compile time

Confirm namespace and assembly in target-version documentation. Check whether the example came from
another release. Inspect installed XML docs or metadata, then adapt to the verified signature rather
than adding speculative references.

## Extension is not discovered

Confirm extension type, output assembly, documented registration/deployment method, startup logs,
and target-version requirements. A successful build does not prove registration.

## Project changes fail

Check project selection, object validity, locking, transaction/undo context, licensing, and whether
the current callback permits the operation. Reproduce read-only against a copied project first.

## Discovery finds nothing

Pass an explicit root to `detect-eplan.ps1 -SearchRoot <path>`. Nonstandard installations,
permissions, or product layout changes may fall outside conventional roots.
