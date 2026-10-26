# patchelf aborts while preparing Grpc.Tools

- Status: resolved
- Introduced: 2026-10-22
- Last reviewed: 2026-10-26
- Removed: 2026-10-26
- Former location: `pkgs/aspire-dashboard/package.nix`, `grpcPatchelf` and `buildAspire`
- Affected dependency: Aspire Dashboard 13.6.1's `Grpc.Tools` 2.83.0
- Former activation: exactly `patchelf.version == "0.19.2"`, for that dependency only

## Resolution

Removed the backport, dependency overrides, extra package arguments, and code
marker on 2026-10-26. Aspire now uses `buildDotnetModule` directly.

The current supported matrix no longer needs our backport:

- `nixpkgs-unstable`, revision `d3b13ad75cc492690728f9307e443dec9ef9a20e`,
  and `nixos-unstable`, revision `3ec636362e1816bc2f0888fa0fa2c69f1bc9e504`,
  downgrade patchelf internally to 0.15.2 for NuGet binary modification.
- `nixos-stable`, revision `1f607aa79b6356ed45d3cd3c8079c196e79efa2c`,
  defines patchelf 0.15.2, so our override was inactive.
- `detnix-weekly`, revision `55bfb4d7437bd4e09ab7cba58a43bd68eb310044`,
  evaluates to patchelf 0.15.2, so our override was inactive.

The upstream downgrade was introduced by
[`967152e4070ab72a7b510bccac2fd598602314eb`](https://github.com/NixOS/nixpkgs/commit/967152e4070ab72a7b510bccac2fd598602314eb).
Its later `overrideAttrs` retained our patch while replacing the version and
source with 0.15.2. This caused both unstable jobs in
[CI run 40314273250](https://github.com/Alxandr/nur/actions/runs/40314273250)
to fail applying the 0.19.2 backport to 0.15.2 sources.

These are current source/evaluation checks, not a reconstruction of every
revision used by that CI run. At the user's request, removal was not built
locally; verification of builds across all four inputs is deferred to CI.
The historical workaround and its verification are documented below.

## Problem and upstream tracking

[CI run 39762543261](https://github.com/Alxandr/nur/actions/runs/39762543261)
failed on both unstable inputs while `patch-nupkgs` prepared the bundled
`tools/linux_x64/protoc` executable. patchelf 0.19.2 aborted in `shiftFile` with
`Assertion 'splitIndex == -1' failed`, before Aspire compilation.

- [nixpkgs issue #576678](https://github.com/NixOS/nixpkgs/issues/576678)
  reports the same assertion and three-command sequence for another NuGet
  native executable.
- [patchelf PR #672](https://github.com/NixOS/patchelf/pull/672) fixes overlapping
  LOAD mappings after repeated executable header rewrites. It was merged on
  2026-10-20, after the 0.19.2 release.
- The backported fix is commit
  [`59acc3d98b4961cfddf02090d9426ac735603218`](https://github.com/NixOS/patchelf/commit/59acc3d98b4961cfddf02090d9426ac735603218).
- [nixpkgs PR #576897](https://github.com/NixOS/nixpkgs/pull/576897) proposed a
  temporary patchelf downgrade for `patch-nupkgs`; it was open at this review.

## Workaround

Backport the upstream patch to patchelf 0.19.2 and add `autoreconfHook`, since
the patch changes the autotools test definitions. Inject that tool only into
the `patch-nupkgs` used to fetch `Grpc.Tools` 2.83.0 for Aspire. Retain existing
patchelf patches. All other patchelf versions bypass this override entirely.

An earlier local workaround downgraded this tool to 0.15.2; the current
implementation keeps 0.19.2 and applies the upstream fix instead.

## Reproduction and verification

Extract `tools/linux_x64/protoc` from the `Grpc.Tools` 2.83.0 nupkg referenced
in `pkgs/aspire-dashboard/deps.json`. On a fresh copy, run the three separate
patchelf invocations used by `patch-nupkgs`:

1. Set the interpreter to the target nixpkgs glibc dynamic linker.
2. Add needed libraries `libicui18n.so`, `libicuuc.so`, `libz.so`, and `libssl.so`.
3. Add the runtime library RPATH constructed by `patch-nupkgs`.

The interpreter and RPATH lengths matter. Use the paths from a failing build
log or the actual hook for the input under review; short placeholder paths may
not reproduce the crash. Test a fresh copy for every tool version.

On 2026-10-22, the binary and RPATH from the failing CI run reproduced the
assertion with 0.19.2. Both 0.15.2 and 0.19.2 plus PR #672 passed the sequence.

The final package with the conditional backport was built against
`nixpkgs-unstable` revision `5adc50831c259f87faeb09ddf930d43597197473`.
The full build passed, including Native AOT publishing and the package's
startup, AOT marker, and frontend asset install checks.

With the repository's locked nixpkgs revision
`8edc0c72e3a38faf5434e40d1f19431125fe4b30`, patchelf was 0.15.2. Evaluation
confirmed the override was bypassed and produced the same derivation as an
explicit nonmatching patchelf version. This was an evaluation check of the
final conditional implementation, not a fresh full build of it.

The final backport was not separately built against every CI matrix input.
Future reviews must check the current matrix rather than treating these two
inputs as complete coverage.

## Removal criteria

Check all inputs currently listed in `.github/workflows/build.yml`:

- Determine their patchelf version and whether the upstream fix is included
  (possibly as a backport without a version change).
- Determine whether Aspire still requires the affected `Grpc.Tools` version.
- If the workaround is active anywhere, verify the original patch sequence
  and Aspire build without our backport before recommending removal there.
- If the condition is inactive everywhere, confirm the unmodified package
  evaluates and builds across the matrix before removing the dormant code.

Once all supported inputs work without the override, remove `grpcPatchelf`,
the `buildAspire` override, its extra arguments, and the marker. Use
`buildDotnetModule` directly again, and mark this record resolved with the
verified revisions and results.
