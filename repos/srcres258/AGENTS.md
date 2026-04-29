# AGENTS.md

## Repository Snapshot
- Type: NUR (Nix User Repository) package set.
- Main language: Nix (`*.nix`) plus one helper shell script.
- Key files:
  - `default.nix` (package registry)
  - `ci.nix` (CI build/cache target selection)
  - `flake.nix` (flake outputs)
  - `.github/workflows/build.yml` (canonical CI commands)
- No JS/TS project metadata (`package.json`, `tsconfig`, ESLint, Prettier) is present.

## Policy Files Check
At authoring time, repository does **not** contain:
- `.cursor/rules/`
- `.cursorrules`
- `.github/copilot-instructions.md`
If any appear later, update this file and follow those policies first.

## Build, Test, and Validation Commands
Run commands from repository root.

### 1) Evaluate package set (CI parity)
```bash
nix-env -f . -qa \* --meta --xml \
  --allowed-uris https://static.rust-lang.org \
  --option restrict-eval true \
  --option allow-import-from-derivation true \
  --drv-path --show-trace \
  -I nixpkgs=$(nix-instantiate --find-file nixpkgs) \
  -I $PWD
```
Source: `.github/workflows/build.yml` (`Check evaluation`).

### 2) Build CI-selected outputs
```bash
nix-build ci.nix -A cacheOutputs
```
CI wrapper form:
```bash
nix shell -f '<nixpkgs>' nix-build-uncached -c nix-build-uncached ci.nix -A cacheOutputs
```
Source: `.github/workflows/build.yml` (`Build nix packages`).

### 3) Build a single package (primary local verification)
```bash
nix-build -A <package-attr>
```
Examples:
```bash
nix-build -A ag
nix-build -A jyyslide-util
nix-build -A lceda-pro
```

### 4) Flake-style build
```bash
nix build .#<package-attr>
```
Example: `nix build .#ag`

## "Single Test" Guidance
There is no standalone unit-test runner in this repo.
Use a **single package build** as the narrowest test-equivalent:
```bash
nix-build -A <package-attr>
```
Notes:
- `pkgs/ag/default.nix` and `pkgs/jyyslide-util/default.nix` set `doCheck = true`.
- `pkgs/keystroke/default.nix` sets `doCheck = false` (tests deliberately disabled).
- For packages with `doCheck = true`, checks execute during build.

## CI Behavior
- Runs on PR, push to main/master, cron (daily at 08:00 UTC), and manual trigger.
- Matrix tests against **3 nixpkgs channels**: `nixpkgs-unstable`, `nixos-unstable`, `nixos-25.05`.
- Steps: evaluate → build cacheable outputs → trigger NUR update webhook.
- Uses **Cachix** for binary caching: cache name `nur-packages-srcres258`.

## Lint/Format Status
No dedicated repo-level lint/format command is defined.
- No `statix`, `deadnix`, or formatter config is wired in CI.
- CI contract is currently: evaluation + build/cache outputs.

## Recommended Agent Workflow
1. Edit only relevant files (usually `pkgs/<name>/default.nix`).
2. Run evaluation command.
3. Run `nix-build -A <changed-attr>` for each touched package.
4. If changing shared plumbing (`default.nix`, `ci.nix`, overlays, flake), also run:
   - `nix-build ci.nix -A cacheOutputs`

## Code Style Guidelines (Evidence-Based)
Derived from `default.nix`, `ci.nix`, `overlay.nix`, and `pkgs/*/default.nix`.

### Structure and organization
- One package per directory: `pkgs/<name>/default.nix`.
- Export package attrs in root `default.nix` via `pkgs.callPackage`.
- Keep special attrs reserved: `lib`, `modules`, `overlays`.
Pattern:
```nix
<attr> = pkgs.callPackage ./pkgs/<dir> {
  inherit maintainers;
};
```

### Naming conventions
- Root attrs are kebab-case or version-suffixed:
  - `example-package`, `simple-toml-configurator`, `vivado-2022_2`
- Inside derivations, prefer `pname` + `version`.
- Use clear `let` variable names (`pythonEnv`, `programName`, `desktopEntry`, `runtimeDeps`).

### Arguments and imports
- Use attrset function headers with explicit dependencies and optional `...`.
- Prefer `inherit` for in-scope values.
- For Python packages, extract `pythonEnv = pkgs.python312Packages` in the `let` block.
Examples:
```nix
{ maintainers, pkgs, ... }:
inherit pname version;
```

### Formatting
- Existing files use mixed indentation (2-space and 4-space).
- Match surrounding style in the edited file; do not reformat unrelated lines.
- Keep `let ... in` blocks concise.
- Keep long shell logic in multiline strings (`'' ... ''`).

### Fetch patterns
- Most packages use `pkgs.fetchFromGitHub` (mostly from owner `srcres258`).
- Some files use `hash` (newer nixpkgs convention), some use `sha256`. Follow whichever the file already uses.
- Binary packages use `fetchzip` or `fetchurl`.

### Python package patterns
Three approaches observed in the repo:
1. **`buildPythonApplication`** – for CLI apps (`ag`, `jyyslide-util`, `adif-manage`). Uses `format = "pyproject"` and `propagatedBuildInputs`.
2. **`buildPythonPackage`** – for libraries (`simple-toml-configurator`). Uses `pyproject = true`, `build-system`, and `dependencies` (newer nixpkgs python infrastructure).
3. No Python packages use `buildPythonPackage` with `buildPythonPackage rec { ... }` — prefer the patterns above.

### Metadata expectations
Include a meaningful `meta` block when possible:
- `description`, `homepage`, `license`, `maintainers`
- `platforms` and `mainProgram` where applicable
- `broken = true` for known-broken packages (example: `jlc-assistant`)
- `sourceProvenance` for binary/distributed artifacts (example: `lceda-pro`, `vivado-2022_2` use `binaryNativeCode`, `binaryBytecode`, `binaryData`)

### Error handling and safety
- Prefer explicit metadata gating (`broken`, license correctness, `preferLocalBuild`) to avoid CI/cache surprises.
- In shell phases/scripts, document non-obvious workarounds briefly.
- Use `runHook preInstall` / `runHook postInstall` in custom install phases.
- The `peerbanhelper` package uses `mkDerivation (finalAttrs: { ... })` instead of `rec` — a newer nixpkgs pattern that avoids the `rec` pitfall.

### Derivation quirk
- `pkgs/vivado-2022_2/default.nix` wraps its derivation in `buildFHSEnv` for FHS compatibility — this is uncommon and worth noting if touching that package.

## Critical Files to Inspect Before Editing
- Package exports: `default.nix`
- CI output selection: `ci.nix`
- CI pipeline behavior: `.github/workflows/build.yml`
- Flake outputs: `flake.nix`
- Overlay wiring: `overlay.nix`, `overlays/default.nix`
- Maintainers list: `maintainers.nix`

## Scope Guardrails for Agents
- Keep diffs minimal and task-focused.
- Validate the narrowest affected target first (`nix-build -A <attr>`).
- Do not introduce broad refactors during package updates.
- If adding a new package:
  1. Create `pkgs/<name>/default.nix`
  2. Export it in root `default.nix` with `pkgs.callPackage ./pkgs/<name> { inherit maintainers; }`
  3. Add accurate `meta` (at minimum: `description`, `homepage`, `license`, `maintainers`, `mainProgram`)
  4. Build with `nix-build -A <name>`
