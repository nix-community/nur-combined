# nixcfg

**My personal [NUR](https://github.com/nix-community/NUR) repository**

[Search](https://nur.nix-community.org/repos/toyvo)

[![Cachix Cache](https://img.shields.io/badge/cachix-toyvo-blue.svg)](https://toyvo.cachix.org)

CI runs on self-hosted Forgejo Actions (git.toyvo.dev);

A single Nix flake serving two purposes:

1. **NUR repository** — custom packages, published via
   [NUR](https://github.com/nix-community/NUR) and the
   [cache.toyvo.dev](https://cache.toyvo.dev) binary cache.
1. **System configurations** — shared NixOS, nix-darwin, and Home Manager
   configurations for my machines (desktops, laptops, NAS, router, VPS, ...),
   including the self-hosted services behind `*.diekvoss.net`, `*.diekvoss.com`, or `*.toyvo.dev`.

## Layout

| Path              | Contents                                                         |
| ----------------- | ---------------------------------------------------------------- |
| `configurations/` | Machine configurations (`nixos/`, `darwin/`, `home/`)            |
| `modules/`        | Shared modules (`os/`, `nixos/`, `darwin/`, `home/`, `flake/`)   |
| `pkgs/`           | Custom packages (NUR)                                            |
| `lib/`            | Custom library functions                                         |
| `homelab.nix`     | Homelab host/service registry (drives Caddy vhosts + homepage)   |
| `AGENTS.md`       | Guidance for AI coding agents (structure, conventions, commands) |
| `todos.md`        | Outstanding work and follow-ups                                  |

## Usage

```bash
nix flake show                                   # list all outputs
nix build .#nixosConfigurations.nas.config.system.build.toplevel
deploy .#nas                                     # deploy-rs to a remote node
nix run .#setup-sops                             # provision sops/age keys
```

See [AGENTS.md](AGENTS.md) for full build/deploy commands and development
conventions.
