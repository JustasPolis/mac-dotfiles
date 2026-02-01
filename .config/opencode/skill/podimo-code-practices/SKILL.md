---
name: podimo-code-practices
description: Podimo iOS coding standards and best practices. Use when implementing new features, writing code, or reviewing colleague's code/PRs. Applies to "implement feature", "add feature", "create", "build", "code review", "review PR", "review code", "check this code", or any Swift/iOS development task.
---

# Podimo iOS Code Practices

Comprehensive coding standards for implementing features and reviewing code at Podimo.

---

## Mode Detection

Determine the mode based on user request:

### Implementation Mode
Triggers: "implement", "add feature", "create", "build", "write code", or any feature development request.

**Workflow:**
1. Apply all practices below while writing code
2. Use reusable components from `PodimoUI`/`PodimoBrandbook`
3. Follow architecture patterns (Navigator, Services, ViewModels)
4. Add localization keys to `Localizable.strings`
5. Create unit tests alongside implementation

### Review Mode
Triggers: "review", "code review", "check code", "PR review", git diff, or colleague's code.

**Workflow:**
1. Read specified files or run `git diff` for changed files
2. Analyze code against all practices below
3. Verify localization keys exist in `Podimo/Resources/Localizations/en.lproj/Localizable.strings`
4. Check for reusable components in `PodimoCore/Sources/PodimoUI/` and `PodimoCore/Sources/PodimoBrandbook/`
5. Verify unit tests exist in `PodimoTests/`
6. Generate review report (see Output Format below)

---

## Coding Practices

### 1. Architecture

| Practice | Severity |
|----------|----------|
| Use constructor injection via init | Warning |
| Avoid `@Injected`, `@LazyInjected` property wrappers | Warning |
| Use Navigator pattern for screen transitions | Warning |
| Prefer composition over inheritance | Warning |
| Feature modules in `Features/` directory (flat structure) | Suggestion |
| Services/Navigators registered as Factory properties in Container | Warning |
| Avoid `.shared` singleton unless shared state is needed | Warning |

### 2. Data Layer

| Practice | Severity |
|----------|----------|
| Apollo queries/mutations must live in Repositories | Warning |
| Services use Repositories, not NetworkService directly | Warning |
| ViewModels use Services, not Repositories directly | Warning |

### 3. Events/Analytics

| Practice | Severity |
|----------|----------|
| Extract events to dedicated `EventsService` classes | Warning |
| VMs/Services use feature EventsService, not raw `EventsProtocol` | Warning |

### 4. Responsibilities

| Practice | Severity |
|----------|----------|
| View logic in ViewModels, not ViewControllers | Warning |
| Navigation logic in Navigators | Warning |
| Events/tracking in EventsServices | Warning |
| DataSource as separate class (not VC extension) | Warning |

### 5. Naming Conventions

| Practice | Severity | Example |
|----------|----------|---------|
| No `kConstantName` prefix | Warning | `kSomeInt` -> `someInt` |
| Boolish names for booleans | Warning | `addHeader` -> `shouldAddHeader`, `formatIPad` -> `isIPadFormatted` |
| Action names for methods | Suggestion | `fetchEpisodes()`, `updateState()` |
| Avoid Swift type shadowing | Warning | `class TextView` -> `class BaseTextView` |

### 6. Protocol Rules

| Practice | Severity |
|----------|----------|
| Services/Repos/Managers/EventsServices: require `// sourcery: AutoMockable` protocol | Warning |
| VCs/VMs/DataSources: avoid protocols (flag if present) | Warning |

Protocol naming (when needed):
- Service -> `Serving` (e.g., `AudioRecommendationServing`)
- Repository -> `Storing` (e.g., `ShowPageStoring`)
- Manager -> `Managing`
- DataSource -> `DataSourcing`

### 7. Class Structure

| Practice | Severity |
|----------|----------|
| Avoid Input/Output ViewModel pattern | Warning |
| `@MainActor` on ViewModels | Warning |
| `@MainActor` on Views | Warning |

### 8. SwiftUI Views

| Practice | Severity |
|----------|----------|
| No logic or state in views - keep dumb | Warning |
| No `@State` for business logic (only UI state like animations) | Warning |
| Use `@StateObject` / `@ObservedObject` for ViewModel | Warning |

### 9. SwiftUI ViewModels

| Practice | Severity |
|----------|----------|
| Must be `ObservableObject` | Warning |
| Minimize `@Published` properties | Warning |
| Derive state from existing published properties when possible | Warning |
| Cache computed results to avoid rerenders | Warning |
| No expensive work in `init()` | Warning |
| No side effects in `init()` (Task, subscriptions, etc.) | Warning |

### 10. Encapsulation

| Practice | Severity |
|----------|----------|
| Avoid exposing mutable properties | Warning |
| Use `private(set)` if external read needed | Warning |

### 11. Design System

| Practice | Severity |
|----------|----------|
| Use `PodimoFonts` - no hardcoded fonts | Warning |
| Use `PodimoColors` - no hardcoded colors | Warning |
| Use `UIConstants.paddingX` - no hardcoded paddings | Warning |
| Check for reusable components in `PodimoBrandbook`/`PodimoUI` | Warning |

### 12. View Constants

Move icon configs, magic numbers, strings to `private enum Constants` at top of view file:

```swift
private enum Constants {
    static let iconConfig: BrandbookButtonImageConfig = .icon("icon.name", .left)
    static let maxCount: Int = 10
}
```

### 13. Localization

| Practice | Severity |
|----------|----------|
| No hardcoded text in views | Critical |
| Use `"key".localized()` pattern | Critical |
| Verify keys exist in `Localizable.strings` | Critical |

### 14. Concurrency

| Practice | Severity |
|----------|----------|
| Prefer Swift concurrency (`async/await`, `Task`, `Actor`) over `DispatchQueue` | Warning |
| Avoid `MainActor.run { }` - extract to `@MainActor` function | Warning |
| No redundant `@MainActor` on functions when class is annotated | Suggestion |

### 15. Thread Safety

| Practice | Severity |
|----------|----------|
| Flag non-thread-safe mutable properties | Critical |
| Use `actor` or `@MainActor` for shared mutable state | Critical |
| Mutable `static var` is unsafe | Critical |

### 16. Realm Thread Safety

| Practice | Severity |
|----------|----------|
| Realm objects must not cross threads | Critical |
| Convert to value types before passing to `Task` | Critical |
| Don't store Realm objects in properties accessed by multiple threads | Critical |
| Use `ThreadSafeReference` or fetch by ID on target thread | Critical |

### 17. Error Handling

| Practice | Severity |
|----------|----------|
| Avoid `try?` that swallows errors | Warning |
| All errors must be caught with `do-catch` or propagated | Warning |
| No empty `catch { }` blocks | Warning |

### 18. Swift Best Practices

| Practice | Severity |
|----------|----------|
| Use `[safe:]` for array access | Critical |
| Implicit returns (no `return` keyword for single expressions) | Suggestion |
| Success case first in Result switches | Suggestion |

### 19. Memory Management

| Practice | Severity |
|----------|----------|
| `[weak self]` in closures that capture self | Warning |
| Weak delegates | Warning |
| Store Combine cancellables in `Set<AnyCancellable>` | Warning |

### 20. Code Safety

| Practice | Severity |
|----------|----------|
| No force unwrap (`!`) | Critical |
| No force cast (`as!`) | Critical |
| No unsafe array subscripting without `[safe:]` | Critical |

### 21. Code Style

| Practice | Severity |
|----------|----------|
| Numbers must have explicit type (`CGFloat`, `Int`) | Warning |
| `@objc` on separate line | Suggestion |
| Follow SwiftLint rules in `.swiftlint.yml` | Warning |

### 22. Testability

| Practice | Severity |
|----------|----------|
| Protocol-based DI for services | Warning |
| `// sourcery: AutoMockable` on protocols | Warning |

### 23. Unit Tests

| Practice | Severity |
|----------|----------|
| Unit tests required for ViewModels | Warning |
| Unit tests required for Services | Warning |
| All cases/branches must be covered | Warning |

---

## Review Output Format

Use this format when in Review Mode:

```
## CODE REVIEW: [File/PR name]

### Summary
- Files reviewed: X
- Issues: X critical, X warnings, X suggestions

---

### Critical Issues

**[Issue title]** - `FileName.swift:LINE`
// Current
[problematic code]

// Should be
[corrected code]

---

### Warnings

**[Issue title]** - `FileName.swift:LINE`
// Current
[problematic code]

// Should be
[corrected code]

---

### Suggestions

**[Issue title]** - `FileName.swift:LINE`
[suggestion details]

---

### Summary by Category

| Category | Status |
|----------|--------|
| Architecture | Good / X issues |
| Naming | Good / X issues |
| ... | ... |

### Recommendations
1. [Priority fixes]
2. [...]

### Missing Tests
- [ ] `FeatureViewModelTests.swift` - test file missing
- [ ] `testFetchData_failure` - error case not tested
```

---

## Severity Legend

| Severity | Meaning |
|----------|---------|
| Critical | Must fix - crashes, memory leaks, thread safety, security |
| Warning | Should fix - bad practices, maintainability issues |
| Suggestion | Nice to have - style, minor improvements |
