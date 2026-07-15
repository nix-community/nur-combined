# PCTX Source Packaging Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a source-built PCTX CLI with its separately versioned, source-built Python SDK exposed as `pctx.py`.

**Architecture:** `pkgs/pctx/default.nix` builds the Rust workspace package `pctx` from tag `v0.7.1` and exposes a separate Python derivation through `passthru.py`. `pkgs/pctx/python.nix` fetches tag `pctx-py-v0.4.1` and builds the `pctx-py/` subtree. An internal `uv-build` 0.9.13 source derivation satisfies the SDK's explicitly bounded PEP 517 backend requirement.

**Tech Stack:** Nix, `rustPlatform.buildRustPackage`, Cargo, fixed `rusty_v8` build artifact, `buildPythonPackage`, Maturin, `fetchFromGitHub`.

## Global Constraints

- The CLI version is exactly `0.7.1` from Git tag `v0.7.1`.
- The Python SDK version is exactly `0.4.1` from Git tag `pctx-py-v0.4.1` and `pctx-py/` source subtree.
- Do not use the npm wrapper/tarball, npm postinstall, released PCTX CLI binary, or PyPI sdist.
- Do not combine, synchronize, or reuse CLI and Python version variables or source hashes.
- PCTX source is compiled with Cargo; `deno_core` is a regular Cargo dependency, not a separately packaged Deno CLI.
- Do not set `V8_FROM_SOURCE`; provide the versioned `rusty_v8` static archive and generated binding source through raw filesystem paths in `RUSTY_V8_ARCHIVE` and `RUSTY_V8_SRC_BINDING_PATH` so Cargo never accesses the network.
- The Python SDK requires `uv_build>=0.9.13,<0.10.0`; use a private source-built `uv-build` 0.9.13, not nixpkgs' newer backend.
- Export only `pctx` at repository root; expose the SDK solely as `pctx.py`.
- Preserve `flake.lock`; do not alter CI policy, modules, overlays, or unrelated packages.
- Build and smoke-test both public derivations before documentation cleanup.

---

## File Structure

| Path | Responsibility |
| --- | --- |
| `pkgs/pctx/default.nix` | Source-built Rust CLI, fixed V8 static archive/bindings inputs, and `passthru.py`. |
| `pkgs/pctx/python.nix` | Source-built `pctx-client` from the Python release tag. |
| `pkgs/pctx/uv-build.nix` | Private source-built PEP 517 backend pinned to 0.9.13. |
| `pkgs/pctx/AGENTS.md` | Package-local update and verification contract. |
| `default.nix` | Adds the only top-level export, `pctx`. |
| `README.md` | Adds the public package to the current export inventory. |
| `AGENTS.md` | Updates repository package count and developer-tool inventory. |

### Task 1: Build the bounded uv-build backend from source

**Files:**
- Create: `pkgs/pctx/uv-build.nix`

**Interfaces:**
- Consumes: `python3Packages.callPackage` and standard nixpkgs Rust/Maturin hooks.
- Produces: a private `uv-build` 0.9.13 Python derivation importable as `uv_build`.

- [ ] **Step 1: Establish the missing-backend failure**

Run:

```bash
nix-build -E 'with import <nixpkgs> {}; python3Packages.callPackage ./pkgs/pctx/uv-build.nix { }'
```

Expected: failure because `pkgs/pctx/uv-build.nix` does not yet exist.

- [ ] **Step 2: Add the source-built backend recipe**

Create `pkgs/pctx/uv-build.nix` with this initial fixed-output recipe. The literal `lib.fakeHash` values are intentional for the next two resolution steps and must not be committed as final hashes.

```nix
{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  rustPlatform,
}:

buildPythonPackage (finalAttrs: {
  pname = "uv-build";
  version = "0.9.13";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "astral-sh";
    repo = "uv";
    tag = finalAttrs.version;
    hash = lib.fakeHash;
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = lib.fakeHash;
  };

  buildAndTestSubdir = "crates/uv-build";
  maturinBuildProfile = "minimal-size";
  pythonImportsCheck = [ "uv_build" ];
  doCheck = false;

  meta = with lib; {
    description = "Minimal build backend for uv";
    homepage = "https://docs.astral.sh/uv/";
    license = with licenses; [ mit asl20 ];
  };
})
```

- [ ] **Step 3: Resolve the source and Cargo vendor hashes separately**

Run the Step 1 command. Replace the source `lib.fakeHash` with the SRI hash Nix reports. Run it again, then replace the `cargoDeps.hash` `lib.fakeHash` with Nix's reported SRI hash. Do not copy either hash into a PCTX derivation.

Expected final output: a successful derivation path for `uv-build-0.9.13`.

- [ ] **Step 4: Smoke-test the backend in an interpreter closure**

Run:

```bash
nix-shell -p '(with import <nixpkgs> {}; python3.withPackages (ps: [ (ps.callPackage ./pkgs/pctx/uv-build.nix { }) ]))' --run 'python -c "import uv_build; print(uv_build.__file__)"'
```

Expected: exit status 0 and a Nix-store path for `uv_build`.

- [ ] **Step 5: Commit the private backend**

```bash
git add pkgs/pctx/uv-build.nix
git commit -m "build(pctx): add pinned uv build backend"
```

### Task 2: Build the Python SDK from its own source tag

**Files:**
- Create: `pkgs/pctx/python.nix`
- Uses: `pkgs/pctx/uv-build.nix`

**Interfaces:**
- Consumes: tag `pctx-py-v0.4.1`, the private `uv-build` derivation, and runtime packages declared in `pctx-py/pyproject.toml`.
- Produces: `pctx-client` 0.4.1 with importable module `pctx_client`.

- [ ] **Step 1: Establish the missing-SDK failure**

Run:

```bash
nix-build -E 'with import <nixpkgs> {}; python3Packages.callPackage ./pkgs/pctx/python.nix { }'
```

Expected: failure because `pkgs/pctx/python.nix` does not yet exist.

- [ ] **Step 2: Add the independent Python source recipe**

Create `pkgs/pctx/python.nix`:

```nix
{
  lib,
  buildPythonPackage,
  docstring-parser,
  fetchFromGitHub,
  httpx,
  jsonschema,
  pydantic,
  callPackage,
  websockets,
}:

let
  uv-build = callPackage ./uv-build.nix { };
in
buildPythonPackage rec {
  pname = "pctx-client";
  version = "0.4.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "portofcontext";
    repo = "pctx";
    rev = "pctx-py-v${version}";
    hash = lib.fakeHash;
  };

  sourceRoot = "source/pctx-py";
  postPatch = ''
    data_dir=src/pctx_client/descriptions/data
    if [ -L "$data_dir" ]; then
      data_target="$(readlink "$data_dir")"
      data_parent="$(dirname "$data_dir")"
      rm "$data_dir"
      cp -r "$data_parent/$data_target" "$data_dir"
    fi
  '';
  build-system = [ uv-build ];
  dependencies = [
    docstring-parser
    httpx
    jsonschema
    pydantic
    websockets
  ];

  pythonImportsCheck = [ "pctx_client" ];
  doCheck = false;

  meta = with lib; {
    description = "Python client for using Code Mode via PCTX";
    homepage = "https://github.com/portofcontext/pctx";
    license = licenses.mit;
  };
}
```

`pctx-py-v0.4.1` stores `src/pctx_client/descriptions/data` as an in-tree relative symlink. The private `uv-build` 0.9.13 backend cannot package that symlink; the narrow `postPatch` replaces it with the same tagged source-tree contents before wheel construction.

- [ ] **Step 3: Resolve only the Python source hash**

Run the Step 1 command. Replace only the `src.hash` with Nix's reported SRI hash, then rerun until the package builds. Do not use `v0.7.1`, the Rust source hash, or any PyPI archive in this derivation.

Expected: `pctx-client-0.4.1` builds and its declared `pythonImportsCheck` passes.

- [ ] **Step 4: Exercise the public Python API import**

Run:

```bash
nix-shell -p '(with import <nixpkgs> {}; python3.withPackages (ps: [ (ps.callPackage ./pkgs/pctx/python.nix { }) ]))' --run 'python -c "from pctx_client import Pctx, tool; print(Pctx.__name__, callable(tool))"'
```

Expected: `Pctx True` and exit status 0.

- [ ] **Step 5: Commit the SDK source build**

```bash
git add pkgs/pctx/python.nix pkgs/pctx/uv-build.nix
git commit -m "feat(pctx): add source-built Python client"
```

### Task 3: Build and export the Rust CLI from source

**Files:**
- Create: `pkgs/pctx/default.nix`
- Modify: `default.nix:75`
- Uses: `pkgs/pctx/python.nix`

**Interfaces:**
- Consumes: source tag `v0.7.1`, Cargo vendor set, static `rusty_v8` 145.0.0 archive, and the Python SDK derivation.
- Produces: CLI derivation `pctx`, binaries `pctx` and `generate-cli-docs`, and passthrough derivation `pctx.py`.

- [ ] **Step 1: Capture the missing public-export failure**

Run:

```bash
nix build .#pctx
```

Expected: failure because the root flake/package set does not yet expose `pctx`.

- [ ] **Step 2: Add the source-built CLI derivation**

Create `pkgs/pctx/default.nix` with this initial recipe. The four independently resolved input groups are intentional until Step 3: PCTX source, Cargo vendor set, V8 archive, and V8 bindings. Both V8 inputs must match `stdenv.hostPlatform.rust.rustcTarget`; the V8 crate receives raw store paths, not `file://` URIs.

```nix
{
  cmake,
  fetchFromGitHub,
  fetchurl,
  lib,
  pkg-config,
  python3Packages,
  rustPlatform,
  stdenv,
}:

let
  version = "0.7.1";

  rustyV8Hashes = {
    "x86_64-linux" = lib.fakeHash;
    "aarch64-linux" = lib.fakeHash;
  };

  rustyV8BindingHashes = {
    "x86_64-linux" = lib.fakeHash;
    "aarch64-linux" = lib.fakeHash;
  };

  rustyV8 = fetchurl {
    url = "https://github.com/denoland/rusty_v8/releases/download/v145.0.0/librusty_v8_release_${stdenv.hostPlatform.rust.rustcTarget}.a.gz";
    hash = rustyV8Hashes.${stdenv.hostPlatform.system}
      or (throw "pctx: unsupported platform ${stdenv.hostPlatform.system}");
  };

  rustyV8Binding = fetchurl {
    url = "https://github.com/denoland/rusty_v8/releases/download/v145.0.0/src_binding_release_${stdenv.hostPlatform.rust.rustcTarget}.rs";
    hash = rustyV8BindingHashes.${stdenv.hostPlatform.system}
      or (throw "pctx: unsupported platform ${stdenv.hostPlatform.system}");
  };

  py = python3Packages.callPackage ./python.nix { };
in
rustPlatform.buildRustPackage {
  pname = "pctx";
  inherit version;

  src = fetchFromGitHub {
    owner = "portofcontext";
    repo = "pctx";
    rev = "v${version}";
    hash = lib.fakeHash;
  };

  cargoHash = lib.fakeHash;
  cargoBuildFlags = [ "-p" "pctx" ];
  RUSTY_V8_ARCHIVE = "${rustyV8}";
  RUSTY_V8_SRC_BINDING_PATH = "${rustyV8Binding}";

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  passthru = { inherit py; };

  meta = with lib; {
    description = "Execution layer for agentic tool calls and MCP servers";
    homepage = "https://github.com/portofcontext/pctx";
    license = licenses.mit;
    mainProgram = "pctx";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
```

- [ ] **Step 3: Resolve all four fixed input groups without conflating release lines**

1. Run `nix build .#pctx`; replace the Rust `src.hash` with the reported SRI hash.
2. Run it again; replace `cargoHash` with the reported Cargo vendor SRI hash.
3. Prefetch both V8 archives and both matching generated binding sources, then replace their corresponding platform entries:

```bash
nix store prefetch-file --json https://github.com/denoland/rusty_v8/releases/download/v145.0.0/librusty_v8_release_x86_64-unknown-linux-gnu.a.gz
nix store prefetch-file --json https://github.com/denoland/rusty_v8/releases/download/v145.0.0/librusty_v8_release_aarch64-unknown-linux-gnu.a.gz
nix store prefetch-file --json https://github.com/denoland/rusty_v8/releases/download/v145.0.0/src_binding_release_x86_64-unknown-linux-gnu.rs
nix store prefetch-file --json https://github.com/denoland/rusty_v8/releases/download/v145.0.0/src_binding_release_aarch64-unknown-linux-gnu.rs
```

4. Re-run `nix build .#pctx`; if a native build error names a missing executable or shared library, add only that named nixpkgs dependency to the relevant input list and rebuild. Do not replace source compilation with the npm wrapper or a PCTX release executable.

Expected: a source-built PCTX derivation; Cargo's V8 build script consumes fixed archive and binding-source store paths without network access.

- [ ] **Step 4: Wire the root export**

Add this line immediately after the existing `banguminet` export in the root `default.nix`:

```nix
  pctx = pkgs.callPackage ./pkgs/pctx { };
```

- [ ] **Step 5: Build both public attribute paths and smoke-test the CLI**

Run:

```bash
nix build --out-link result-pctx .#pctx
nix build --out-link result-pctx-py .#pctx.py
result-pctx/bin/pctx --version
result-pctx/bin/generate-cli-docs --help
```

Expected: both derivations build; `pctx --version` reports `0.7.1`; the documentation generator renders help without a missing-library failure.

- [ ] **Step 6: Commit the public package surface**

```bash
git add default.nix pkgs/pctx/default.nix pkgs/pctx/python.nix pkgs/pctx/uv-build.nix
git commit -m "feat(pctx): add source-built CLI package"
```

### Task 4: Document the verified package and repository inventory

**Files:**
- Create: `pkgs/pctx/AGENTS.md`
- Modify: `README.md:22-36`
- Modify: `AGENTS.md`
- Modify: `docs/superpowers/specs/2026-07-15-pctx-packaging-design.md`

**Interfaces:**
- Consumes: successful output and hash data from Tasks 1–3.
- Produces: contributor instructions that prevent version/hash conflation and a current public package inventory.

- [ ] **Step 1: Gate documentation on the successful smoke tests**

Do not start this task until all commands in Task 3 Step 5 exit successfully. If either public derivation or CLI smoke test fails, return to the source of that failure instead of editing documentation.

- [ ] **Step 2: Write `pkgs/pctx/AGENTS.md`**

Create the package-local guide with this content, substituting the verified test output only if it differs:

```markdown
# PCTX Packaging Guide

## Public interface

- `pctx` is the source-built Rust CLI.
- `pctx.py` is the source-built Python `pctx-client` SDK exposed only through `pctx.passthru.py`.
- Do not add a top-level `pctx-client` export.

## Independent release lines

| Component | Source tag | Version | Build mechanism |
| --- | --- | --- | --- |
| CLI | `v0.7.1` | `0.7.1` | `rustPlatform.buildRustPackage` |
| Python SDK | `pctx-py-v0.4.1` | `0.4.1` | `buildPythonPackage` from `pctx-py/` |
| PEP 517 backend | `astral-sh/uv` `0.9.13` | `0.9.13` | private Maturin source build |

Never synchronize these versions, tags, or hashes. In particular, do not use the CLI's `v0.7.1` for `pctx.py`, and do not use the Python SDK's `0.4.1` for the Rust CLI.

## Rust/V8 build rule

The CLI source depends on `deno_core`; it is compiled as a normal Cargo dependency. Do not package a separate Deno CLI and do not set `V8_FROM_SOURCE`. `RUSTY_V8_ARCHIVE` and `RUSTY_V8_SRC_BINDING_PATH` must point to matching fixed `rusty_v8` 145.0.0 archive and generated-binding inputs so Cargo does not attempt network access. Never substitute the npm wrapper or an upstream PCTX binary.

## Update procedure

1. Update the CLI tag/version in `default.nix`, then separately refresh its GitHub source hash and `cargoHash`.
2. Update the matching `rusty_v8` archive and generated-binding versions only when Cargo.lock changes its `v8` crate version; refresh every supported-platform archive and binding hash.
3. Update the Python tag/version in `python.nix` separately, then refresh only its source hash.
4. Keep `uv-build.nix` at a version satisfying `pctx-py/pyproject.toml`'s `uv_build` upper bound; update its source and Cargo hashes independently.
5. Rebuild and smoke-test both `pctx` and `pctx.py` after any update.

## Verification

```bash
nix build --out-link result-pctx .#pctx
nix build --out-link result-pctx-py .#pctx.py
result-pctx/bin/pctx --version
result-pctx/bin/generate-cli-docs --help
```
```

- [ ] **Step 3: Update repository documentation from the actual export**

1. Add this row after `codegraph` in the `README.md` developer-tools table:

```markdown
| `pctx` | Source-built Code Mode execution layer for agentic tool calls and MCP servers; `pctx.py` exposes its Python SDK |
```

2. In root `AGENTS.md`, update the stale exported-package count from 24 to 28 in both the repository-shape and package-inventory descriptions.
3. Add `pctx` to the MCP/developer-tools inventory in root `AGENTS.md`, describing it as a source-built Code Mode execution layer with a Python SDK at `pctx.py`.
4. Keep the design specification's Deno clarification: `deno_core` compiles as a normal Cargo dependency; no standalone Deno CLI or V8-from-source build is introduced.

- [ ] **Step 4: Re-run final package evidence after documentation changes**

Run:

```bash
nix build --out-link result-pctx .#pctx
nix build --out-link result-pctx-py .#pctx.py
result-pctx/bin/pctx --version
```

Expected: documentation-only changes do not alter the source-build results; `pctx --version` still reports `0.7.1`.

- [ ] **Step 5: Commit documentation cleanup**

```bash
git add AGENTS.md README.md pkgs/pctx/AGENTS.md docs/superpowers/specs/2026-07-15-pctx-packaging-design.md
git commit -m "docs(pctx): document source packaging workflow"
```

## Plan Self-Review

- **Spec coverage:** Task 1 satisfies the bounded Python backend requirement; Task 2 builds the independent Python source tag; Task 3 builds the independent Rust source tag, pins V8, creates `passthru.py`, wires the only root export, and verifies both public paths; Task 4 fulfills the required package-local and repository documentation updates after smoke tests.
- **Placeholder scan:** Final package files may not retain `lib.fakeHash`; the plan uses it only as the explicit, reproducible fixed-output-hash discovery mechanism.
- **Interface consistency:** `default.nix` defines `py` from `python.nix`; root `default.nix` exports only `pctx`; flake users access the SDK as `pctx.py`.
