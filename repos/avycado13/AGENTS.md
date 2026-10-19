# AGENTS.md

This document helps AI agents work effectively in this NixOS/Nix-Darwin configuration repository.

## Project Overview

This is a Nix flake-based configuration for managing multiple systems:

- **Avys-Mac** — Apple Silicon macOS (nix-darwin + home-manager + nix-homebrew)
- **pi0** — Raspberry Pi Zero 2W (NixOS, aarch64-linux, SD card image; currently commented out in flake.nix)
- **pi1** — Raspberry Pi 3 (NixOS, aarch64-linux, SD card image, runs the homelab)
- **oracle** — Oracle Cloud VM (NixOS, x86_64-linux, OCI image)
- **eclipse** — NixOS, x86_64-linux (srvos server profile, disko for partitioning)
- **gce** — Google Compute Engine VM (NixOS, x86_64-linux, GCE image)
- **apollo1** — Allwinner A64 SBC (NixOS, aarch64-linux, SD card image via u-boot/extlinux, wifi via sops-templated `wpa_supplicant` config)
- **apollo13** — Allwinner A64 SBC (Pine64+) (NixOS, aarch64-linux, SD card image via u-boot/extlinux, wifi via sops-templated `wpa_supplicant` config)
- Uses sops-nix for secrets management
- Includes homelab services and reusable NixOS modules

## Essential Commands

```bash
nix develop          # Enter dev shell (provides: just, nh, nixos-rebuild-ng, treefmt, sops, ssh-to-age, nil, cachix, nix-output-monitor, niks3, devour-flake, omnix)
treefmt              # Format all files (nixfmt + deadnix + shellcheck)
nix flake check      # Validate flake

just darwin-deploy               # Apply Darwin config on this Mac (nh darwin switch)
just dry-run <host>              # Test NixOS deploy without applying
just deploy <host>               # rsync + nixos-rebuild switch to NixOS host
just copy <host>                 # rsync only (no rebuild)
just home-deploy <host>          # rsync + home-manager switch on a remote host
just home-dry-run <host>         # rsync + home-manager switch --dry-run on a remote host
just update                      # nix flake update
just check                       # nix flake check
just choose                      # Interactive recipe picker with fzf
just build-iso <host>            # Build a NixOS installer ISO for a host
```

## Code Organization

### Directory Structure

```
flake.nix               # Entry point; calls mkDarwin/mkNixos per host (Avys-Mac, pi0, pi1, apollo1, apollo13, oracle, eclipse, gce)
flakeHelpers.nix         # mkDarwin, mkNixos, mkHome, mkMerge, nixpkgsCfg — read first for new machines
machines/
  darwin/
    default.nix          # shared settings for all Darwin machines (nixpkgs config, sops age keys)
    Avys-Mac/             # host-specific config + ricing.nix, system.nix, home.nix
  nixos/
    default.nix           # shared settings for all NixOS machines (imports modules/nix, binary caches, ssh/sudo defaults, tailscale, firewall)
    <hostname>/default.nix # host-specific config; extras like disko.nix, facter.json, hardware-configuration.nix live alongside
    pi1/homelab.nix        # host opting into the homelab (sets homelab.enable + homelab.services.*)
modules/                  # reusable NixOS modules: ddns, email, remoteBuild, nix, secrets
homelab/                  # imported into every NixOS system via mkNixos, inert unless homelab.enable is set
  default.nix              # top-level homelab.* options (group, timeZone, baseDomainName, cloudflare creds, email, notifications)
  services/
    default.nix            # homelab.services.enable, shared Caddy/ACME wiring, notify-failure@ template unit, imports every service dir
    <service>/default.nix  # one service per directory (see "Adding a Homelab Service" below)
  fail2ban-cloudflare/     # bans offenders at the Cloudflare edge
  motd/                    # login MOTD listing enabled/monitored services
users/avy/
  default.nix              # NixOS user declaration (uid, groups, shell, ssh key)
  packages.nix             # all user packages (utilities, scripts, late-sh)
  dots.nix                 # imports dotfile modules from dotfiles/<feature>/
  sops.nix                 # per-user sops secret declarations
  dotfiles/<feature>/      # browser, devenv, editor, git, gpg, irc, media, restic, shell, ssh, syncthing, terminal, theme
secrets/                  # sops-encrypted secrets.yaml (default) and services.yaml — never commit plaintext
dns.toml                  # Helix editor config (keybindings, language formatters)
toml.nix                  # Reads dns.toml into Nix attrset via builtins.fromTOML
upload-oci.sh             # Helper script for uploading QCOW2 images to Oracle Cloud
fileofbrew                # Reference file listing previous Homebrew packages (before nix-homebrew migration)
```

### Configuration Patterns

- Configurations use standard NixOS/Darwin module format
- Home-manager is integrated for user-specific settings on Darwin; on NixOS, home-manager is imported but the user block in mkNixos is currently commented out
- Flake helpers (`mkDarwin`, `mkNixos`, `mkMerge`) standardize configuration creation
- Secrets are managed via sops-nix (encrypted YAML files in `secrets/`)
- `unf` (from the `unf` input) is used for JSON module option generation via `mkOpts`

## Development Workflow

1. Make changes to configuration files
2. Test with `just dry-run <host>` for NixOS or local rebuild for Darwin
3. Format code: `treefmt` (automatically configured)
4. Commit and deploy with `just deploy <host>`

## CI/CD

GitHub Actions workflows in `.github/workflows/`:

- **build.yml**: Runs on push to main and PRs. Builds across 3 platforms (x86_64-linux, aarch64-darwin, aarch64-linux) using `om ci run`. Connects to Tailscale for cache access, pushes to the niks3 cache (via the `niks3` CLI) with retries.
- **update-flake-lock.yml**: Runs weekly (Monday 06:47 UTC) and on dispatch. Updates flake.lock, commits, pushes, and pushes realized outputs to the niks3 cache.

## Formatting and Linting

- **Formatter**: `nixfmt` (configured in flake.nix via treefmt-nix)
- **Linting**: `deadnix` (detects unused code), `shellcheck` (shell scripts)
- **Auto-format**: Run `treefmt` to format all files
- Exclusions: `*.lock`, `.gitignore`, `secrets/*`

## Gotchas

- **State Version**: Varies by host — `"25.05"` (pi1, eclipse), `"25.11"` (pi0), `"26.05"` (oracle, gce), `5` (Avys-Mac Darwin)
- **Sops**: Secrets are in `secrets/` directory (YAML files), managed with `sops` tool. Recipients defined in `.sops.yaml` (age keys `avy`/`pi1`, a GPG key, and an AWS KMS key)
- **Home Directory**: Darwin configs set `homeDirectory = "/Users/avy"`; NixOS uses `/home/avy`
- **Mutable Users**: pi1 disables mutable users for security
- **Imports**: Configurations import from parent directories (e.g., `./homelab`, `./users/avy`)
- **Hardware Modules**: NixOS configs may include hardware-specific modules (e.g., `nixos-hardware.nixosModules.raspberry-pi-3`)
- **pi0**: Currently commented out in `flake.nix` outputs
- **mkService**: Some homelab services (postgres, lldap) use the `mkService.nix` factory in `homelab/lib/mkService.nix`, imported via `import ../../lib/mkService.nix`
- **Homelab services**: `homelab/services/default.nix` currently imports `miniflux`, `auth`, `glance`, `niks3`, `retrom`, `cloudrun`, `scrutiny`, `restic`, `isponsorblocktv`, `lard`, `calibre-web`, `asterisk`, `irc`, `navidrome`. Enabled on pi1: all except `retrom`.

## Secrets Management

- Uses `sops-nix` for encrypted secrets
- Secret files: `secrets/secrets.yaml` (default) and `secrets/services.yaml`
- Recipients defined in `.sops.yaml` (age keys for `avy` and `pi1`, a GPG key, and an AWS KMS key)
- Age key file at `~/.config/sops/age/keys.txt` plus host SSH host keys are used to decrypt
- Modules: `modules/secrets/default.nix` (NixOS), `modules/secrets/home.nix` (home-manager)
- Never commit plaintext secrets

## Testing

- No automated unit tests currently
- Manual testing via `dry-run` commands
- CI runs `om ci run` across all platforms via GitHub Actions
