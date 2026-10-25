# AGENTS.md

Guidance for AI coding agents working in this Nix/NixOS configuration repository.

## Repository Overview

Dual-purpose Nix flake: a **NUR (Nix User Repository)** publishing custom packages, and a **shared system configuration** for 20 machines across NixOS, nix-darwin, and Home Manager.

- GitHub: `ToyVo/nixcfg`
- Primary branch: `main`
- Uses `nixos-unstable` as base nixpkgs

## Build, Lint, and Test Commands

### Formatting (Required Before Commit)

```bash
nix fmt                          # Format all files (nixfmt, prettier, yamlfmt, mdformat)
```

### Evaluation and Building

```bash
nix flake show                   # Show all flake outputs (evaluation check)
nix flake check                  # Run all flake checks

# Build specific system configurations
nix build .#darwinConfigurations.MacBook-Pro.config.system.build.toplevel
nix build .#nixosConfigurations.nas.config.system.build.toplevel

# Build specific packages
nix build .#setup-sops
nix build .#packages.x86_64-linux.fabricServers.fabric-1-21-4

# Build and run
nix run .#setup-sops
```

### Development Environment

```bash
nix develop                      # Enter dev shell with tools and git hooks
```

### Deployment (System Updates)

```bash
# NixOS
nixos-rebuild switch --flake .#<hostname>

# nix-darwin (macOS)
darwin-rebuild switch --flake .#<hostname>

# Home Manager
home-manager switch --flake .#<hostname>

# deploy-rs (remote nodes defined in flake.nix, e.g. nas)
deploy .#<hostname>
```

**No Traditional Tests**: This repo has no unit tests. Validation is via `nix flake show` (evaluation check) and building outputs. CI builds the aggregate `checks.<system>.all` derivation with a single `nix build` (cachix `watch-store` pushes results).

## Code Style Guidelines

### Nix Language Style

- Use `nixfmt` for formatting (enforced by `nix fmt`)
- Prefer `lib.mkEnableOption` and `lib.mkOption` for module options
- Use `lib.mkIf` for conditional config, `lib.mkDefault` for defaults
- Functions: `camelCase` for parameters, lowercase for local vars
- Modules: `cfg = config.path.to.option` pattern for accessing config
- Use `with lib;` sparingly; prefer explicit `lib.` prefix for clarity

### Module Structure

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.myModule.option;
in
{
  options.myModule.option = {
    enable = lib.mkEnableOption "description";
    setting = lib.mkOption {
      type = lib.types.str;
      default = "value";
      description = "Description here";
    };
  };

  config = lib.mkIf cfg.enable {
    # Configuration here
  };
}
```

### Package Structure

Each package directory has a `package.nix` entry point:

```nix
{ lib
, stdenv
, fetchurl
, # ... other deps
}:

stdenv.mkDerivation rec {
  pname = "package-name";
  version = "1.0.0";

  src = fetchurl {
    url = "...";
    hash = lib.fakeHash; # Replace after first build attempt
  };

  meta = {
    description = "Brief description";
    homepage = "https://example.com";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ toyvo ];
    mainProgram = "program-name";
  };
}
```

### Imports and Dependencies

- Use `callPackage` pattern for package dependencies
- Prefer `pkgs.callPackage` over direct imports
- For flakes: explicit inputs in `flake.nix`, use `inputs.nixpkgs.follows` to reduce duplication
- Access custom lib functions via `self.lib`

### Naming Conventions

- **Files/Directories**: `kebab-case` (e.g., `fabric-servers`, `setup-sops`)
- **Nix Attributes**: `camelCase` (e.g., `nixosConfigurations`, `darwinConfigurations`)
- **Module Options**: `camelCase` (e.g., `containerPresets`, `programs.bat`)
- **Packages**: match upstream naming where possible

### Error Handling

- Use `lib.mkOption` with appropriate `type` for validation
- Fail fast with `throw` or `assert` for impossible states
- Use `lib.optional` and `lib.optionals` for conditional lists
- For package hashes: start with `lib.fakeHash`, run build, copy actual hash

### Secrets Management

- Uses `sops-nix` with age encryption
- `.sops.yaml` defines per-machine age keys
- `secrets.yaml` contains encrypted secrets
- **Never commit unencrypted secrets**
- Use `setup-sops` command to generate age keys

## Architecture

### Module Tree (`modules/`)

Each tree has a `default.nix` that **explicitly imports** its modules (no auto-discovery):

| Directory         | Scope        | Description                                       |
| ----------------- | ------------ | ------------------------------------------------- |
| `modules/os/`     | Shared       | OS-agnostic config for NixOS and Darwin           |
| `modules/nixos/`  | NixOS        | Linux-specific: services, containers, filesystems |
| `modules/darwin/` | Darwin       | macOS-specific: ollama, podman                    |
| `modules/home/`   | Home Manager | User-level programs, user profiles                |
| `modules/flake/`  | flake-parts  | Flake-level modules                               |

Exposed as flake outputs `nixosModules` / `darwinModules` / `homeModules` / `flakeModules`
(plus `modules.<tree>` aliases). Machine configs consume them via
`inputs.nixcfg.modules.<tree>.default`.

### System Configurations (`configurations/`)

Machines live in `configurations/<class>/<hostname>/`, where class is `nixos`, `darwin`,
or `home`. Each machine directory contains:

- `default.nix`: Function of flake inputs returning the built configuration
  (`nixosSystem` / `darwinSystem` / `homeConfiguration`); wires up `specialArgs`
  (`homelab`, `stablePkgs`, `unstablePkgs`, ...)
- `configuration.nix`: System configuration (NixOS/Darwin)
- `home.nix`: Shared Home Manager config, where applicable

Machines are registered **explicitly** in `configurations/default.nix`, which maps
flake output names (e.g., `nixosConfigurations.nas`) to the directories.

### Homelab Service Registry (`homelab.nix`)

`homelab.nix` is the single source of truth for homelab hosts and the services
running on them: IP/MAC addresses plus a `services` attrset per host with fields
like `port`, `subdomain`, `domain` (default `diekvoss.net`), `forwardAuthGate`
(default `true`; gates the vhost behind authentik), `selfSigned`, and homepage
metadata (`displayName`, `description`, `category`, `icon`, `widget`).

Consumers:

- `configurations/nixos/router/virtual-hosts.nix` — generates a Caddy vhost
  `<subdomain>.<domain>` → `http://<host ip>:<port>` for every service on a
  `10.1.0.0/16` or `10.200.0.0/16` host. TLS uses the `*.diekvoss.net` /
  `*.toyvo.dev` wildcard ACME certs (Cloudflare DNS challenge). See
  "Domains and Public Exposure" below for how vhost listen addresses are chosen.
- `configurations/nixos/nas/homepage.nix` — generates homepage-dashboard
  entries grouped by `category`.

To expose a new service: add its entry to `homelab.nix`, run it on its host, and
open the host firewall port. DNS records for the public domains are managed in
Cloudflare (manually, except `toyvo.dev`, which uses dyndns).

Note on SSH: the router's admin sshd listens on port **2222** (client config in
`modules/home/programs/ssh.nix`). TCP/22 on the router is relayed to the nas
(`git-ssh-relay` service) so forgejo git-over-SSH works on the standard port:
`forgejo@git.toyvo.dev:user/repo.git`.

### Domains and Public Exposure

- `diekvoss.net` — **internal-only**: only resolvable within the home network.
  As defense in depth, its Caddy vhosts listen on localhost/LAN addresses only,
  and services are gated behind authentik forward-auth by default
  (`forwardAuthGate = true`). Exposure risk is low, but don't treat it as
  nonexistent — the network has guest/IoT VLANs.
- `toyvo.dev` and `diekvoss.com` — **public internet-facing**: anything exposed
  on these domains is reachable by the entire world, so keep security top of
  mind. Their Caddy vhosts listen on all interfaces. Requirements for anything
  public: strong authentication (prefer authentik forward-auth or OIDC), no
  default/weak credentials, no unauthenticated write access, no sensitive data
  on unauthenticated endpoints, and the minimal set of open ports. Think twice
  before setting `domain = "toyvo.dev"` or `public = true` on a service.

### Packages (`pkgs/`)

NUR-style: each package lives in `pkgs/<name>/` (entry point `package.nix` or
`default.nix`) and is registered **explicitly** in the repository root
`default.nix` via `callPackage`. `flake.nix` exposes the result as
`legacyPackages`, filters derivations into `packages.<system>`, and publishes
them via `overlays/`. Common pattern: `package.nix` calls `derivation.nix` with
versions from `versions.json`.

### Custom Library (`lib/`)

Exposed as `self.lib`. Key utilities:

- `flattenPkgs` / `outputsOf` — Flatten package sets into derivations for checks
- `isBuildable` / `isCacheable` / `isReserved` / `forSystem` — Filter which derivations CI builds
- `platformsOf` — Platform lists for packages
- `mkWrappedProgram` — Wrapper helper for programs with extra args/env
- `maintainers.toyvo` — Maintainer entry, merged into nixpkgs `lib` for packages

## Common Patterns

### Adding a New System

1. Create `configurations/<class>/<hostname>/`
1. Add `default.nix` (function of inputs returning the `*System` call) and
   `configuration.nix` (NixOS/Darwin) or `home.nix` (Home Manager)
1. Register it in `configurations/default.nix`
1. Optionally add a `deploy.nodes.<hostname>` entry in `flake.nix` for deploy-rs

### Adding a New Package

1. Create `pkgs/<name>/`
1. Add `package.nix` (function accepting deps)
1. Register it in the repository root `default.nix` via `callPackage`

### Adding a New Module

1. Place the `.nix` file under the appropriate `modules/<tree>/`
1. Import it from that tree's `default.nix`
1. Reference via `inputs.nixcfg.modules.<tree>.default` (or `self.modules.<tree>`)

## Binary Caches

Configured substituters:

- `https://cache.nixos.org`
- `https://nix-community.cachix.org`
- `https://cache.toyvo.dev` — served by nix-serve on the nas out of its local
  store. Automatically excluded from substituters on the machine serving it
  (`nixcfg.nix.excludeOwnCache`, defaults to `services.nix-serve.enable`), and
  the nas resolves the domain to the router's LAN IP so trusted-user/CI builds
  that pick it up from the flake's `nixConfig` don't hairpin the WAN.

## Git Hooks

Dev shell includes pre-commit and pre-push hooks (auto-enabled):

- Pre-commit: formatting checks
- Pre-push: validation checks

Hooks configured in `flake.nix` via `devshell` module.

## Version Control (jj)

This repo uses **jj** (Jujutsu) for version control, not git. When pushing changes:

```bash
# Move main bookmark to current commit and push
jj bookmark set main -r @ && jj git push
```

**Never use `jj git push --all` or create new bookmarks without explicit user request.**

The standard workflow is:

1. Make changes
1. `jj describe -m "commit message"`
1. `jj bookmark set main -r @ && jj git push`

## Downstream Usage

Work machine config imports this flake and uses `nixcfg.lib.darwinSystem` to inherit shared modules/overlays.

## Todo Tracking

Outstanding follow-up work lives in [`todos.md`](todos.md).

**Standing instruction for agents: keep `todos.md` up to date automatically.**

- When you complete work that has an entry in `todos.md`, check it off (or
  remove it) in the same change.
- When you defer work, leave a manual step for the user, or notice a worthwhile
  improvement you don't implement, add it to `todos.md` before finishing.
- Check `todos.md` when starting related work and pick up open items when asked.

Likewise, keep this `AGENTS.md` current: when you change the repository
structure, registration patterns, or workflows, update the relevant sections in
the same change.
