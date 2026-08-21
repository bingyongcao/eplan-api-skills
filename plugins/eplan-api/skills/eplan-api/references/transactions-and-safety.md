# Transactions and safety

## Before mutation

Require an explicit target project, user authorization, a recoverable backup/test copy, verified
locking and transaction APIs, and a bounded selection with expected change count. If any condition
is missing, continue read-only or produce code that is not executed.

## During mutation

Use the EPLAN-supported transaction and locking sequence for the target version. Do not approximate
it with filesystem copying, generic database transactions, or exception swallowing. Validate object
state before each write and fail closed when selection differs from expectations.

A `-Force` flag may authorize replacing a generated scaffold directory; it never authorizes
modifying an EPLAN project.

## After mutation

Commit only after validation passes. On failure, use documented rollback/undo behavior and report
whether rollback was verified. Re-read changed values and summarize counts, identities, and warnings
without unnecessarily exposing proprietary project data.
