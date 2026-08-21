# Debugging

## Classify the failure

Separate restore/compiler errors, reference/framework mismatch, extension discovery/registration,
assembly loading, licensing/runtime initialization, lifecycle callback exceptions, and project-data
locking failures.

## Collect evidence

Record the selected EPLAN executable and build, referenced DLL paths and file versions, target
framework, CPU architecture, output path, loader/log output, and complete exception including inner
exceptions.

## Debug safely

Build before launching or attaching. Use a disposable project for writes. Attach to the correct
EPLAN process only when interactive debugging is requested. Avoid breakpoints in fragile startup
callbacks when they could cause loader timeouts.

Add narrow logging at registration, initialization, action entry, transaction boundaries, and
shutdown. Never log customer project content by default.
