# emulation-nix

Emulators and console tooling for Nix: the ones nixpkgs does not carry, and newer builds of the ones it carries but does not keep up with. Everything is built from source where source builds exist, and pushed to a binary cache.

| Package | In nixpkgs | Here |
| --- | --- | --- |
| `ryujinx-canary` | `ryubing` 1.3.3, stable channel only | canary, near-daily |
| `citron-neo` | absent (nixpkgs' `citron` is an unrelated project) | `main` |
| `eden` | 0.2.1, tagged releases | `master`, re-exported from [eden-nix](https://github.com/Daaboulex/eden-nix) |
| `pcsx2` | 2.6.3 | 2.8.2 |
| `panda3ds` | absent | `master` |
| `nx-optimizer` | absent | `master` |
| `atmosphere` | absent | 1.11.2 release |
| `hekate` | absent | 6.5.3 release |

## Why

Three separate problems, one flake.

Some of these are simply not in nixpkgs — Citron NEO, Panda3DS, nx-optimizer, and the Switch-side custom firmware. Some are in nixpkgs but pinned to a channel that has stopped moving: `ryubing`'s updater filters canary tags out by design, so stable has not moved since 1.3.3 (2025-10-11) while canary ships almost daily. And some are in nixpkgs but behind: PCSX2 has been at 2.6.3 while upstream shipped 2.8.0, 2.8.1 and 2.8.2 inside two weeks, and Eden is packaged from tagged releases rather than master.

The rest is build time. A yuzu-lineage C++ tree or a full .NET restore is not something anyone wants to run on a laptop, which is what the cache is for.

## Use it

```nix
{
  inputs.emulation-nix.url = "github:ilyasturki/emulation-nix";
}
```

**Do not add `inputs.emulation-nix.inputs.nixpkgs.follows = "nixpkgs"`.** The cache only holds builds against this flake's own pin; following your nixpkgs rebuilds everything from source, which is the one thing this repo exists to avoid. The extra evaluation is the price.

Then either take the packages directly:

```nix
environment.systemPackages = [ inputs.emulation-nix.packages.${system}.citron-neo ];
```

or use the NixOS module, which applies the overlay and adds `programs.{eden,ryujinx-canary,citron-neo,pcsx2,panda3ds}`:

```nix
{
  imports = [ inputs.emulation-nix.nixosModules.default ];

  programs.citron-neo.enable = true;
  programs.ryujinx-canary.enable = true;
  programs.pcsx2.enable = true;
  programs.eden.enable = true;
}
```

`overlays.default` shadows nixpkgs' own `pcsx2` with the newer build. That is deliberate, but it means anything else in your configuration referring to `pkgs.pcsx2` gets this one.

`nx-optimizer` is under CC-BY-NC, which nixpkgs treats as unfree — it needs `nixpkgs.config.allowUnfree` (or an `allowUnfreePredicate`) wherever you use it.

Without flakes, `default.nix` takes your `pkgs` and returns every package but `eden`:

```nix
(import (fetchTarball "https://github.com/ilyasturki/emulation-nix/archive/main.tar.gz") { inherit pkgs; }).citron-neo
```

That builds against your nixpkgs rather than this flake's pin, so nothing comes from the cache.

### Custom firmware

`atmosphere` and `hekate` are SD card payloads, not Linux programs, so they install nothing into `bin`. Source-building them needs the devkitA64 toolchain, which nixpkgs does not package; these are the upstream release archives, unpacked and pinned.

```console
$ cp -r ${pkgs.atmosphere}/share/atmosphere/. /run/media/$USER/SWITCH/
$ cp -r ${pkgs.hekate}/share/hekate/. /run/media/$USER/SWITCH/
```

`fusee.bin` and `hekate_ctcaer_*.bin` sit alongside for injection over USB.

## Not here

**DuckStation.** Its root `CMakeLists.txt` reads `SPDX-License-Identifier: CC-BY-NC-ND-4.0 + Packaging Restriction`, and adds: *"you may not use this file to create packages or build recipes without explicit permission from the copyright holder … other files supporting the build system are covered under the same terms."* Writing a Nix recipe is exactly that. Upstream's README does permit redistributing unmodified releases, so the official AppImage is the supported route.

## Binary cache

```nix
nix.settings = {
  extra-substituters = [ "https://emulation-nix.cachix.org" ];
  extra-trusted-public-keys = [ "emulation-nix.cachix.org-1:I3Aml1Db63RSk37MGt6sS/SY2nPg++StOWS1+M6OeDg=" ];
};
```

## Updating

`nix develop --command ./scripts/update.sh` rewrites every package's version, rev, asset name and source hash in place. It needs the dev shell for `jq`, `perl` and `nix-prefetch-git`. `ONLY=citron-neo` restricts it to one package.

A weekly workflow runs it, opens a PR on `update/packages`, and dispatches `check.yml` against that branch. If every package builds and lint passes, that run squash-merges the PR and dispatches `check.yml` on `main`, which pushes to the cache. If anything fails, the PR stays open and the next weekly run updates it. A package whose upstream can't be reached is left at its current version and doesn't block the merge.

The PR's own `pull_request` check run sits at "approval required", because `GITHUB_TOKEN` opened it; the dispatched run is the one that counts. `gh workflow run check.yml --ref update/packages` retries the gate by hand.

`ryujinx-canary` is the exception to fetch-and-hash: its NuGet lockfile comes out of a build, so the script also runs `nix build .#ryujinx-canary.fetch-deps` and regenerates `pkgs/ryujinx-canary/deps.json`.

## Licence

MIT. `eden` is re-exported from [eden-nix](https://github.com/Daaboulex/eden-nix) (MIT); the emulators and firmware themselves are under their own upstream licences.
