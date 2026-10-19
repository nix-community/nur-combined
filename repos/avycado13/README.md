# nix

avy's (avycado13) Nix configuration — a flake-based setup for managing macOS and NixOS systems with home-manager, homelab services, and encrypted secrets.

## Systems

| Host | Platform | Description |
|------|----------|-------------|
| `Avys-Mac` | `aarch64-darwin` | macOS (nix-darwin) |
| `pi0` | `aarch64-linux` | Raspberry Pi Zero 2W (currently commented out in flake.nix) |
| `pi1` | `aarch64-linux` | Raspberry Pi 3, runs the homelab |
| `apollo1` | `aarch64-linux` | Allwinner A64 SBC |
| `apollo13` | `aarch64-linux` | Allwinner A64 SBC (Pine64+) |
| `oracle` | `x86_64-linux` | Oracle Cloud VM |
| `eclipse` | `x86_64-linux` | NixOS server |
| `gce` | `x86_64-linux` | Google Compute Engine VM |

## Structure

```
flake.nix            # Flake definition
flakeHelpers.nix     # mkDarwin / mkNixos helpers
machines/
  darwin/            # macOS configurations
  nixos/             # NixOS configurations (pi0, pi1, apollo1, apollo13, oracle, eclipse, gce)
users/avy/           # User config & dotfiles (home-manager)
homelab/
  services/          # miniflux, auth, glance, niks3, retrom, cloudrun, scrutiny,
                      # restic, isponsorblocktv, lard, calibre-web, asterisk, irc, navidrome
  motd/               # Message of the day
  fail2ban-cloudflare/ # bans offenders at the Cloudflare edge
modules/             # Reusable modules (ddns, email, binary cache, remote build)
pkgs/                # NUR package definitions
scripts/brew2nur.py  # Homebrew-to-Nix package generator
secrets/             # sops-nix encrypted secrets (secrets.yaml, services.yaml)
```

## Usage

Enter the dev shell:

```bash
nix develop
```

### Deploy

```bash
just deploy <host>     # Deploy to a NixOS host
just dry-run <host>    # Dry-run a NixOS deployment
just darwin-deploy     # Rebuild macOS config locally
just update            # nix flake update
just check             # nix flake check
```

### NUR packages

This repository also serves as the `avycado13` [NUR](https://github.com/nix-community/NUR) repository. Packages live in `pkgs/` and are exported from `default.nix`; `overlay.nix` is a standalone nixpkgs overlay (also exposed as `overlays.default` in the flake). The overlay is enabled in the host configurations.

```bash
nix-env -f . -qa '*'                  # List NUR packages (requires <nixpkgs>)
nix-build -A gitcredits              # Build a package with legacy Nix
nix build .#gitcredits               # Build using the flake
nix-build ci.nix -A cacheOutputs     # Build supported, free, cacheable packages
```

`.github/workflows/nur.yml` builds the NUR packages and notifies the NUR registry on successful pushes to `main`. To complete the migration, update `avycado13` in [NUR's repos.json](https://github.com/nix-community/NUR/blob/master/repos.json) to point at `avycado13/nix` instead of `avycado13/nur-packages`.

### Formatting

```bash
treefmt
```

Uses `nixfmt`, `deadnix`, and `shellcheck`.

## Secrets

Managed with [sops-nix](https://github.com/Mic92/sops-nix). Encrypted YAML files (`secrets.yaml`, `services.yaml`) live in `secrets/`; recipients are defined in `.sops.yaml`. Never commit plaintext secrets.
