# EPLAN Development Coding Rules

Apply these defaults when the target repository does not define a conflicting convention. Preserve
the existing project's framework, language version, architecture, and style unless the task requires
a deliberate migration.

## Common rules

### Naming conventions

| Element | Convention | Example |
|---------|------------|---------|
| Classes and records | PascalCase | `PageService`, `ProjectSnapshot` |
| Interfaces | `I` + PascalCase | `IProjectService` |
| Methods and properties | PascalCase | `GetPageByName`, `IsProjectOpen` |
| Events | PascalCase | `ProjectChanged` |
| Instance fields | `m_` + PascalCase | `m_ProjectService` |
| Static fields | `s_` + PascalCase | `s_DefaultConfiguration` |
| Constants | SCREAMING_SNAKE_CASE | `DEFAULT_TIMEOUT` |
| Local variables and parameters | camelCase | `pageName`, `project` |

### Formatting

- Use Allman braces for types and methods.
- Use spaces consistently, keep lines under 120 characters when practical, and separate logical
  sections with a single blank line.
- Keep related functionality together and keep methods small and focused.
- Follow the existing repository's formatter and analyzer configuration when present.

### Architecture and quality

- Give each type one clear responsibility and prefer composition over inheritance.
- Use constructor injection for required dependencies. Do not add a dependency-injection container
  solely to construct a small EPLAN extension.
- Introduce interfaces at real boundaries or test seams, not for every class.
- Validate inputs and required EPLAN state early; never silently swallow exceptions.
- Keep code testable by separating decision logic from EPLAN runtime calls.
- Add comments for non-obvious EPLAN lifecycle constraints and complex algorithms, not for syntax.
- Measure before optimizing. Avoid unnecessary allocations only on demonstrated hot paths.

## C# and EPLAN API boundaries

- Prefer existing `EplanUtilities` methods before direct EPLAN API calls. Keep raw calls behind a
  focused service or adapter when they are shared by UI and non-UI code.
- Keep `IEplAction.Execute` and add-in lifecycle callbacks small, deterministic, and
  exception-safe. Delegate substantive work to testable classes.
- Treat EPLAN objects as runtime-bound resources. Do not cache them beyond their documented
  lifetime, expose them broadly through view models, or use them from arbitrary worker threads.
- Verify the required EPLAN execution context before moving work off the UI thread. Marshal UI
  updates through the WPF dispatcher, and do not assume EPLAN API calls are thread-safe.
- Use `IDisposable` or an explicit lifecycle method for owned subscriptions and resources. Unhook
  events during the corresponding add-in, view, or view-model shutdown path.
- Avoid `async void` except for UI event handlers. Surface asynchronous failures and cancellation;
  do not block the UI thread with `.Wait()` or `.Result`.
- Catch exceptions to add useful context and report
  them through the project's established logging or EPLAN error presentation. Do not hide failure.

## MVVM for EPLAN WPF UI

Use MVVM for non-trivial WPF UI with state, commands, validation, or testable interaction logic.
Do not introduce an MVVM framework for an action without UI or a small, self-contained dialog.

### Responsibilities

- **View:** XAML, layout, bindings, visual state, and strictly visual code-behind.
- **View model:** Presentation state, validation, and `ICommand` orchestration. Implement
  `INotifyPropertyChanged` correctly and raise changes only when values actually change.
- **Model/domain:** EPLAN-independent values and business rules where practical.
- **Services/adapters:** EPLAN API access, selection, dialogs, logging, dispatcher access, and
  other host-specific operations.

### Interaction rules

- Do not place project traversal, transactions, or direct EPLAN API calls in XAML code-behind.
- Do not expose mutable EPLAN API objects as bindable state. Map required values to view-model or
  domain objects, then resolve and validate live EPLAN objects inside the service operation.
- Inject services into view models through constructors. Keep design-time data and parameterless
  constructors separate from production dependency resolution when the designer requires them.
- Bind user actions to commands. Use code-behind only for view-specific behavior such as focus,
  window chrome, drag handling, or controls that cannot be expressed cleanly through binding.
- Represent long-running work with busy state, cancellation where meaningful, and disabled command
  re-entry. Keep the UI responsive without moving EPLAN calls to an unverified thread context.
- Perform project mutations only after explicit validation or confirmation appropriate to the
  operation. Refresh presentation state after success; preserve it and report actionable details on
  failure.
- Dispose view models that own subscriptions, cancellation sources, timers, or disposable services,
  and ensure the view or composition root invokes that cleanup.