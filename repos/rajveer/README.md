# Rajveer's NUR packages

Nix packaging for [NixBox](https://github.com/SINGH-RAJVEER/nixbox), pinned to the latest successfully published stable release.

| Package | Interface | Platforms |
| --- | --- | --- |
| `nixbox` | Native desktop GUI | Linux |
| `nixbox-tui` | Terminal UI | x86_64 Linux, aarch64 Linux, aarch64 macOS |
| `nixbox-cli` | Commands, including `nixbox`, `nb`, and `nixbox-cli` | x86_64 Linux, aarch64 Linux, aarch64 macOS |
| `nixbox-gui` | Alias for the `nixbox` GUI package | Linux |

The registered NUR namespace is `rajveer`.

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
	pkgs.nur.repos.rajveer.nixbox-tui
	pkgs.nur.repos.rajveer.nixbox-cli
];
```

For standalone Home Manager, include `nur.modules.homeManager.default` in its modules and use the same package attributes in `home.packages`.

Update a pinned NUR input with `nix flake update nur`, then rebuild your configuration to receive a new package version.

## Install directly

```sh
nix run github:SINGH-RAJVEER/nur-packages#nixbox
nix profile add github:SINGH-RAJVEER/nur-packages#nixbox-tui
nix profile add github:SINGH-RAJVEER/nur-packages#nixbox-cli
```

The flake exports all package variants, `packages.<system>.default` as the GUI on Linux and the TUI on macOS, and `overlays.default`. Each interface is installed separately. The GUI installs `nixbox-gui`, the TUI installs `nixbox-tui`, and only the CLI provides terminal commands. NUR uses `default.nix` with its supplied Nixpkgs package set; it does not depend on this flake's Nixpkgs pin.

The GUI loads the system's Vulkan driver. On NixOS, importing through NUR or applying this overlay with your system's Nixpkgs keeps its graphics libraries compatible with that driver. A standalone flake built with an older Nixpkgs can fail with `No GPU adapters found` when a newer system driver requires a newer glibc. Refresh the Nixpkgs input, or pass `--override-input nixpkgs github:NixOS/nixpkgs/nixos-unstable` to `nix run` when using a newer unstable system.

Build and test compilation default to at most two jobs per package. Override this with `pkgs.nur.repos.rajveer.nixbox.override { buildJobs = 4; }`, or the equivalent override on the TUI/CLI package. This limits NixBox's compilation concurrency; it does not cap other derivations or impose a memory limit.

## Release updates

The updater checks hourly, and can also be run with GitHub's **Run workflow** button. GitHub may delay scheduled runs.

It selects a stable version only when the upstream `Publish crates` workflow succeeded and the version tag points to that exact commit. It fetches that commit, records its source hash and Cargo lock file, checks restricted NUR evaluation, and builds all three packages against Nixpkgs unstable. Only a passing update is committed and sent to NUR's update endpoint.

The updater uses this repository's `GITHUB_TOKEN`. It needs no cross-repository write token or additional secret. Keep GitHub Actions enabled and allow workflow writes to `main`; branch protection that forbids the bot's push needs a PR-based update workflow instead.

The source hash and local Cargo lock file live in `pkgs/nixbox`. A future release introducing Git dependencies requires explicit `cargoLock.outputHashes`; the updater stops until those have been added.

## Validate locally

With Nixpkgs unstable available through `NIX_PATH`:

```sh
bash scripts/check-evaluation.sh
nix-build default.nix -A nixbox -A nixbox-tui -A nixbox-cli --no-out-link
python scripts/update-nixbox.py --dry-run
```

Use Python 3.11 or newer for the updater. The GUI build enables NixBox's native feature, installs its desktop entry and icon, and wraps its graphics libraries.

## License

The packaging expressions, scripts, and documentation are MIT-licensed. NixBox is fetched from its upstream repository and remains Apache-2.0; package metadata records that upstream license.
