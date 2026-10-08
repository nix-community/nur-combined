# Rajveer's NUR packages

Nix packaging for [NixBox](https://github.com/SINGH-RAJVEER/nixbox), pinned to the latest successfully published stable release.

| Package | Interface | Platforms |
| --- | --- | --- |
| `nixbox` | Terminal UI and commands | x86_64 Linux, aarch64 Linux, aarch64 macOS |
| `nixbox-cli` | Commands without the terminal UI | x86_64 Linux, aarch64 Linux, aarch64 macOS |
| `nixbox-gui` | Native desktop GUI | Linux |

The registered NUR namespace is intended to be `rajveer`. Until the registration PR is merged, use this repository as a flake input directly.

## Install through NUR

Add the NUR input to your system flake:

```nix
inputs.nur.url = "github:nix-community/NUR";
inputs.nur.inputs.nixpkgs.follows = "nixpkgs";
```

Include `nur.modules.nixos.default` in the modules passed to `nixosSystem`, then choose the interfaces you want:

```nix
environment.systemPackages = [
  pkgs.nur.repos.rajveer.nixbox
  pkgs.nur.repos.rajveer.nixbox-cli
  pkgs.nur.repos.rajveer.nixbox-gui
];
```

For standalone Home Manager, include `nur.modules.homeManager.default` in its modules and use the same package attributes in `home.packages`.

Update a pinned NUR input with `nix flake update nur`, then rebuild your configuration to receive a new package version.

## Install directly

```sh
nix run github:SINGH-RAJVEER/nur-packages#nixbox
nix profile install github:SINGH-RAJVEER/nur-packages#nixbox-gui
```

The flake exports all package variants, `packages.<system>.default` as the TUI, and `overlays.default`. NUR uses `default.nix` with its supplied Nixpkgs package set; it does not depend on this flake's Nixpkgs pin.

## Release updates

The updater checks hourly, and can also be run with GitHub's **Run workflow** button. GitHub may delay scheduled runs.

It selects a stable version only when the upstream `Publish crates` workflow succeeded and the version tag points to that exact commit. It fetches that commit, records its source hash and Cargo lock file, checks restricted NUR evaluation, and builds all three packages against Nixpkgs unstable. Only a passing update is committed and sent to NUR's update endpoint.

The updater uses this repository's `GITHUB_TOKEN`. It needs no cross-repository write token or additional secret. Keep GitHub Actions enabled and allow workflow writes to `main`; branch protection that forbids the bot's push needs a PR-based update workflow instead.

The source hash and local Cargo lock file live in `pkgs/nixbox`. A future release introducing Git dependencies requires explicit `cargoLock.outputHashes`; the updater stops until those have been added.

## Validate locally

With Nixpkgs unstable available through `NIX_PATH`:

```sh
bash scripts/check-evaluation.sh
nix-build default.nix -A nixbox -A nixbox-cli -A nixbox-gui --no-out-link
python scripts/update-nixbox.py --dry-run
```

Use Python 3.11 or newer for the updater. The GUI build enables NixBox's native feature, installs its desktop entry and icon, and wraps its graphics libraries.

## License

The packaging expressions, scripts, and documentation are MIT-licensed. NixBox is fetched from its upstream repository and remains Apache-2.0; package metadata records that upstream license.
