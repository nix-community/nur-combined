# PCTX packaging design

## Goal

Add the PCTX CLI and its Python SDK to this NUR as a single public package surface:

```nix
pctx
pctx.py
```

Both products build from source. They intentionally have separate releases, source tags, version variables, hashes, and update procedures.

## Release boundaries

| Product | Public package path | Upstream source | Version |
| --- | --- | --- | --- |
| PCTX CLI | `pctx` | `portofcontext/pctx` tag `v0.7.1` | `0.7.1` |
| Python SDK | `pctx.py` | `portofcontext/pctx` tag `pctx-py-v0.4.1`, `pctx-py/` subdirectory | `0.4.1` |

`@portofcontext/pctx` is npm's wrapper around the native CLI release. It is used only to establish the CLI release/version line; the Nix package does not use the npm tarball, npm install hook, or a released PCTX binary.

The Python SDK is not built from a PyPI sdist. It is fetched from its own upstream Git tag and built from the repository subdirectory.

## Package layout

```text
pkgs/pctx/
├── default.nix
├── python.nix
├── uv-build.nix
└── AGENTS.md
```

`default.nix` defines the Rust CLI and owns `passthru.py`. `python.nix` defines the Python SDK. `uv-build.nix` is an internal build dependency only; it is not exported through `default.nix`.

The repository root exports only:

```nix
pctx = pkgs.callPackage ./pkgs/pctx { };
```

This makes the SDK reachable as `pctx.py`, without adding an independent top-level `pctx-client` attribute.

## Rust CLI build

`default.nix` uses `rustPlatform.buildRustPackage` with a `fetchFromGitHub` source fixed to tag `v0.7.1` and a separate Cargo vendor hash. It builds only workspace package `pctx`, which provides both the `pctx` and `generate-cli-docs` binaries.

The source requires `deno_core`, whose `v8` crate needs both a static library and generated Rust bindings during Cargo's build script. Nix supplies those as separately fixed build-time inputs through `RUSTY_V8_ARCHIVE` (a filesystem path, not a `file://` URI) and `RUSTY_V8_SRC_BINDING_PATH`; the PCTX application itself is still compiled from source. The package must never fall back to the npm-delivered PCTX executable or allow network access during a build.
`deno` is not packaged or compiled as a standalone CLI. Cargo compiles `deno_core` as an ordinary Rust dependency of PCTX; Nix supplies the pinned V8 archive and bindings without setting `V8_FROM_SOURCE`.

The package metadata identifies `pctx` as the main program and limits platform support to systems that the source build is verified to support.

## Python SDK build

`python.nix` uses `buildPythonPackage` on the `pctx-py/` source subtree from tag `pctx-py-v0.4.1`. Runtime dependencies follow that tag's `pyproject.toml`: `docstring-parser`, `httpx`, `jsonschema`, `pydantic`, and `websockets`.

The tag requires `uv_build>=0.9.13,<0.10.0`, while the current nixpkgs `uv-build` is newer and outside that declared compatibility range. `uv-build.nix` therefore builds exactly `uv-build` 0.9.13 from source as a private build backend. `python.nix` uses it as the PEP 517 build system and includes an import check for `pctx_client`.

Optional agent-framework extras are not enabled. They remain user-selectable dependencies rather than forced runtime closure contents.

## Documentation and maintenance

`pkgs/pctx/AGENTS.md` records:

- the distinct CLI, Python SDK, and internal build-backend version lines;
- source tag and hash update procedures for each line;
- the fixed V8 archive requirement for Rust builds;
- required build and smoke-test commands;
- the prohibition on synchronizing version variables or hashes across the CLI and SDK.

## Verification

The implementation must prove all of the following:

1. `nix build .#pctx` completes from source.
2. `nix build .#pctx.py` completes from source.
3. The resulting `pctx` executable reports its expected release version or otherwise successfully renders its version/help contract.
4. The Python derivation imports `pctx_client` using the Nix-built dependency closure.
5. The new root export evaluates without changing `flake.lock`.

## Non-goals

- No top-level `pctx-client` export.
- No npm wrapper, npm lockfile, npm postinstall hook, or prebuilt PCTX CLI release asset.
- No PyPI sdist for the Python client.
- No optional Python integration extras.
- No unrelated changes to flake inputs, CI policy, modules, overlays, or existing packages.
