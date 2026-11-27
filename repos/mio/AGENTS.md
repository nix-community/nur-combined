# Agent notes

- In this flake repo, run `git add` for newly created files before `nix build .#...`, because untracked files are not included in flake evaluation.
- Do not check upstream-published patches into this repo. Pin the patch's revision and fetch it with `fetchurl`/`fetchpatch` (SRI `hash =`), as `wallet-engine` does for Forkgram's patch in `desktop-app/patches`; keep that pin in the package expression and in its update script so it moves together with the source revision. Patches that exist only here (our own fixes) still live as files next to `package.nix`.
- Use the modern SRI format for hashes (e.g. `hash = "sha256-..."`) instead of the legacy `sha256 = "..."` attribute. You can convert old hashes using `nix hash convert <hash>` or `nix hash to-sri --type sha256 <hash>`. Note that `builtins.fetchTarball` does NOT support the `hash` attribute (only the deprecated `sha256=` is supported); use `pkgs.fetchzip` instead when you need to fetch tarballs and use the modern `hash=` attribute.
- NEVER FORCE PUSH! Just commit and `git push` normally. UNLESS YOU ACCIDENTLY PUSHED binary or other unneeded big files to git history ONLY IN THIS CASE push --force acceptable
- ALWAYS confirm that `nix build` passes successfully and the built app functions correctly before committing and pushing any changes. For GUI apps on a CLI-only host with no usable GUI session, run the build and any available non-GUI startup/smoke checks; if those pass as far as the environment permits, document that interactive behavior could not be verified and this limitation does not by itself block committing or pushing.
- CRITICAL: Make absolutely sure `nix build` passes before ANY push!
- When developing Hanga specifically, the development gate is `nix build .#hanga-dev` (runs host, mod, and xvfb agent tests). Do not wait on `nix build .#hanga` for day-to-day Hanga work; that wrap skips the long cargo checkPhase.
- Omnimux vendors `gpui-terminal`: see `by-name/om/omnimux/VENDOR.md` for upstream baselines (gpui-terminal, alacritty_terminal and the patched gpui-pre platform crates) and our local patches. App-level notes (appearance/OSC, sessions, packaging): `by-name/om/omnimux/README.md`.
- Always check `git status` to clean up any temporary files or scratch scripts created during problem solving.
- "check updates" or similar requests mean you should run `./check_updates.py`.
- Prefer upstream's own build scripts. When a package needs build changes, patch or configure upstream's script (or pass its documented flags) and run that, instead of writing a replacement build driver. If a replacement is genuinely unavoidable (e.g. MSBuild/.NET cannot run in the sandbox), keep it as thin as possible, drive it from upstream's own generated project files, and state at the top of the file why upstream's path cannot be used.
- On darwin, if upstream's build script fails only because of the Nix sandbox, turn the sandbox off for darwin instead of rewriting the script: add `__noChroot = true` (or `__darwinAllowLocalNetworking = true` when that is enough) under a `lib.optionalAttrs buildIsDarwin` block, so Linux keeps its sandbox. Diagnose first — confirm the failure is sandbox-only (Wine's `Can't check in server_mach_port` is the usual one).
- Some darwin-only packages need a newer host Xcode (or an Xcode component such as the separately downloaded Metal toolchain) than the machine has, and cannot be built there (e.g. `splash`, `onlyswitch`). When such a package fails only because of the host Xcode/toolchain — not because of the update — skip it on that machine: leave it at its current version, keep any bump out of the diff, and report the reason instead of forcing it.
- Standard update workflow for a package in this repo:
  1. `./check_updates.py` lists candidates (network-only report, changes nothing).
  2. Run the package's own update script, not a hand edit. Build it from the flake so it runs with its declared inputs:
     `out=$(nix build .#legacyPackages.<system>.<pkg>.updateScript --no-link --print-out-paths)`
     then `"$out"/bin/update-<pkg>` (packages without one can use `nix-update <pkg>`).
     `.#legacyPackages.<system>.<pkg>` is the reliable installable; `.#packages.<system>.<pkg>` is not one (Nix reads it as `legacyPackages.<system>.packages.<system>.<pkg>`, and this overlay's `packages` attribute is a function). `nix build .#<pkg>` still works for packages whose per-system derivation is supported, e.g. `kytyps5`, which repackages itself from a pinned x86_64-darwin nixpkgs inside its own `package.nix` (the flake keeps nixpkgs as its only input).
  3. Review `git diff`: the script must update every coupled pin (version, src hash, dependency/FOD hashes, commit metadata), not just the version.
  4. `git add` new files, then verify with `nix build` for the package before committing; the gate is the package's own derivation, not just a successful evaluation.
  5. When updating a main package, also check and fix up any patched/derived variants that build on it (e.g. `<pkg>_patched`, such as `lastbook_patched`): rebase their patches, refresh any variant-specific manifests/assets, and verify their `nix build` passes too.
  6. Format changed Nix files with `nixfmt` (nixfmt-rfc-style). Don't reformat unrelated code, and never rewrite a patch file for formatting alone.
  7. Keep the conventional versioning rules below; if a script produces a bad `version`, fix the script, not just the output.
- `check_updates.py` reports the latest upstream commit for git-sourced packages even when the tracked file/release commit did not move (e.g. freebuff pins the commit that sets the npm release version, not branch HEAD). Confirm with the package's update script before bumping.
- A package whose upstream lags (e.g. VSCodium has no release for the newest vscode tag) must not be bumped to a version its branding/patch set does not support; leave it and report why.
- Standard Nixpkgs versioning rule: NEVER use a commit hash directly as `version`! For unreleased packages or builds tracking git commits/branches, follow the standard Nixpkgs convention:
  - If there is a prior release/tag or known base version: `version = "<base-version>-unstable-<YYYY-MM-DD>";` (e.g. `"5.0-unstable-2026-04-21"` or `"6.0.0-unstable-2026-10-03"`).
  - If there are no prior releases: `version = "0-unstable-<YYYY-MM-DD>";`.
  - Put the git commit hash in a separate attribute or local binding (`rev = "...";` or `commit = "...";`) rather than in `version`.

## Usual update workflow

This is the standard procedure when updating packages reported by `./check_updates.py`:

1. **Check the update script is correct.** Every package should expose `passthru.updateScript` (a `nix-update-script`, `writeShellApplication`, or a script under the package directory). Read it and confirm it updates the right attributes (version, source rev/hash, plus any extra pins such as `cargoHash`, `vendorHash`, `pnpmDeps`/`npmDeps` hashes, submodule revisions, or companion assets). Fix or write the script first if it is missing or stale — do not hand-edit versions that the script is supposed to handle. Keep `version` in the `<base>-unstable-<date>` / `0-unstable-<date>` form; scripts must normalise rolling upstream tags (e.g. `nightly`) rather than use them verbatim.
2. **Call the update script**, not `nix-update` by hand: `nix run --impure .#<pkg>.passthru.updateScript` (or `./scripts/update-packages.sh` to run them all). New files referenced by `package.nix` must be `git add`ed before this, because untracked files are invisible to flake evaluation.
3. **Make `nix build .#<pkg>` pass** and fix whatever the update broke: hash mismatches (`lib.fakeHash` then paste the reported hash), new or changed upstream dependencies (vendored cargo crates, npm/pnpm deps, Rust/Go toolchain additions), patches that no longer apply, new build-time downloads that must be staged as fixed-output derivations because the sandbox has no network, and upstream-mandated build flags/tags. Prefer fixing the cause in the package expression over disabling tests or features.
4. Re-run the package's update script once more to confirm it is idempotent, clean up scratch files (`git status`), and only then commit.

## Gradle / Compose Desktop dependency locks

`gradle.fetchDeps` only records what the machine running the update resolved, and
`compose.desktop.currentOs` pulls just the host OS's desktop binaries. A `deps.json`
generated on darwin then fails on linux (and vice versa) with
`Could not find org.jetbrains.compose.desktop:desktop-jvm-<os>-<arch>`. Lock every
supported OS in the same `deps.json` by running the deps download once per target
with that OS spoofed, in the package's `gradleUpdateScript`:

```nix
gradle :app:nixDownloadDeps -Dos.name=Linux -Dos.arch=amd64
gradle :app:nixDownloadDeps -Dos.name=Linux -Dos.arch=aarch64
gradle :app:nixDownloadDeps -Dos.name='Mac OS X' -Dos.arch=amd64
gradle :app:nixDownloadDeps -Dos.name='Mac OS X' -Dos.arch=aarch64
```

`nixDownloadDeps` is not a per-package task: the nixpkgs gradle setup hook injects it
(see its `init-deps.gradle`) into every project when `IN_GRADLE_UPDATE_DEPS=1`, and it
resolves every resolvable configuration. Do not register a task with that name in the
package's build script — it collides with the injected one. `-Dos.name` and
`-Dos.arch` are what Compose (and Gradle's platform attributes) actually read;
`-Dos.family` alone keeps the host's OS and locks nothing. The OS-specific pieces
are the `org.jetbrains.compose.desktop:desktop-jvm-<os>-<arch>` artifacts
(`linux`/`macos`/`windows` + `x64`/`arm64`); skiko ships the fat
`skiko-awt-runtime-all`, so it needs no per-OS lock. Examples in this repo:
`bifrost` and `archivetune` (the loop above). `komi-store` achieves the same by
appending the extra platform `implementation` deps to its build script.

