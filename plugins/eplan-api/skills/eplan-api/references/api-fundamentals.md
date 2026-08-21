# API fundamentals

## Verify symbols

Before writing direct EPLAN access, inspect existing Utility declarations and call sites. Reuse or
compose them when they already cover the operation. If no Utility covers the required member, use
the procedure in `official-api-verification.md`, then corroborate with target-version XML
documentation, installed samples, or assembly metadata. Match the full namespace, signature,
return type, and lifecycle requirements. A similarly named member from another EPLAN release is not
sufficient evidence.

## Respect runtime context

Determine whether code is loaded by EPLAN, invoked as an action, or hosted through a documented
offline/application framework. Many useful objects depend on EPLAN runtime initialization and
cannot be treated as ordinary standalone .NET libraries.

## Manage EPLAN objects deliberately

Check target-version documentation for validity, initialization, locking, write access,
transaction/undo requirements, disposal, thread affinity, and licensing. Do not cache EPLAN data
objects across lifecycle boundaries unless documentation confirms it is safe.

## Work with properties

Prefer `PropertyUtility.GetValueString` for display-oriented conversion already supported by
the project. Use verified property identifiers and value representations. Never copy or extrapolate
numeric property IDs from a nearby Utility method. When a property is unclear, request its
documented identifier or verify it in the EPLAN 2026 documentation and same-version evidence.
