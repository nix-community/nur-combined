# Weaver 0.25.1 missing zstd dependency

- Status: fixed upstream
- Last reviewed: 2026-11-17
- Affected file: `pkgs/obstudio/package.nix`
- Activation: exactly `weaver.version == "0.25.1"`

## Failure and workaround

[CI job](https://github.com/Alxandr/nur/actions/runs/44024637785/job/133841929568)
failed building Weaver, which Obstudio includes in its wrapper's PATH.
The weekly nixpkgs Rust setup hook sets `ZSTD_SYS_USE_PKG_CONFIG=1`, but
Weaver 0.25.1 declares only OpenSSL in `buildInputs`. The `zstd-sys` build
therefore fails because pkg-config cannot find `libzstd.pc`.

Add `zstd` to this Weaver dependency's build inputs using `overrideAttrs`.
Preserve existing inputs and restrict the override to the exact failing version.
Other Weaver versions retain the original derivation.

The newer [nixpkgs Weaver definition](https://github.com/NixOS/nixpkgs/blob/5d2b81a7a3be3e2f832879028e4d60abbf58e9a0/pkgs/by-name/we/weaver/package.nix)
packages Weaver 0.28.0 and already includes zstd. The fix has not reached weekly.
No separate upstream issue was filed.

## Verification

Inputs resolved from the matrix in `.github/workflows/build.yml`:

| Input | Exact revision | Weaver | Override |
| --- | --- | --- | --- |
| nixpkgs-unstable | `5d2b81a7a3be3e2f832879028e4d60abbf58e9a0` | 0.28.0 | inactive |
| nixos-unstable | `d5cc6833999746cffdfe0598f7bc801a57b887a9` | 0.28.0 | inactive |
| nixos-stable (nixos-26.05) | `b349185bb79c7cf7ad8ea8c097931730bf473c71` | 0.23.0 | inactive |
| detnix-weekly | `f4a03c008967841f2a0b3cb7c436fc6fc31671f6` | 0.25.1 | active |

The unmodified weekly Weaver build reproduced the CI failure locally, using
the identical derivation `/nix/store/02fr48ki0qncyh3xwm5bv7a502cqf797-weaver-0.25.1.drv`.
Reproduce against the pinned weekly nixpkgs source with
`nix-build <source> -A weaver --no-out-link`.

Completed checks:

- Patched weekly Weaver built successfully, including its upstream test suite.
  Output: `/nix/store/c89apy1hijwmlvk8wnr1yrdr6ihb2dr2-weaver-0.25.1`.
- The modified checkout's Obstudio 0.1.2 evaluated and built successfully against
  all four inputs, with its normal tests and version/HTTP install checks.
  Both unstable inputs share the same resulting derivation.
- For the inactive 0.23.0 and 0.28.0 branches, evaluation confirmed identical
  Obstudio derivations with the guard bypassed, so the override changes nothing.
- `nixfmt --check pkgs/obstudio/package.nix` and `git diff --check` passed.

After updating the GitButler workspace to `06a861b` (current main), the same
four-input build command also succeeded for Obstudio 0.1.4. Weekly's changed
output built locally and passed its normal tests and version/HTTP install
checks; the unaffected unstable and stable outputs were substituted from cache.
Weekly output: `/nix/store/ipnj182x4zd5yswfv8vkmpg9vm2hvgb1-obstudio-0.1.4`.
Local logs: `/tmp/nur-weekly-weaver-build.log`,
`/tmp/nur-weekly-weaver-fixed.log`, `/tmp/nur-obstudio-matrix-build.log`, and
`/tmp/nur-obstudio-014-matrix-build.log`.

## Removal criteria

Remove the override and its code marker once no supported input needs it.
Resolve every matrix input again, inspect Weaver's build inputs, and evaluate
and build Obstudio without the override on each input. A newer upstream package
alone is insufficient while weekly still resolves to the affected snapshot.
Retain this record with status `resolved` after removal.
