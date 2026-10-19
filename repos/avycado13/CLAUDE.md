# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A Nix flake managing multiple systems declaratively:
- **Avys-Mac** — Apple Silicon macOS (nix-darwin + home-manager + nix-homebrew)
- **pi0** — Raspberry Pi Zero 2W (NixOS, aarch64-linux, SD card image; currently commented out in flake.nix)
- **pi1** — Raspberry Pi 3 (NixOS, aarch64-linux, SD card image, runs the homelab)
- **oracle** — Oracle Cloud VM (NixOS, x86_64-linux, OCI image)
- **eclipse** — NixOS, x86_64-linux (srvos server profile, disko for partitioning)
- **gce** — Google Compute Engine VM (NixOS, x86_64-linux, GCE image)
- **apollo1** — Allwinner A64 SBC (NixOS, aarch64-linux, SD card image via u-boot/extlinux, wifi via sops-templated `wpa_supplicant` config)
- **apollo13** — Allwinner A64 SBC (Pine64+) (NixOS, aarch64-linux, SD card image via u-boot/extlinux, wifi via sops-templated `wpa_supplicant` config)

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

## Codebase Structure

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
  hardware/a64/             # nixos-hardware-style Pine64/A64 board profile (device tree, u-boot, boot loader)
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

## Architecture

**`flakeHelpers.nix`** is the core abstraction. Defines `mkDarwin`, `mkNixos`, `mkHome`, `mkMerge`, and `nixpkgsCfg`. All system configs in `flake.nix` go through these builders (`flake.nix` currently only calls `mkDarwin` and `mkNixos`; `mkHome` exists as an unused-but-available helper). Read this file first when adding a new machine or understanding how inputs wire together.

**Layered machine configs:**
- `machines/<type>/default.nix` — shared settings for all machines of that type (nix settings, binary caches, ssh/sudo defaults)
- `machines/<type>/<hostname>/default.nix` — host-specific config (e.g. `machines/nixos/pi1/homelab.nix` wires up the homelab on that host)
- Machine-specific extras (e.g., `ricing.nix`, `system.nix`, `home.nix`, `disko.nix`, `facter.json`) imported by the host config

**User environment** — entirely in `users/avy/`:
- `packages.nix` — all user packages including utilities, custom shell scripts, and `late-sh` (gated behind `dots.lateSh.enable` option, default true)
- `dots.nix` — imports dotfile modules from `dotfiles/<feature>/` (browser, devenv, editor, git, gpg, irc, media, restic, shell, ssh, syncthing, terminal, theme)
- `default.nix` — NixOS user declaration (uid, groups, shell, ssh key)
- `sops.nix` — per-user sops secret declarations (paths, modes, which sops file each secret comes from)

**Modules** (`modules/`) — reusable NixOS modules: `ddns` (cloudflare/desec/duckdns/freedns), `email` (msmtp setup), `remoteBuild` (creates `remotebuild` user + configures nix-daemon), `nix` (core nix settings + substituters + distributed builds via nixbuild.net + `services.niks3-auto-upload` for pushing build outputs to the niks3 cache, imported by `machines/nixos/default.nix`), `secrets` (wires sops-nix; `default.nix` for NixOS, `home.nix` for home-manager), `hardware/a64` (nixos-hardware-style board profile for Allwinner A64/Pine64 boards — device tree + wifi overlay, u-boot SPL dd into the sd-image, extlinux boot loader, serial console; host configs like `apollo1` import it and layer on host-specific policy such as hostname, secrets, and user accounts).

**Homelab** (`homelab/`) — imported directly into every NixOS system (`mkNixos` always includes `./homelab`), gated behind `homelab.enable`/`homelab.services.enable` so it's inert unless a host opts in (currently only `pi1` does, via `machines/nixos/pi1/homelab.nix`). Reverse proxy is **Caddy** (not Traefik), with ACME via `security.acme` (cloudflare DNS challenge). Currently imported services (see `homelab/services/default.nix` imports): `miniflux`, `auth` (indiko + lldap), `glance`, `niks3`, `retrom`, `cloudrun`, `scrutiny`, `restic`, `isponsorblocktv`, `lard`, `calibre-web`, `asterisk`, `irc`, `navidrome`. A `postgres` service dir provides shared DB setup for services that need it. `homelab/motd` builds a login MOTD listing enabled/monitored services; `homelab/fail2ban-cloudflare` bans offenders at the Cloudflare edge.

**Currently enabled on pi1:** miniflux, auth/indiko, glance, niks3 (S3-backed Nix binary cache, backed by an R2 bucket), cloudrun (searxng, it-tools), scrutiny, restic (backing up to B2), isponsorblocktv, lard, calibre-web, navidrome, asterisk (SIP/PBX), irc. **Disabled on pi1:** retrom (enable = false). **fail2ban-cloudflare** is enabled on pi1 but no jails configured yet.

## Adding a Homelab Service

Each service lives in its own directory under `homelab/services/<name>/default.nix`, defines its own `options.homelab.services.<name>`, and is wired into the shared Caddy reverse proxy. Two patterns exist:

1. **Hand-rolled services** — most services follow this pattern. Copy an existing service like `homelab/services/miniflux/default.nix` or `homelab/services/scrutiny/default.nix` and adapt it. Pattern:

```nix
{ config, lib, ... }:
let
  service = "myservice";
  hl = config.homelab;
  cfg = hl.services.${service};
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption "Enable ${service}";
    url = lib.mkOption {
      type = lib.types.str;
      default = "myservice.${hl.baseDomainName}";
      description = "Domain to serve myservice on";
    };
    # Optional: surface a bookmark/monitor entry on the Glance dashboard.
    glance.name = lib.mkOption {
      type = lib.types.str;
      default = "My Service";
    };
    glance.url = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "https://${cfg.url}";
      description = "URL to show for this service in the Glance homelab bookmarks";
    };
  };

  config = lib.mkIf cfg.enable {
    services.${service}.enable = true; # or hand-roll a systemd unit / container

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = hl.baseDomainName;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:PORT
      '';
    };

    # Optional: page on failure via ntfy, matching the shared template unit.
    systemd.services.${service}.serviceConfig.OnFailure = lib.mkIf (
      hl.notifications.ntfySecretsFile != null
    ) "notify-failure@%n.service";
  };
}
```

2. **mkService factory** — `postgres` and `lldap` use the `mkService.nix` factory in `homelab/lib/mkService.nix` (`import ../../lib/mkService.nix`). Prefer the hand-rolled pattern for new services unless they closely match an existing factory-based one.

Then:
1. Add `./<name>` to the `imports` list in `homelab/services/default.nix`.
2. Enable it on a host, e.g. in `machines/nixos/pi1/homelab.nix`: `homelab.services.<name>.enable = true;` plus any required options.
3. Feed secrets (API keys, credentials files) through sops — add them to `secrets/services.yaml` and reference the decrypted path via `config.sops.secrets.<name>.path` or `config.sops.templates`, never inline. See `homelab/services/retrom/default.nix` for an example using `sops.templates` to render a JSON config file containing secrets (avoids writing them to the Nix store in plaintext, unlike `pkgs.writeText`-based `settings` options some upstream modules expose).
4. If the service should appear on the homelab Glance dashboard, define `glance.name`/`glance.url`/`glance.description` options as above — `homelab/services/glance/default.nix` auto-collects bookmarks from any `homelab.services.*` with `enable = true` and a non-null `glance.url`.
5. Run `treefmt` and `nix flake check` before committing.

## Key Patterns

- **Secrets**: `sops-nix`, not agenix. Encrypted files in `secrets/secrets.yaml` (default) and `secrets/services.yaml`; recipients defined in `.sops.yaml` (age keys `avy`/`pi1`, a GPG key, and an AWS KMS key). Age key file at `~/.config/sops/age/keys.txt` plus host SSH host keys are used to decrypt (`modules/secrets/default.nix`). Never commit plaintext secrets.
- **nixpkgs config**: `allowUnfree = true`, overlays for nix-topology, lazygit, NUR, nix-vscode-extensions, fenix — applied uniformly via `nixpkgsCfg` in `flakeHelpers.nix`.
- **Binary caches / substituters**: numtide, catppuccin, virby, nix-community, helix, fenix, avycado13, niks3 (self-hosted at `cache.avyay.in`), retrom — configured in `modules/nix/default.nix`, shared by all NixOS hosts.
- **Distributed builds**: All NixOS hosts use `eu.nixbuild.net` for remote builds (x86_64-linux, aarch64-linux, armv7l-linux, i686-linux) via SSH key at `~/.ssh/avy`.
- **Post-build hook**: All NixOS hosts push build outputs to the niks3 cache via `services.niks3-auto-upload` (a socket-activated daemon that batches pushes and manages `nix.settings.post-build-hook` itself).
- **nix-cache-beacon**: Enabled alongside niks3 to announce/discover caches on the local network.
- **State version**: Varies by host — `"25.05"` (pi1, eclipse), `"25.11"` (pi0), `"26.05"` (oracle, gce), `5` (Avys-Mac Darwin).
- **Home-manager on NixOS**: The `homeManagerCfg` call in `mkNixos` is currently commented out; NixOS hosts use `users/avy/` directly. Darwin uses `homeManagerCfg` with full dotfile module imports.
- **Dotfile modules**: User dotfiles use a module system with enable flags (e.g., `dots.shell.enable`, `dots.editor.enable`), declared in `machines/darwin/Avys-Mac/home.nix`.

## CI/CD

GitHub Actions workflows in `.github/workflows/`:

- **build.yml**: Runs on push to main and PRs. Builds across 3 platforms (x86_64-linux, aarch64-darwin, aarch64-linux) using `om ci run`. Connects to Tailscale for cache access, pushes to the niks3 cache (via the `niks3` CLI) with retries.
- **update-flake-lock.yml**: Runs weekly (Monday 06:47 UTC) and on dispatch. Updates flake.lock, commits, pushes, and pushes realized outputs to the niks3 cache.

## Formatting

`treefmt` is the single formatter. It runs nixfmt, deadnix, and shellcheck. Run it before committing. Exclusions: `*.lock`, `.gitignore`, `secrets/*`.
