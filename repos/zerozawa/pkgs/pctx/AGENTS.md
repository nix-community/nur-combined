# PCTX — Nix Packaging Guide

Read this before updating `pctx`, `pctx.py`, or either fixed build input. The package deliberately combines two independently released upstream products in one public Nix surface:

```text
pkgs/pctx/
├── default.nix    # Rust CLI: pctx 0.7.1
├── python.nix     # Python SDK: pctx-client 0.4.1
├── uv-build.nix   # Private source-built PEP 517 backend: uv-build 0.9.13
└── AGENTS.md      # This guide
```

`default.nix` is the only root export: `pctx`. It exposes the SDK solely as `pctx.passthru.py`; never add a root `pctx-client` export.

## Rust CLI

`default.nix` source-builds package `pctx` from `portofcontext/pctx` tag `v${version}` with `rustPlatform.buildRustPackage` and `cargoBuildFlags = [ "-p" "pctx" ]`. This produces both `pctx` and `generate-cli-docs`.

The workspace uses `deno_core`, whose `v8` (`rusty_v8`) dependency downloads two release inputs during Cargo's build script. Keep the build hermetic by providing both fixed inputs for every supported Linux platform:

- `RUSTY_V8_ARCHIVE = "${rustyV8}"` is the static V8 archive.
- `RUSTY_V8_SRC_BINDING_PATH = "${rustyV8Binding}"` is the matching generated Rust binding source.
- Both values must be raw Nix store paths, **not** `file://` URLs.
- Do not set `V8_FROM_SOURCE`; do not package a separate Deno CLI. `deno_core` is an ordinary Cargo dependency.

The package supports only `x86_64-linux` and `aarch64-linux`. The unsupported-platform branch must throw rather than select a wrong V8 artifact.

### Swagger UI input

Cargo.lock pins `utoipa-swagger-ui` 9.0.2. Its default build-script behavior downloads Swagger UI v5.17.14. Network access is unavailable during Nix builds, so retain a fixed `fetchurl` archive, passed as `SWAGGER_UI_DOWNLOAD_URL = "file://${swaggerUi}"`.

The build script supports `file:` URLs and copies/extracts the fixed archive into its output directory. This is a hermetic static build input, not a PCTX release binary or npm wrapper.

`doCheck = false` is intentional: the crate's default check phase re-runs the Swagger build script and tries to mutate an already-generated archive in a read-only target state. The release build and both CLI smoke tests are required instead.

## Python SDK

`python.nix` source-builds `pctx-client` from the independent `pctx-py-v${version}` tag and `pctx-py/` source subtree. Its runtime dependencies must continue to match the core upstream `pyproject.toml` list:

- `docstring-parser`
- `httpx`
- `jsonschema`
- `pydantic`
- `websockets`

The SDK requires `uv-build>=0.9.13,<0.10.0`. Use the private, source-built `uv-build.nix` backend rather than the newer nixpkgs backend. Inside a Python package-set `callPackage`, accept the injected `callPackage` function and define:

```nix
uv-build = callPackage ./uv-build.nix { };
```

Do **not** request `python3Packages`: nixpkgs intentionally supplies it as a throwing alias inside that package scope.

The tagged Python source stores `src/pctx_client/descriptions/data` as an in-tree relative symlink. `uv-build` 0.9.13 cannot package it, so the narrow `postPatch` must replace the symlink with the same tagged source-tree contents before wheel construction. Keep `pythonImportsCheck = [ "pctx_client" ]`.

## Update workflow

The CLI, Python SDK, and uv backend have separate release lines. Never synchronize their versions, Git tags, source hashes, or Cargo hash by assumption.

1. Update the Rust CLI `version`, tag, source hash, and `cargoHash` independently. If Cargo.lock changes the `v8` package entry, update both matching platform archives and matching generated binding files. If it changes `utoipa-swagger-ui`, inspect that locked crate's build script before changing the fixed Swagger archive URL/hash.
2. Build the CLI and resolve one fixed-output hash at a time:
   ```bash
   nix build .#pctx
   nix build --out-link result-pctx .#pctx
   result-pctx/bin/pctx --version
   result-pctx/bin/generate-cli-docs --help
   ```
3. Update `python.nix` independently from the `pctx-py-v*` tag and resolve only its source hash. Keep `uv-build.nix` at a version satisfying the SDK's declared upper bound.
4. Build and exercise the passthru SDK:
   ```bash
   nix build --out-link result-pctx-py .#pctx.py
   nix-shell -p '(with import <nixpkgs> {}; python3.withPackages (ps: [ (ps.callPackage ./pkgs/pctx/python.nix { }) ]))' --run 'python -c "from pctx_client import Pctx, tool; print(Pctx.__name__, callable(tool))"'
   ```

Expected API smoke output: `Pctx True`.

## Non-goals

- No npm package, npm postinstall hook, or prebuilt PCTX executable.
- No PyPI source distribution for the SDK.
- No root `pctx-client` export.
- No `flake.lock` change for routine PCTX updates.
