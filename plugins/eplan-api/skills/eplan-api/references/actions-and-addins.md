# Actions and add-ins

## Choose the extension type

Use an action for a named operation invoked on demand. Use an add-in when initialization,
registration, GUI integration, shutdown handling, or persistent session behavior is required.
Confirm target-version interfaces and deployment rules before finalizing either choice.

## Actions

Verify the `IEplAction` contract from the selected installation. Keep registration names stable and
unique. Parse calling-context parameters defensively, keep `Execute` focused, and move substantive
logic to testable classes that do not depend on global state.

The bundled action template contains a commonly used interface shape as a scaffold. Treat its
method signatures as unverified until compiled against the target assemblies.

## Add-ins

Keep lifecycle callbacks small, deterministic, and exception-safe. Do not perform expensive scans
during registration or GUI initialization. Release event subscriptions and owned resources during
the documented exit/unregister phase.

The add-in template contains a minimal commonly used lifecycle shape. Verify callback signatures
and load-on-start behavior for the target EPLAN release.

## Registration and deployment

Use the target release's supported registration/deployment method. Do not invent registry entries,
installation folders, or switches. Record exact manual activation steps remaining after build.
