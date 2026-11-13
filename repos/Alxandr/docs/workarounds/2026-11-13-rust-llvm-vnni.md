# Rust VNNI intrinsics with older LLVM

- Status: fixed upstream
- Introduced: 2026-11-13
- Last reviewed: 2026-11-13
- Location: `pkgs/gitbutler-cli/package.nix` and `adler32furious-llvm21.patch`
- Affected package: gitbutler-cli 0.23.2, dependency adler32furious 0.1.1
- Activation: Rust >= 1.98 with LLVM < 22

## Problem and upstream fix

[PR #131's CI run](https://github.com/Alxandr/nur/actions/runs/42597077757)
failed compiling adler32furious with an intrinsic signature mismatch for
`llvm.x86.avx512.vpdpbusd.256`. Newer Rust declares byte-vector operands,
while LLVM 21 expects integer-vector operands.

[nixpkgs commit aa0cf492b8fbf63b2bfb5ad0fbe070c5a85ba1fb](https://github.com/NixOS/nixpkgs/commit/aa0cf492b8fbf63b2bfb5ad0fbe070c5a85ba1fb)
fixes the same failure by switching Rust to LLVM 23. Both unstable inputs
contain the corrected toolchain; the currently resolved weekly input does not.

## Workaround

Patch the writable vendored copy of adler32furious only when the toolchain
condition holds. Exclude VNNI implementations and their runtime dispatch
entries. Retain AVX2, SSE2, and the portable implementation. The checksum
algorithm and public API are unchanged; CPUs with VNNI use a slower supported
implementation. This avoids changing Rust or rebuilding the compiler.

The patch deliberately targets dependency version 0.1.1 and fails visibly if
an update changes its location or context. Cargo source and dependency hashes
remain unchanged because patching happens after vendoring.

## Verification

Resolved matrix on 2026-11-13:

| Input | Exact nixpkgs revision | Rust / LLVM | Workaround |
| --- | --- | --- | --- |
| nixpkgs-unstable | `2074cc672349f14240fb7ea90d509e0b643e9dd4` | 1.99.1 / 23.1.3 | inactive |
| nixos-unstable | `d4f25a3e562008648d45bcf2d70bcc7422cad84e` | 1.99.1 / 23.1.3 | inactive |
| nixos-stable (26.05) | `ac588ef1c914865dad517b337ea0eb9694a4021c` | 1.95.0 / 21.1.8 | inactive |
| detnix-weekly | `0bb2eedc20e4739f29e8045034f2828ad7054f8f` | 1.99.0 / 21.1.8 | active |

The unmodified weekly expression produces exactly the failing CI derivation
`sxpbzbp7nmjlirj7g6v5mbd65x374fx5-gitbutler-cli-0.23.2.drv`.
The patched weekly build completed, including shell completions and skill
installation. The two unstable inputs produce identical gitbutler-cli
derivations. Repository-wide metadata/derivation evaluation (`nix-env -qa`
with `allowUnfree = true`) passes against all four revisions. The patched
crate's nine upstream unit tests pass under weekly's Rust 1.99.0 / LLVM 21,
including length/offset cases, incremental checksums, overflow boundaries,
and combination tests.

Final gitbutler-cli builds pass on all four revisions, including both outputs,
shell completions, and skill installation:

- Both unstable inputs: `zk78xxybwz44jb4qbzkqr5g1j9cqjrm2-gitbutler-cli-0.23.2.drv`.
- Stable: `bg1b63wy5yccaxzmfgw6rf7bmbjgm96p-gitbutler-cli-0.23.2.drv`.
- Weekly: `f6qlbpkh9lv2q0gvfxk715qw2yczp4b2-gitbutler-cli-0.23.2.drv`.

Current unstable's system-library hook additionally requires explicit AWS-LC,
Oniguruma, and SQLite build inputs. These are included in the final expression
and in the builds above. The unstable binary reports `but 0.23.2`.
This verifies the affected package and repository evaluation; a complete
repository build remains for CI.

## Removal criteria

Resolve all inputs from `.github/workflows/build.yml` again. Once none uses
the mismatched toolchain, remove the postPatch condition, patch, rustc argument,
and marker together. Evaluate the repository and build gitbutler-cli against
every matrix revision without the workaround, including both outputs and
completion/skill installation. Mark this record resolved with those results.
