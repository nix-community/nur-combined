# Semantic Commit Rules

## Format

```text
<type>(<scope>)<[!] optional breaking change>: <subject>

<body>

<footer>
```

## Types

- **feat**: New functionality for the end-user.
- **fix**: Resolving a bug or error.
- **docs**: Changes to documentation only.
- **style**: Formatting, white-space, or linting (no logic changes).
- **refactor**: Rewriting code without changing behavior or fixing bugs.
- **perf**: Code changes that specifically improve performance.
- **test**: Adding, updating, or fixing test suites.
- **build**: Changes to build systems or external dependencies (e.g., `.csproj`, `pubspec.yaml`).
- **ci**: Updates to CI/CD pipelines and scripts (e.g., GitHub Actions).
- **chore**: General maintenance (e.g., updating `metainfo.xml`, `.gitignore`).
- **revert**: Rolling back a previous commit.

## Scope

- **Priority 1:** The feature name located in the `features/` directory (e.g., `(login)`, `(dashboard)`).
- **Priority 2:** The specific architectural layer or module (e.g., `(api)`, `(ui)`, `(data)`).

## Breaking Changes

- **Indicator:** Append a `!` after the type/scope to signal a breaking change (e.g., `feat(auth)!: rewrite login logic`).
- **Footer:** Use `BREAKING CHANGE: <description>` in the footer for detailed migration notes.

## Constraints

- **Subject:** Max 50 chars, imperative tense ("add" not "added"), lowercase, no trailing period.
- **Body:** Optional, wrap at 72 chars. Focus on **why** rather than **how**.

## Examples

- `feat(auth): add biometric login support`
- `fix(onboarding): resolve overflow in registration form`
- `feat(api)!: migrate to .NET 11 minimal APIs`
- `chore(flatpak): update screenshots in metainfo.xml`
- `refactor(database): extract repository pattern for user entity`

## Execution

Analyze diffs to determine the primary intent. Prioritize `feat` > `fix` > `refactor` > `chore`. Output only the commit message in a code block.
