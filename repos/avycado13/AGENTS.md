# AGENTS.md

This document helps AI agents work effectively in this NixOS/Nix-Darwin configuration repository.

## Project Overview

This is a Nix flake-based configuration for managing multiple systems:

- **Avys-Mac** — Apple Silicon macOS (nix-darwin + home-manager + nix-homebrew)
- **pi0** — Raspberry Pi Zero 2W (NixOS, aarch64-linux, SD card image)
- **pi1** — Raspberry Pi 3 (NixOS, aarch64-linux, homelab reverse proxy and services)
- **pi2** — Raspberry Pi 2 v1.3 (NixOS, aarch64-linux, SD card image, home-manager)
- **oracle** — Oracle Cloud VM (NixOS, x86_64-linux, OCI image)
- **eclipse** — NixOS, x86_64-linux (srvos server profile, disko for partitioning)
- **gce** — Google Compute Engine VM (NixOS, x86_64-linux, GCE image)
- **apollo1** — Allwinner A64 SBC (NixOS, aarch64-linux, SD card image via u-boot/extlinux, wifi via sops-templated `wpa_supplicant` config)
- **apollo13** — Allwinner A64 SBC (Pine64+) (NixOS, aarch64-linux, SD card image via u-boot/extlinux, wifi via sops-templated `wpa_supplicant` config)
- **0xff** — NixOS x86_64-linux host (srvos, disko, home-manager)
- **nest** — NixOS x86_64-linux host
- **iso** — NixOS x86_64-linux installer ISO configuration
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
flake.nix               # Entry point; calls mkDarwin/mkNixos per host
flakeHelpers.nix         # mkDarwin, mkNixos, mkMerge, homeManagerCfg, nixpkgsCfg — read first for new machines
machines/
  darwin/
    default.nix          # shared settings for all Darwin machines (nixpkgs config, sops age keys)
    Avys-Mac/             # host-specific config + ricing.nix, system.nix, home.nix
  nixos/
    default.nix           # shared settings for all NixOS machines (imports modules/nix, binary caches, ssh/sudo defaults, tailscale, firewall)
    <hostname>/default.nix # host-specific config; extras like disko.nix, facter.json, hardware-configuration.nix live alongside
    pi1/homelab.nix        # host opting into the homelab (sets homelab.enable + homelab.services.*)
modules/                  # reusable modules: ddns, email, heTunnel, remoteBuild, nix, secrets, nixos
  hardware/a64/           # Pine64/A64 board profile (device tree, u-boot, boot loader)
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
- Home-manager is used on Darwin and on selected NixOS hosts (`pi1`, `pi2`, `0xff`). `mkNixos` imports its module; `flake.nix` passes `homeManagerCfg` for hosts that opt in. `homeDotsModule` forwards host-level `dots` settings to `home-manager.users.avy`.
- `flakeHelpers.nix` defines `mkDarwin`, `mkNixos`, `mkMerge`, `homeManagerCfg`, and `nixpkgsCfg`. Read it first when adding a machine.
- Machine configs layer shared `machines/<type>/default.nix`, host-specific `machines/<type>/<hostname>/default.nix`, and host extras such as `disko.nix` or `home.nix`.
- `modules/hardware/a64` supplies the Allwinner A64/Pine64 board profile; hosts such as `apollo1` add their own secrets, hostname, and users.
- `homelab/` is imported by `mkNixos` for every NixOS host, but is inert until `homelab.enable` is set. Hosts opt in via their `homelab.nix` (e.g. `machines/nixos/pi1/homelab.nix`). Caddy handles reverse proxying; ACME uses Cloudflare DNS challenges. `homelab/services/default.nix` is the authoritative list of imported service modules; not all imported services are enabled on a host.
- `users/avy/packages.nix` contains user packages and scripts, `dots.nix` imports feature-specific dotfiles, and `sops.nix` declares per-user secrets. Dotfile modules have enable flags (e.g. `dots.shell.enable`).
- `modules/nix/default.nix` configures substituters and distributed builds via nixbuild.net, and uploads build outputs to the niks3 cache with `services.niks3-auto-upload`; nix-cache-beacon announces/discovers local caches.
- `nixpkgsCfg` in `flakeHelpers.nix` applies `allowUnfree = true` and shared overlays.
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
- **nur.yml**: Evaluates and builds the NUR packages, then triggers a NUR update on main.
- **update-flake-lock.yml**: Runs weekly (Monday 06:47 UTC) and on dispatch. Updates flake.lock, commits, pushes, and pushes realized outputs to the niks3 cache.

## Formatting and Linting

- **Formatter**: `nixfmt` (configured in flake.nix via treefmt-nix)
- **Linting**: `deadnix` (detects unused code), `shellcheck` (shell scripts)
- **Auto-format**: Run `treefmt` to format all files
- Exclusions: `*.lock`, `.gitignore`, `secrets/*`

## Adding a Homelab Service

- Add a module defining `options.homelab.services.<service>` under `homelab/services/<service>/`; use `homelab/services/miniflux/default.nix` as an example. Import it from `homelab/services/default.nix`, then enable it on the host (e.g. `machines/nixos/pi1/homelab.nix`). Services define their own options, systemd/NixOS service, and Caddy virtual host.
- For Caddy, use `hl.acmeHostFor cfg.url` to select the appropriate ACME certificate. Optionally add `glance.name`/`glance.url`/`glance.description`; Glance collects bookmarks from enabled services with a non-null `glance.url`. Services can opt into failure alerts with `systemd.services.<service>.serviceConfig.OnFailure` when ntfy is configured.
- Feed credentials through sops and use `config.sops.secrets.<name>.path` or `config.sops.templates` (see `homelab/services/asterisk/default.nix` for the latter); never place plaintext secrets in Nix store derivations.
- Give every new service a Gatus endpoint option alongside its other `homelab.services.<service>` options. Prefer a dedicated unauthenticated health endpoint when available:

  ```nix
  gatus = import ../../lib/gatusEndpoint.nix {
    inherit lib;
    name = "Service Name";
    url = "https://${cfg.url}/healthz";
  };
  ```

  The helper defaults to checking `[STATUS] < 400` every `5m`; override `gatus.condition` or `gatus.interval` if needed. Gatus automatically collects endpoints from enabled services (and enabled Cloud Run services) when `homelab.services.gatus.enable` is set. Set a service's `gatus = null` only when it cannot be meaningfully checked.
- Run `treefmt` and `nix flake check` before committing.

## Gotchas

- **State Version**: Host-specific; check each host's `default.nix` before changing it (e.g. pi1/eclipse `"25.05"`, pi0/nest `"25.11"`, oracle/gce/pi2 `"26.05"`, 0xff `"26.11"`; Avys-Mac Darwin uses `5`). Do not bump just to match the current NixOS release.
- **Sops**: Secrets are in `secrets/` directory (YAML files), managed with `sops` tool. Recipients defined in `.sops.yaml` (age keys `avy`/`pi1`, a GPG key, and an AWS KMS key)
- **Home Directory**: Darwin configs set `homeDirectory = "/Users/avy"`; NixOS uses `/home/avy`
- **Mutable Users**: pi1 disables mutable users for security
- **Imports**: Configurations import from parent directories (e.g., `./homelab`, `./users/avy`)
- **NixOS home-manager**: Some hosts pass `homeManagerCfg` explicitly from `flake.nix`; others only import the module. Check the host configuration before editing user dotfiles.
- **Hardware Modules**: NixOS configs may include hardware-specific modules (e.g., `nixos-hardware.nixosModules.raspberry-pi-3`)
- **pi0**: Enabled in `flake.nix` outputs; uses the `nixos-pi-zero-2` SD-image module.
- **Homelab services**: `homelab/services/default.nix` lists the imported services; `machines/nixos/pi1/homelab.nix` selects which ones are enabled.

## Secrets Management

- Uses `sops-nix` for encrypted secrets
- Secret files: `secrets/secrets.yaml` (default) and `secrets/services.yaml`
- Recipients defined in `.sops.yaml` (age keys for `avy` and `pi1`, a GPG key, and an AWS KMS key)
- Age key file at `~/.config/sops/age/keys.txt` plus host SSH host keys are used to decrypt
- Modules: `modules/secrets/default.nix` (NixOS), `modules/secrets/home.nix` (home-manager)
- Never commit plaintext secrets

## Testing

- No dedicated unit-test suite; use `just dry-run <host>` for affected NixOS hosts.
- Run `nix flake check` for flake checks (including formatting/pre-commit checks); CI builds with `om ci run` across three platforms.
