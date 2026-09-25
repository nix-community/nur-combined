# Agent Instructions for this Repository

Welcome, Agent! This document outlines the build, test, and code style guidelines for this Nix-based repository. This repository functions as a custom Nix flake and Nix User Repository (NUR), containing the Nix derivation for `omp` ([can1357/oh-my-pi](https://github.com/can1357/oh-my-pi)), an AI coding agent for the terminal.

Please read and adhere to these guidelines when making modifications to ensure consistency, idiomatic Nix usage, and working builds.

---

## 1. Project Architecture and Context

This is predominantly a Nix codebase.

- `flake.nix`: The modern Nix entrypoint exposing legacy packages and standard flake outputs.
- `default.nix`: The legacy entrypoint, primarily used for NUR compatibility.
- `pkgs/omp/default.nix`: The package definition.

### 1.1. Why `omp` is a fetched binary, not a source build

Upstream (`can1357/oh-my-pi`) is a TypeScript (Bun runtime) + Rust (N-API native addon) + Bazel project that publishes new releases almost daily. There is no practical way to keep a from-source Nix build (vendored `cargoHash`/`npmDepsHash`/Bazel fetches) in sync with that cadence. Instead, `pkgs/omp/default.nix` fetches the same prebuilt, single-file executables that upstream's own install script (`curl -fsSL https://omp.sh/install | sh`) downloads from GitHub Releases, and pins a `sha256` hash per platform verified against the release's `SHA256SUMS.txt`.

**Do not attempt to convert this to a source build** unless upstream's release cadence and build story change significantly — it is not worth the maintenance burden.

### 1.2. Critical gotcha: never let `strip` touch this binary

The upstream executables are built with `bun build --compile`, which appends the bundled application (JS + assets) after the ELF's own sections, similar to a self-extracting archive. Running the standard `strip` fixup phase on it silently truncates that trailing data — the binary still runs, but downgrades to a bare Bun runtime (`omp --version` prints something like `1.3.14` instead of `omp/17.2.12`). This was caught empirically, not from upstream docs.

`dontStrip = true;` in `pkgs/omp/default.nix` must never be removed. If you touch this file, re-verify with:

```bash
nix build .#omp
./result/bin/omp --version   # must print "omp/<version>", not a bare Bun version
```

---

## 2. Build, Lint, and Test Commands

### 2.1. Building

- **Build `omp`:** `nix build .#omp`
- Legacy: `nix-build -A omp`

### 2.2. Testing

There is no `checkPhase` — this is a fetched binary, not something compiled here. The only meaningful test is running it:

```bash
nix build .#omp
./result/bin/omp --version
./result/bin/omp --help
```

On Linux, also sanity-check that `autoPatchelfHook` didn't leave unresolved dependencies (the build log ends with `auto-patchelf: 0 dependencies could not be satisfied`; anything else is a regression).

### 2.3. Updating to a new upstream version

This is automated: `.github/workflows/update-omp.yml` runs `scripts/update-omp.sh` daily (and on `workflow_dispatch`), which checks the latest `can1357/oh-my-pi` release, rewrites `version` and the four per-platform `hash` fields in `pkgs/omp/default.nix` from that release's `SHA256SUMS.txt`, builds `omp` and checks its `--version` output (catches both hash mistakes and the §1.2 strip regression on `x86_64-linux`), then opens a PR for review. It does not auto-merge.

To bump manually (e.g. to test the script, or if the workflow is broken):

```bash
./scripts/update-omp.sh   # requires curl, jq, nix, git
nix build .#omp
./result/bin/omp --version   # must print "omp/<version>"
```

Note the `aarch64-linux`/`aarch64-darwin` hashes are only ever validated against upstream's published `SHA256SUMS.txt`, never independently built in CI (no cross-arch runner) — a bad upload there would only surface as a build failure for those users, not in CI.

---

## 3. Code Style Guidelines

### 3.1. Formatting and Indentation

- **Indentation:** Use exactly **2 spaces** for indentation. Never use tabs.
- **Line Endings:** Use Unix-style (`\n`) line endings. Ensure all files end with a single trailing newline.
- **Formatter:** Run `nix fmt` (uses `nixfmt-tree`) before committing. Note it needs a git-initialized tree with no uncommitted symlinks into `/nix/store` (e.g. a stray `result` symlink) or it may misdetect the project root and try to format read-only store paths.

### 3.2. Nix Language Conventions

- **Attribute Sets:** For small sets, inline definitions are acceptable: `{ foo = "bar"; }`. For larger sets, place each attribute on a new line.
- **Strings:** Use double quotes (`"`) for strings. Use double-single quotes (`''`) for multi-line strings.
- **Inherit:** Use `inherit` to extract variables from the outer scope or an attribute set rather than re-assigning them manually.

### 3.3. Naming Conventions

- Derivation file names should be `default.nix` inside a directory named after the package.
- Use `camelCase` for Nix variables and function names.
- Use `kebab-case` for package names in `pname`.

### 3.4. Meta Attribute

Every package must have a `meta` block containing `description`, `homepage`, `license`, `mainProgram` (if it is an application), and — for fetched-binary packages like this one — `sourceProvenance = [ lib.sourceTypes.binaryNativeCode ]` to be honest with consumers about how it was built.

---

## 4. Workflows

### 4.1. Adding a New System

If upstream adds a new release asset (e.g. `omp-linux-musl-x64` for static/musl targets), add it to the `sources` attrset in `pkgs/omp/default.nix` and, if it maps to a system nixpkgs still supports, add that system to the `systems` list in `flake.nix`.

### 4.2. PR Review Checklist

- Does `nix build .#omp` succeed on the system you're targeting?
- Does `./result/bin/omp --version` print the real `omp/<version>` string (not a bare Bun version)?
- Is every platform's `sha256` hash cross-checked against upstream's `SHA256SUMS.txt`?
- Does `nix flake check --all-systems` pass? (Watch for nixpkgs dropping a Darwin arch out from under you — see the note in `flake.nix` about `x86_64-darwin`.)
- Does the code adhere to the 2-space Nix indentation rule and pass `nix fmt`?
